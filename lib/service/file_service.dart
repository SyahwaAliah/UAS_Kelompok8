
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/database/database_helper.dart';

class StoredDocument {
  final String name;
  final String path;
  final int sizeInBytes;
  final DateTime modified;

  const StoredDocument({
    required this.name,
    required this.path,
    required this.sizeInBytes,
    required this.modified,
  });

  String get extension =>
      p.extension(path).replaceFirst('.', '').toUpperCase();

  String get title => p.basenameWithoutExtension(path);

  String get formattedSize {
    if (sizeInBytes >= 1048576) {
      return '${(sizeInBytes / 1048576).toStringAsFixed(1)} MB';
    }

    if (sizeInBytes >= 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }

    return '$sizeInBytes B';
  }

  String get subtitle => '$extension • $formattedSize';
}

class FileServiceException implements Exception {
  final String message;

  const FileServiceException(this.message);

  @override
  String toString() => message;
}

class FileService {
  FileService._();

  static final FileService instance = FileService._();

  static const String _folderName = 'dokumen_skripsi';

  static const List<String> allowedExtensions = [
    'pdf',
    'doc',
    'docx',
  ];

  // =====================================================
  // LOGIN & DIRECTORY
  // =====================================================

  Future<Map<String, Object?>> _akunAktif() async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (akun == null) {
      throw const FileServiceException(
        'Silakan login terlebih dahulu.',
      );
    }

