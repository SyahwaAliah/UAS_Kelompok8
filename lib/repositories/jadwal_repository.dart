import '../database/database_helper.dart';
import '../models/jadwal_model.dart';

class JadwalRepository {
  final DatabaseHelper _helper;
  JadwalRepository([DatabaseHelper? helper]) : _helper = helper ?? DatabaseHelper.instance;

  Future<int> tambah(JadwalModel item) async {
    final db = await _helper.database;
    return db.insert('jadwal_bimbingan', item.toMap());
  }

  Future<List<JadwalModel>> semua() async {
    final db = await _helper.database;
    final rows = await db.query('jadwal_bimbingan', orderBy: 'tanggal ASC, jam ASC');
    return rows.map((row) => JadwalModel.fromMap(row)).toList();
  }

  Future<JadwalModel?> berdasarkanId(int id) async {
    final db = await _helper.database;
    final rows = await db.query('jadwal_bimbingan',
        where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : JadwalModel.fromMap(rows.first);
  }

  Future<int> ubah(JadwalModel item) async {
    if (item.id == null) throw ArgumentError('ID diperlukan untuk update');
    final db = await _helper.database;
    return db.update('jadwal_bimbingan', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> hapus(int id) async {
    final db = await _helper.database;
    return db.delete('jadwal_bimbingan', where: 'id = ?', whereArgs: [id]);
  }
}
