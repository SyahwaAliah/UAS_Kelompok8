import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database lokal Android. Versi 2 mempertahankan data versi 1.
class DatabaseHelper {
  DatabaseHelper._init();
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final filePath = join(dbPath, 'bimbingan_skripsi.db');
    return openDatabase(
      filePath,
      version: 2,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE mahasiswa (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          nim TEXT NOT NULL UNIQUE,
          email TEXT NOT NULL DEFAULT '',
          prodi TEXT NOT NULL DEFAULT '',
          semester INTEGER NOT NULL DEFAULT 1,
          judul_skripsi TEXT NOT NULL DEFAULT ''
        )''');
        await db.execute('''CREATE TABLE jadwal_bimbingan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tanggal TEXT NOT NULL,
          jam TEXT NOT NULL,
          dosen TEXT NOT NULL,
          mode TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'Menunggu'
        )''');
        await db.execute('''CREATE TABLE checklist (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          kegiatan TEXT NOT NULL,
          selesai INTEGER NOT NULL DEFAULT 0
        )''');
        await db.execute('''CREATE TABLE revisi (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          judul TEXT NOT NULL,
          catatan TEXT,
          status TEXT NOT NULL DEFAULT 'Belum Selesai',
          deadline TEXT
        )''');
        await db.execute('''CREATE TABLE dokumen (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mahasiswa_id INTEGER,
          nama_file TEXT NOT NULL,
          path_file TEXT NOT NULL,
          kategori TEXT NOT NULL DEFAULT 'Skripsi',
          tanggal_upload TEXT NOT NULL,
          FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(id) ON DELETE SET NULL
        )''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''CREATE TABLE IF NOT EXISTS mahasiswa (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            nim TEXT NOT NULL UNIQUE,
            email TEXT NOT NULL DEFAULT '',
            prodi TEXT NOT NULL DEFAULT '',
            semester INTEGER NOT NULL DEFAULT 1,
            judul_skripsi TEXT NOT NULL DEFAULT ''
          )''');
          await db.execute('''CREATE TABLE IF NOT EXISTS dokumen (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mahasiswa_id INTEGER,
            nama_file TEXT NOT NULL,
            path_file TEXT NOT NULL,
            kategori TEXT NOT NULL DEFAULT 'Skripsi',
            tanggal_upload TEXT NOT NULL,
            FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(id) ON DELETE SET NULL
          )''');
          await db.execute('ALTER TABLE revisi ADD COLUMN deadline TEXT');
        }
      },
    );
  }

  // Kompatibilitas dengan booking_jadwal_page.dart lama.
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

  Future<List<Map<String, Object?>>> ambilJadwal() async {
    final db = await database;
    return db.query('jadwal_bimbingan', orderBy: 'tanggal ASC, jam ASC');
  }

  Future<int> hapusJadwal(int id) async {
    final db = await database;
    return db.delete('jadwal_bimbingan', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
