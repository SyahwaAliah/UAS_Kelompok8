import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      version: 4,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE mahasiswa (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            nim TEXT NOT NULL UNIQUE,
            email TEXT NOT NULL DEFAULT '',
            prodi TEXT NOT NULL DEFAULT '',
            semester INTEGER NOT NULL DEFAULT 1,
            judul_skripsi TEXT NOT NULL DEFAULT ''
          )
        ''');

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
            status TEXT NOT NULL DEFAULT 'Belum Selesai',
            deadline TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE dokumen (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mahasiswa_id INTEGER,
            nama_file TEXT NOT NULL,
            path_file TEXT NOT NULL,
            kategori TEXT NOT NULL DEFAULT 'Skripsi',
            tanggal_upload TEXT NOT NULL,
            FOREIGN KEY (mahasiswa_id)
              REFERENCES mahasiswa(id) ON DELETE SET NULL
          )
        ''');

        await _createNotificationsTable(db);
        await _createNewTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS mahasiswa (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nama TEXT NOT NULL,
              nim TEXT NOT NULL UNIQUE,
              email TEXT NOT NULL DEFAULT '',
              prodi TEXT NOT NULL DEFAULT '',
              semester INTEGER NOT NULL DEFAULT 1,
              judul_skripsi TEXT NOT NULL DEFAULT ''
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS dokumen (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              mahasiswa_id INTEGER,
              nama_file TEXT NOT NULL,
              path_file TEXT NOT NULL,
              kategori TEXT NOT NULL DEFAULT 'Skripsi',
              tanggal_upload TEXT NOT NULL,
              FOREIGN KEY (mahasiswa_id)
                REFERENCES mahasiswa(id) ON DELETE SET NULL
            )
          ''');

          await db.execute('ALTER TABLE revisi ADD COLUMN deadline TEXT');
        }

        if (oldVersion < 3) {
          await _createNotificationsTable(db);
        }

        if (oldVersion < 4) {
          await _createNewTables(db);
        }
      },
    );
  }

  Future<void> _createNewTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS catatan_pribadi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul TEXT NOT NULL DEFAULT '',
        isi TEXT NOT NULL DEFAULT '',
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dosen TEXT NOT NULL,
        pengirim TEXT NOT NULL,
        pesan TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS mahasiswa_avatar (
        id INTEGER PRIMARY KEY,
        avatar_index INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Tujuh dosen contoh untuk keperluan demo UAS.
  // INSERT OR IGNORE memastikan edit pengguna tidak tertimpa saat aplikasi dibuka lagi.
  Future<void> _siapkanDosen() async {
    final db = await database;
    await db.execute('''CREATE TABLE IF NOT EXISTS profil_dosen (
      id INTEGER PRIMARY KEY,
      nama TEXT NOT NULL, nidn TEXT NOT NULL DEFAULT '',
      fakultas TEXT NOT NULL DEFAULT '', prodi TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '', telepon TEXT NOT NULL DEFAULT '',
      ruangan TEXT NOT NULL DEFAULT '', keahlian TEXT NOT NULL DEFAULT ''
    )''');

    final dataAwal = <Map<String, Object?>>[
      {
        'id': 1,
        'nama': 'Dr. Budi Santoso, M.Kom.',
        'nidn': '',
        'fakultas': 'Fakultas Ilmu Komputer',
        'prodi': 'Sistem Informasi',
        'email': 'budi.santoso@kampus.ac.id',
        'telepon': '',
        'ruangan': 'Gedung A - Ruang 203',
        'keahlian':
            'Sistem Informasi, Mobile Application, UI/UX, Data Management',
      },
      {
        'id': 2,
        'nama': 'Dr. Siti Rahmawati, M.Kom.',
        'nidn': '',
        'fakultas': 'Fakultas Ilmu Komputer',
        'prodi': 'Sistem Informasi',
        'email': '',
        'telepon': '',
        'ruangan': 'Gedung A - Ruang 204',
        'keahlian': 'Analisis Sistem, Basis Data, Sistem Informasi',
      },
      {
        'id': 3,
        'nama': 'Andi Pratama, S.Kom., M.T.',
        'nidn': '',
        'fakultas': 'Fakultas Ilmu Komputer',
        'prodi': 'Teknik Informatika',
        'email': '',
        'telepon': '',
        'ruangan': 'Gedung A - Ruang 205',
        'keahlian': 'Pemrograman Mobile, Rekayasa Perangkat Lunak',
      },
      {
        'id': 4,
        'nama': 'Dr. Maya Puspita, M.Kom.',
        'nidn': '',
        'fakultas': 'Fakultas Ilmu Komputer',
        'prodi': 'Sistem Informasi',
        'email': '',
        'telepon': '',
        'ruangan': 'Gedung B - Ruang 201',
        'keahlian': 'UI/UX, Interaksi Manusia dan Komputer',
      },
      {
        'id': 5,
        'nama': 'Rizky Firmansyah, S.Kom., M.Kom.',
        'nidn': '',
        'fakultas': 'Fakultas Ilmu Komputer',
        'prodi': 'Teknik Informatika',
        'email': '',
        'telepon': '',
        'ruangan': 'Gedung B - Ruang 202',
        'keahlian': 'Keamanan Informasi, Jaringan Komputer',
      },
      {
        'id': 6,
        'nama': 'Dr. Nurul Hidayah, M.Kom.',
        'nidn': '',
        'fakultas': 'Fakultas Ilmu Komputer',
        'prodi': 'Sistem Informasi',
        'email': '',
        'telepon': '',
        'ruangan': 'Gedung B - Ruang 203',
        'keahlian': 'Data Mining, Machine Learning, Kecerdasan Buatan',
      },
      {
        'id': 7,
        'nama': 'Dimas Saputra, S.T., M.Kom.',
        'nidn': '',
        'fakultas': 'Fakultas Ilmu Komputer',
        'prodi': 'Sistem Informasi',
        'email': '',
        'telepon': '',
        'ruangan': 'Gedung B - Ruang 204',
        'keahlian': 'Manajemen Proyek TI, Tata Kelola TI',
      },
    ];

    for (final dosen in dataAwal) {
      await db.insert(
        'profil_dosen',
        dosen,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<List<Map<String, Object?>>> ambilDaftarDosen() async {
    await _siapkanDosen();
    final db = await database;
    return db.query('profil_dosen', orderBy: 'id ASC');
  }

  Future<Map<String, Object?>> ambilProfilDosen({int id = 1}) async {
    await _siapkanDosen();
    final db = await database;
    final rows = await db.query(
      'profil_dosen',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) throw StateError('Profil dosen tidak ditemukan');
    return rows.first;
  }

  Future<void> simpanProfilDosen(
    Map<String, Object?> data, {
    int id = 1,
  }) async {
    await _siapkanDosen();
    final db = await database;
    final jumlah = await db.update(
      'profil_dosen',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (jumlah == 0) throw StateError('Profil dosen tidak ditemukan');
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

  Future<List<Map<String, Object?>>> ambilJadwal() async {
    final db = await database;

    return db.query('jadwal_bimbingan', orderBy: 'tanggal ASC, jam ASC');
  }

  Future<int> hapusJadwal(int id) async {
    final db = await database;

    return db.delete('jadwal_bimbingan', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> ubahStatusJadwal(int id, String status) async {
    if (!['Menunggu', 'Terjadwal', 'Selesai'].contains(status)) {
      throw ArgumentError('Status jadwal tidak valid');
    }

    final db = await database;

    return db.update(
      'jadwal_bimbingan',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, Object?>>> ambilCatatan() async {
    final db = await database;

    return db.query('catatan_pribadi', orderBy: 'updated_at DESC, id DESC');
  }

  Future<int> simpanCatatan({
    int? id,
    required String judul,
    required String isi,
  }) async {
    final db = await database;

    final data = {
      'judul': judul,
      'isi': isi,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (id == null) {
      return db.insert('catatan_pribadi', data);
    }

    return db.update('catatan_pribadi', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> hapusCatatan(int id) async {
    final db = await database;

    return db.delete('catatan_pribadi', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> simpanPesanChat({
    required String dosen,
    required String pengirim,
    required String pesan,
  }) async {
    final db = await database;

    return db.insert('chat_messages', {
      'dosen': dosen,
      'pengirim': pengirim,
      'pesan': pesan,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, Object?>>> ambilPesanChat({
    required String dosen,
  }) async {
    final db = await database;

    return db.query(
      'chat_messages',
      where: 'dosen = ?',
      whereArgs: [dosen],
      orderBy: 'created_at ASC, id ASC',
    );
  }

  Future<List<Map<String, Object?>>> ambilPesanTerakhir() async {
    final db = await database;

    return db.query(
      'chat_messages',
      orderBy: 'created_at DESC, id DESC',
      limit: 1,
    );
  }

  Future<void> siapkanChecklistAwal() async {
    final db = await database;

    await db.transaction((txn) async {
      final initialized = await txn.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: ['checklist_initialized'],
        limit: 1,
      );

      if (initialized.isNotEmpty) return;

      final count =
          Sqflite.firstIntValue(
            await txn.rawQuery('SELECT COUNT(*) FROM checklist'),
          ) ??
          0;

      if (count == 0) {
        final tahapan = [
          'Penentuan Topik',
          'Bab 1',
          'Bab 2',
          'Bab 3',
          'Seminar Proposal',
        ];

        for (final tahap in tahapan) {
          await txn.insert('checklist', {'kegiatan': tahap, 'selesai': 0});
        }
      }

      await txn.insert('app_settings', {
        'key': 'checklist_initialized',
        'value': '1',
      });
    });
  }

  Future<void> _createNotificationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        time TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> simpanNotifikasi({
    required String type,
    required String title,
    required String description,
    required String time,
  }) async {
    final db = await database;

    return db.insert('notifications', {
      'type': type,
      'title': title,
      'description': description,
      'time': time,
      'is_read': 0,
    });
  }

  Future<List<Map<String, Object?>>> ambilNotifikasi() async {
    final db = await database;

    return db.query('notifications', orderBy: 'time DESC, id DESC');
  }

  Future<void> tandaiNotifikasiDibaca(int id) async {
    final db = await database;

    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> tandaiSemuaNotifikasiDibaca() async {
    final db = await database;

    await db.update('notifications', {'is_read': 1});
  }

  Future<void> hapusSemuaNotifikasi() async {
    final db = await database;
    await db.delete('notifications');
  }

  Future<void> close() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
