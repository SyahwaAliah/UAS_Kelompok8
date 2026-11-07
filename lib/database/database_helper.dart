import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite lokal untuk data mahasiswa pada emulator Android.
class DatabaseHelper {
  DatabaseHelper._init();
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'bimbingan_skripsi.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE jadwal_bimbingan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanggal TEXT NOT NULL,
            jam TEXT NOT NULL,
            dosen TEXT NOT NULL,
            mode TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'Menunggu'
          )
        ''');
        await db.execute('''
          CREATE TABLE checklist (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            kegiatan TEXT NOT NULL,
            selesai INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE revisi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            catatan TEXT,
            status TEXT NOT NULL DEFAULT 'Belum Selesai'
          )
        ''');
      },
    );
  }

  Future<int> tambahJadwal({
    required String tanggal,
    required String jam,
    required String dosen,
    required String mode,
  }) async {
    final db = await database;
    return db.insert('jadwal_bimbingan', {
      'tanggal': tanggal,
      'jam': jam,
      'dosen': dosen,
      'mode': mode,
      'status': 'Menunggu',
    });
  }

  Future<List<Map<String, dynamic>>> ambilJadwal() async {
    final db = await database;
    return db.query('jadwal_bimbingan', orderBy: 'tanggal ASC, jam ASC');
  }

  Future<int> hapusJadwal(int id) async {
    final db = await database;
    return db.delete('jadwal_bimbingan', where: 'id = ?', whereArgs: [id]);
  }
}
