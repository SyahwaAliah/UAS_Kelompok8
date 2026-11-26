import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:test/database/auth_database.dart';

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

  /// Ekstensi file huruf besar, contoh: PDF
  String get extension => p.extension(path).replaceFirst('.', '').toUpperCase();

  /// Nama tanpa ekstensi, cocok untuk title card
  String get title => p.basenameWithoutExtension(path);

  /// Ukuran terformat, contoh: 2.4 MB
  String get formattedSize {
    const kb = 1024;
    const mb = kb * 1024;

    if (sizeInBytes >= mb) {
      return '${(sizeInBytes / mb).toStringAsFixed(1)} MB';
    }
    if (sizeInBytes >= kb) {
      return '${(sizeInBytes / kb).toStringAsFixed(1)} KB';
    }
    return '$sizeInBytes B';
  }

  /// Subtitle siap pakai, contoh: PDF • 2.4 MB
  String get subtitle => '$extension • $formattedSize';
}

/// Error dengan pesan Bahasa Indonesia yang bisa langsung
/// ditampilkan lewat SnackBar.
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

  static const List<String> allowedExtensions = ['pdf', 'doc', 'docx'];

  // ---------------------------------------------------------------
  // FOLDER
  // ---------------------------------------------------------------

  Future<Directory> _documentDirectory() async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (akun == null) {
      throw const FileServiceException('Silakan login terlebih dahulu.');
    }

    final id = akun['id'] as int;
    final role = akun['role']?.toString() ?? '';

    if (role != 'mahasiswa' && role != 'dosen') {
      throw const FileServiceException('Akun tidak memiliki akses dokumen.');
    }

    final baseDir = await getApplicationDocumentsDirectory();

    // Setiap akun menggunakan folder sendiri.
    final dir = Directory(p.join(baseDir.path, _folderName, '${role}_$id'));

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  // ---------------------------------------------------------------
  // PILIH FILE
  // ---------------------------------------------------------------

  /// Membuka file picker. Mengembalikan null jika dibatalkan.
  Future<File?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return null;
      }

      return File(result.files.single.path!);
    } catch (_) {
      throw const FileServiceException(
        'Gagal memilih dokumen. Silakan coba lagi.',
      );
    }
  }

  // ---------------------------------------------------------------
  // SIMPAN LOKAL
  // ---------------------------------------------------------------

  /// Menyalin file ke folder lokal aplikasi.
  /// Jika nama sudah ada, otomatis diberi akhiran (1), (2), dst.
  Future<StoredDocument> saveLocally(File source) async {
    try {
      final dir = await _documentDirectory();
      final name = p.basenameWithoutExtension(source.path);
      final ext = p.extension(source.path);

      var targetPath = p.join(dir.path, '$name$ext');
      var counter = 1;

      while (await File(targetPath).exists()) {
        targetPath = p.join(dir.path, '$name ($counter)$ext');
        counter++;
      }

      final saved = await source.copy(targetPath);

      return _toStoredDocument(saved);
    } catch (_) {
      throw const FileServiceException(
        'Gagal menyimpan dokumen ke penyimpanan lokal.',
      );
    }
  }

  /// Gabungan pilih + simpan. Mengembalikan null jika dibatalkan.
  Future<StoredDocument?> pickAndSave() async {
    final file = await pickDocument();

    if (file == null) return null;

    return saveLocally(file);
  }

  // ---------------------------------------------------------------
  // DAFTAR DOKUMEN
  // ---------------------------------------------------------------

  /// Mengambil semua dokumen tersimpan, terbaru di atas.
  Future<List<StoredDocument>> getSavedDocuments() async {
    try {
      final dir = await _documentDirectory();

      final entities = await dir.list().toList();

      final documents = <StoredDocument>[];

      for (final entity in entities) {
        if (entity is File) {
          documents.add(await _toStoredDocument(entity));
        }
      }

      documents.sort((a, b) => b.modified.compareTo(a.modified));

      return documents;
    } catch (_) {
      throw const FileServiceException('Gagal mengambil daftar dokumen.');
    }
  }

  // ---------------------------------------------------------------
  // BUKA & HAPUS
  // ---------------------------------------------------------------

  /// Membuka dokumen dengan aplikasi bawaan perangkat.
  Future<void> openDocument(String path) async {

    await _pastikanFileMilikAkun(path);
    if (!await File(path).exists()) {
      throw const FileServiceException('File tidak ditemukan di perangkat.');
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
        throw const FileServiceException('File tidak ditemukan di perangkat.');
      default:
        throw const FileServiceException('Dokumen tidak dapat dibuka.');
    }
  }

  Future<void> deleteDocument(String path) async {
    await _pastikanFileMilikAkun(path);
    
    try {
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      throw const FileServiceException('Gagal menghapus dokumen.');
    }
  }

  // ---------------------------------------------------------------
  // HELPER
  // ---------------------------------------------------------------

  Future<StoredDocument> _toStoredDocument(File file) async {
    final stat = await file.stat();

    return StoredDocument(
      name: p.basename(file.path),
      path: file.path,
      sizeInBytes: stat.size,
      modified: stat.modified,
    );
  }


Future<void> _pastikanFileMilikAkun(String path) async {
  final folder = await _documentDirectory();

  final folderPath = p.normalize(
    p.absolute(folder.path),
  );

  final filePath = p.normalize(
    p.absolute(path),
  );

  if (!p.isWithin(folderPath, filePath)) {
    throw const FileServiceException(
      'Dokumen ini bukan milik akun yang sedang login.',
    );
  }
}

}
