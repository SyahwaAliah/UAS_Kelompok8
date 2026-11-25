import '../database/database_helper.dart';
import '../models/dokumen_model.dart';

class DokumenRepository {
  final DatabaseHelper _helper;
  DokumenRepository([DatabaseHelper? helper])
    : _helper = helper ?? DatabaseHelper.instance;

  Future<int> tambah(DokumenModel item) async {
    final db = await _helper.database;
    return db.insert('dokumen', item.toMap());
  }

  Future<List<DokumenModel>> semua() async {
    final db = await _helper.database;
    final rows = await db.query('dokumen', orderBy: 'tanggal_upload DESC');
    return rows.map((row) => DokumenModel.fromMap(row)).toList();
  }

  Future<DokumenModel?> berdasarkanId(int id) async {
    final db = await _helper.database;
    final rows = await db.query(
      'dokumen',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : DokumenModel.fromMap(rows.first);
  }

  Future<int> ubah(DokumenModel item) async {
    if (item.id == null) throw ArgumentError('ID diperlukan untuk update');
    final db = await _helper.database;
    return db.update(
      'dokumen',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> hapus(int id) async {
    final db = await _helper.database;
    return db.delete('dokumen', where: 'id = ?', whereArgs: [id]);
  }
}
