import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/mahasiswa_model.dart';

class MahasiswaRepository {
  final DatabaseHelper _helper;

  MahasiswaRepository([DatabaseHelper? helper])
      : _helper = helper ?? DatabaseHelper.instance;

  // =====================================================
  // DATA MAHASISWA
  // =====================================================

  Future<int> tambah(MahasiswaModel item) async {
    final db = await _helper.database;

    return db.insert(
      'mahasiswa',
      item.toMap(),
    );
  }

  Future<List<MahasiswaModel>> semua() async {
    final db = await _helper.database;

    final rows = await db.query(
      'mahasiswa',
      orderBy: 'id ASC',
    );

    return rows
        .map((row) => MahasiswaModel.fromMap(row))
        .toList();
  }

  Future<MahasiswaModel?> berdasarkanId(int id) async {
    final db = await _helper.database;

    final rows = await db.query(
      'mahasiswa',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return MahasiswaModel.fromMap(rows.first);
  }

  Future<int> ubah(MahasiswaModel item) async {
    if (item.id == null) {
      throw ArgumentError(
        'ID mahasiswa diperlukan untuk update.',
      );
    }

    final db = await _helper.database;

    return db.update(
      'mahasiswa',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> hapus(int id) async {
    final db = await _helper.database;

    return db.delete(
      'mahasiswa',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =====================================================
  // AKUN YANG SEDANG LOGIN
  // =====================================================

  Future<int> _idAkunMahasiswa() async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (akun == null || akun['role'] != 'mahasiswa') {
      throw StateError(
        'Silakan login menggunakan akun mahasiswa.',
      );
    }

    return akun['id'] as int;
  }

  // =====================================================
  // AVATAR PER AKUN
  // =====================================================

  Future<void> _siapkanAvatarAkun() async {
    final db = await _helper.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_avatar_akun (
        akun_id INTEGER PRIMARY KEY,
        avatar_index INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> ambilAvatar() async {
    final akunId = await _idAkunMahasiswa();

    await _siapkanAvatarAkun();

    final db = await _helper.database;

    final rows = await db.query(
      'skriva_avatar_akun',
      columns: ['avatar_index'],
      where: 'akun_id = ?',
      whereArgs: [akunId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return 0;
    }

    final avatar =
        rows.first['avatar_index'] as int? ?? 0;

    if (avatar < 0 || avatar > 6) {
      return 0;
    }

    return avatar;
  }

  Future<void> simpanAvatar(int avatarIndex) async {
    if (avatarIndex < 0 || avatarIndex > 6) {
      throw ArgumentError(
        'Pilihan avatar tidak valid.',
      );
    }

    final akunId = await _idAkunMahasiswa();

    await _siapkanAvatarAkun();

    final db = await _helper.database;

    await db.insert(
      'skriva_avatar_akun',
      {
        'akun_id': akunId,
        'avatar_index': avatarIndex,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // =====================================================
  // FOTO CUSTOM PER AKUN
  // =====================================================

  Future<String?> ambilFotoCustom() async {
    final akunId = await _idAkunMahasiswa();

    final db = await _helper.database;

    final rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [
        'mahasiswa_custom_photo_$akunId',
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final lokasi =
        rows.first['value']?.toString() ?? '';

    if (lokasi.isEmpty) {
      return null;
    }

    final file = File(lokasi);

    if (!await file.exists()) {
      return null;
    }

    // Pastikan foto benar-benar berada di folder akun.
    final baseDir =
        await getApplicationDocumentsDirectory();

    final folder = p.normalize(
      p.absolute(
        p.join(
          baseDir.path,
          'foto_profil',
          'mahasiswa_$akunId',
        ),
      ),
    );

    final pathFoto = p.normalize(
      p.absolute(file.path),
    );

    if (!p.isWithin(folder, pathFoto)) {
      return null;
    }

    return file.path;
  }

  Future<void> simpanFotoCustom(String path) async {
    final akunId = await _idAkunMahasiswa();

    final sumber = File(path);

    if (!await sumber.exists()) {
      throw StateError(
        'Foto yang dipilih tidak ditemukan.',
      );
    }

    final ekstensi =
        p.extension(sumber.path).toLowerCase();

    const formatDidukung = [
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
    ];

    if (!formatDidukung.contains(ekstensi)) {
      throw StateError(
        'Format foto harus JPG, JPEG, PNG, atau WEBP.',
      );
    }

    final baseDir =
        await getApplicationDocumentsDirectory();

    final folder = Directory(
      p.join(
        baseDir.path,
        'foto_profil',
        'mahasiswa_$akunId',
      ),
    );

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final namaFile =
        'avatar_${DateTime.now().microsecondsSinceEpoch}$ekstensi';

    final tujuan = p.join(
      folder.path,
      namaFile,
    );

    final hasilSalin = await sumber.copy(tujuan);

    final db = await _helper.database;

    await db.insert(
      'app_settings',
      {
        'key': 'mahasiswa_custom_photo_$akunId',
        'value': hasilSalin.path,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
