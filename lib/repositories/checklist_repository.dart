import '../database/database_helper.dart';
import '../models/checklist_model.dart';

class ChecklistRepository {
  final DatabaseHelper _helper;
  ChecklistRepository([DatabaseHelper? helper])
    : _helper = helper ?? DatabaseHelper.instance;

  Future<int> tambah(ChecklistModel item) async {
    final db = await _helper.database;
    return db.insert('checklist', item.toMap());
  }

  Future<List<ChecklistModel>> semua() async {
    final db = await _helper.database;
    final rows = await db.query('checklist', orderBy: 'id DESC');
    return rows.map((row) => ChecklistModel.fromMap(row)).toList();
  }

  Future<ChecklistModel?> berdasarkanId(int id) async {
    final db = await _helper.database;
    final rows = await db.query(
      'checklist',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : ChecklistModel.fromMap(rows.first);
  }

  Future<int> ubah(ChecklistModel item) async {
    if (item.id == null) throw ArgumentError('ID diperlukan untuk update');
    final db = await _helper.database;
    return db.update(
      'checklist',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> hapus(int id) async {
    final db = await _helper.database;
    return db.delete('checklist', where: 'id = ?', whereArgs: [id]);
  }
}
