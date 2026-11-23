import '../database/database_helper.dart';
import '../models/revisi_model.dart';

class RevisiRepository {
  final DatabaseHelper _helper;
  RevisiRepository([DatabaseHelper? helper]) : _helper = helper ?? DatabaseHelper.instance;

  Future<int> tambah(RevisiModel item) async {
    final db = await _helper.database;
    return db.insert('revisi', item.toMap());
  }

  Future<List<RevisiModel>> semua() async {
    final db = await _helper.database;
    final rows = await db.query('revisi', orderBy: 'id DESC');
    return rows.map((row) => RevisiModel.fromMap(row)).toList();
  }

  Future<RevisiModel?> berdasarkanId(int id) async {
    final db = await _helper.database;
    final rows = await db.query('revisi',
        where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : RevisiModel.fromMap(rows.first);
  }

  Future<int> ubah(RevisiModel item) async {
    if (item.id == null) throw ArgumentError('ID diperlukan untuk update');
    final db = await _helper.database;
    return db.update('revisi', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> hapus(int id) async {
    final db = await _helper.database;
    return db.delete('revisi', where: 'id = ?', whereArgs: [id]);
  }
}
