import '../database/database_helper.dart';
import '../models/mahasiswa_model.dart';

class MahasiswaRepository {
  final DatabaseHelper _helper;
  MahasiswaRepository([DatabaseHelper? helper]) : _helper = helper ?? DatabaseHelper.instance;

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
    final rows = await db.query('mahasiswa',
        where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : MahasiswaModel.fromMap(rows.first);
  }

  Future<int> ubah(MahasiswaModel item) async {
    if (item.id == null) throw ArgumentError('ID diperlukan untuk update');
    final db = await _helper.database;
    return db.update('mahasiswa', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> hapus(int id) async {
    final db = await _helper.database;
    return db.delete('mahasiswa', where: 'id = ?', whereArgs: [id]);
  }
}
