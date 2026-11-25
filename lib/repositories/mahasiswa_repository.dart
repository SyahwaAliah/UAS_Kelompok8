
import 'package:sqflite/sqflite.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/mahasiswa_model.dart';

class MahasiswaRepository {
  final DatabaseHelper _helper;

  MahasiswaRepository([DatabaseHelper? helper])
      : _helper = helper ?? DatabaseHelper.instance;

  Future<int> tambah(MahasiswaModel item) async {
    final db = await _helper.database;
    return db.insert('mahasiswa', item.toMap());
  }

  Future<List<MahasiswaModel>> semua() async {
    final db = await _helper.database;
    final rows = await db.query('mahasiswa', orderBy: 'id ASC');
    return rows.map((row) => MahasiswaModel.fromMap(row)).toList();
  }

  Future<MahasiswaModel?> berdasarkanId(int id) async {
    final db = await _helper.database;
    final rows = await db.query(
      'mahasiswa',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : MahasiswaModel.fromMap(rows.first);
  }

  Future<int> ubah(MahasiswaModel item) async {
    if (item.id == null) {
      throw ArgumentError('ID diperlukan untuk update');
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

  Future<void> _siapkanAvatar() async {
    final db = await _helper.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS mahasiswa_avatar (
        id INTEGER PRIMARY KEY,
        avatar_index INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> ambilAvatar() async {
    await _siapkanAvatar();
    final db = await _helper.database;

    final rows = await db.query(
      'mahasiswa_avatar',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) return 0;

    final avatar = rows.first['avatar_index'] as int? ?? 0;
    return avatar >= 0 && avatar <= 6 ? avatar : 0;
  }

  Future<void> simpanAvatar(int avatarIndex) async {
    if (avatarIndex < 0 || avatarIndex > 6) {
      throw ArgumentError('Pilihan avatar tidak valid');
    }

    await _siapkanAvatar();
    final db = await _helper.database;

    await db.insert(
      'mahasiswa_avatar',
      {
        'id': 1,
        'avatar_index': avatarIndex,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> ambilFotoCustom() async {
    final db = await _helper.database;
    final rows = await db.query('app_settings',
        columns: ['value'], where: 'key = ?',
        whereArgs: ['mahasiswa_custom_photo'], limit: 1);
    if (rows.isEmpty) return null;
    final value = rows.first['value']?.toString() ?? '';
    return value.isEmpty ? null : value;
  }

  Future<void> simpanFotoCustom(String path) async {
    final db = await _helper.database;
    await db.insert('app_settings',
        {'key': 'mahasiswa_custom_photo', 'value': path},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

}