    return akun;
  }

  Future<Directory> _documentDirectory() async {
    final akun = await _akunAktif();

    final id = akun['id'] as int;
    final role = akun['role']?.toString() ?? '';

    if (role != 'mahasiswa' && role != 'dosen') {
      throw const FileServiceException(
        'Akun tidak memiliki akses dokumen.',
      );
    }

    final root = await getApplicationDocumentsDirectory();

    final folder = Directory(
      p.join(
        root.path,
        _folderName,
        '${role}_$id',
      ),
    );

    await folder.create(recursive: true);

    return folder;
  }

  // =====================================================
  // PICK FILE
  // =====================================================

  Future<File?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result == null) return null;

      final path = result.files.single.path;

      if (path == null || path.isEmpty) {
        throw const FileServiceException(
          'File tidak dapat dibaca.',
        );
      }

      return File(path);
    } on FileServiceException {
      rethrow;
    } catch (_) {
      throw const FileServiceException(
        'Gagal memilih dokumen.',
      );
    }
  }

  // =====================================================
  // SAVE DOCUMENT
  // =====================================================

  Future<StoredDocument> saveLocally(File source) async {
    final dir = await _documentDirectory();

    if (!await source.exists()) {
      throw const FileServiceException(
        'File sumber tidak ditemukan.',
      );
    }

    final ext = p.extension(source.path).toLowerCase();

    if (!allowedExtensions.contains(
      ext.replaceFirst('.', ''),
    )) {
      throw const FileServiceException(
        'Format dokumen tidak didukung.',
      );
    }

    final name = p.basenameWithoutExtension(source.path);

    var target = p.join(dir.path, '$name$ext');
    var number = 1;

    while (await File(target).exists()) {
      target = p.join(dir.path, '$name ($number)$ext');
      number++;
    }

    try {
      final copied = await source.copy(target);
      return _toStoredDocument(copied);
    } catch (_) {
      throw const FileServiceException(
        'Gagal menyimpan dokumen.',
      );
    }
  }

  Future<StoredDocument?> pickAndSave() async {
    final source = await pickDocument();

    if (source == null) return null;

    return saveLocally(source);
  }

  // =====================================================
  // LIST DOCUMENTS
  // =====================================================

  Future<List<StoredDocument>> getSavedDocuments() async {
    final dir = await _documentDirectory();

    try {
      final entries = await dir.list().toList();

      final documents = <StoredDocument>[];

      for (final entry in entries) {
        if (entry is File) {
          documents.add(
            await _toStoredDocument(entry),
          );
        }
      }

      documents.sort(
        (a, b) => b.modified.compareTo(a.modified),
      );

      return documents;
    } catch (_) {
      throw const FileServiceException(
        'Gagal mengambil daftar dokumen.',
      );
    }
  }

  // =====================================================
  // OPEN PERSONAL DOCUMENT
  // =====================================================

  Future<void> openDocument(String path) async {
    await _pastikanFileMilikAkun(path);
    await _bukaDenganAplikasi(path);
  }

  // =====================================================
  // DELETE PERSONAL DOCUMENT
  // =====================================================

  Future<void> deleteDocument(String path) async {
    await _pastikanFileMilikAkun(path);

    try {
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      throw const FileServiceException(
        'Gagal menghapus dokumen.',
      );
    }
  }

  // =====================================================
  // OPEN REVISION ATTACHMENT
  // Mahasiswa pemilik revisi atau dosen pembimbing
  // yang membuat revisi dapat membuka lampiran.
  // =====================================================

  Future<void> openRevisiAttachment({
    required int revisiId,
    required int lampiranId,
  }) async {
    final akun = await _akunAktif();

    final akunId = akun['id'] as int;
    final role = akun['role']?.toString() ?? '';

    if (role != 'mahasiswa' && role != 'dosen') {
      throw const FileServiceException(
        'Akses lampiran tidak diizinkan.',
      );
    }

    final db = await DatabaseHelper.instance.database;

    // Tabel lampiran dapat dibuat oleh halaman Revisi.
    // IF NOT EXISTS menjaga data yang sudah tersimpan.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_lampiran_revisi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        revisi_id INTEGER NOT NULL,
        mahasiswa_id INTEGER NOT NULL,
        nama_file TEXT NOT NULL,
        lokasi_file TEXT NOT NULL,
        ukuran_file INTEGER NOT NULL DEFAULT 0,
        dibuat_pada TEXT NOT NULL
      )
    ''');

    // Periksa hak akses berdasarkan relasi revisi.
    final rows = await db.rawQuery(
      '''
      SELECT l.lokasi_file, l.mahasiswa_id, r.dosen_id
      FROM skriva_lampiran_revisi l
      JOIN skriva_revisi r
        ON r.id = l.revisi_id
      JOIN skriva_pembimbing p
        ON p.mahasiswa_id = r.mahasiswa_id
       AND p.dosen_id = r.dosen_id
      WHERE l.id = ?
        AND l.revisi_id = ?
        AND l.mahasiswa_id = r.mahasiswa_id
        AND (
          (? = 'mahasiswa' AND r.mahasiswa_id = ?)
          OR
          (? = 'dosen' AND r.dosen_id = ?)
        )
      LIMIT 1
      ''',
      [
        lampiranId,
        revisiId,
        role,
        akunId,
        role,
        akunId,
      ],
    );

    if (rows.isEmpty) {
      throw const FileServiceException(
        'Lampiran tidak ditemukan atau akses ditolak.',
      );
    }

    final storedPath =
        rows.first['lokasi_file']?.toString() ?? '';

    if (storedPath.isEmpty) {
      throw const FileServiceException(
        'Lokasi lampiran tidak valid.',
      );
    }

    final dbPath = await getDatabasesPath();

    final folderAman = p.normalize(
      p.absolute(
        p.join(
          dbPath,
          'skriva_lampiran',
          '${rows.first['mahasiswa_id']}',
          '$revisiId',
        ),
      ),
    );

    final filePath = p.normalize(
      p.absolute(storedPath),
    );

    if (!p.isWithin(folderAman, filePath)) {
      throw const FileServiceException(
        'Lokasi lampiran tidak diizinkan.',
      );
    }

    await _bukaDenganAplikasi(filePath);
  }

  // =====================================================
  // PRIVATE HELPERS
  // =====================================================

  Future<void> _pastikanFileMilikAkun(
    String path,
  ) async {
    final dir = await _documentDirectory();

    final folderPath = p.normalize(
      p.absolute(dir.path),
    );

    final targetPath = p.normalize(
      p.absolute(path),
    );

    if (!p.isWithin(folderPath, targetPath)) {
      throw const FileServiceException(
        'Dokumen ini bukan milik akun yang sedang login.',
      );
    }
  }

  Future<void> _bukaDenganAplikasi(
    String path,
  ) async {
    final file = File(path);

    if (!await file.exists()) {
      throw const FileServiceException(
        'File tidak ditemukan di perangkat.',
      );
    }

    final result = await OpenFilex.open(path);

    switch (result.type) {
      case ResultType.done:
        return;

      case ResultType.noAppToOpen:
        throw const FileServiceException(
          'Tidak ada aplikasi untuk membuka dokumen ini.',
        );

      case ResultType.fileNotFound:
        throw const FileServiceException(
          'File tidak ditemukan.',
        );

      default:
        throw const FileServiceException(
          'Dokumen tidak dapat dibuka.',
        );
    }
  }

  Future<StoredDocument> _toStoredDocument(
    File file,
  ) async {
    final stat = await file.stat();

    return StoredDocument(
      name: p.basename(file.path),
      path: file.path,
      sizeInBytes: stat.size,
      modified: stat.modified,
    );
  }
}
