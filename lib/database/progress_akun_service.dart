import 'package:sqflite/sqflite.dart';
import 'package:test/database/auth_database.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/checklist_model.dart';

class ProgressAkunService {
  ProgressAkunService._();

  static final instance = ProgressAkunService._();

  static const tahapanAwal = [
    'Penentuan Topik',
    'Bab 1',
    'Bab 2',
    'Bab 3',
    'Seminar Proposal',
  ];

  Future<Database> get _db async {
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mahasiswa_id INTEGER NOT NULL,
        kegiatan TEXT NOT NULL,
        selesai INTEGER NOT NULL DEFAULT 0
      )
    ''');

    return db;
  }

  Future<int> get _mahasiswaId async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (akun == null || akun['role'] != 'mahasiswa') {
      throw StateError('Silakan login sebagai mahasiswa.');
    }

    return akun['id'] as int;
  }

  Future<List<ChecklistModel>> semua() async {
    final id = await _mahasiswaId;
    final db = await _db;

    var rows = await db.query(
      'skriva_progress',
      where: 'mahasiswa_id = ?',
      whereArgs: [id],
      orderBy: 'id ASC',
    );

    if (rows.isEmpty) {
      await db.transaction((txn) async {
        final jumlah = Sqflite.firstIntValue(
          await txn.rawQuery(
            'SELECT COUNT(*) FROM skriva_progress '
            'WHERE mahasiswa_id = ?',
            [id],
          ),
        ) ?? 0;

        if (jumlah == 0) {
          for (final kegiatan in tahapanAwal) {
            await txn.insert('skriva_progress', {
              'mahasiswa_id': id,
              'kegiatan': kegiatan,
              'selesai': 0,
            });
          }
        }
      });

      rows = await db.query(
        'skriva_progress',
        where: 'mahasiswa_id = ?',
        whereArgs: [id],
        orderBy: 'id ASC',
      );
    }

    return rows.map(ChecklistModel.fromMap).toList();
  }

  Future<void> ubahStatus(
    int itemId,
    bool selesai,
  ) async {
    final id = await _mahasiswaId;
    final db = await _db;

    final count = await db.update(
      'skriva_progress',
      {'selesai': selesai ? 1 : 0},
      where: 'id = ? AND mahasiswa_id = ?',
      whereArgs: [itemId, id],
    );

    if (count != 1) {
      throw StateError('Tahapan tidak ditemukan.');
    }
  }

  Future<void> tambah(String kegiatan) async {
    final id = await _mahasiswaId;
    final db = await _db;

    if (kegiatan.trim().isEmpty) {
      throw StateError('Nama tahapan wajib diisi.');
    }

    await db.insert('skriva_progress', {
      'mahasiswa_id': id,
      'kegiatan': kegiatan.trim(),
      'selesai': 0,
    });
  }

  Future<void> hapus(int itemId) async {
    final id = await _mahasiswaId;
    final db = await _db;

    await db.delete(
      'skriva_progress',
      where: 'id = ? AND mahasiswa_id = ?',
      whereArgs: [itemId, id],
    );
  }
}
