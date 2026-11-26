import 'package:crypto/crypto.dart';

import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:test/database/database_helper.dart';

class AuthDatabase {
  AuthDatabase._();

  static final AuthDatabase instance = AuthDatabase._();

  Future<Database> get _db async {
    final db = await DatabaseHelper.instance.database;
    await _siapkanTabel(db);
    return db;
  }

  Future<void> _siapkanTabel(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_akun (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        role TEXT NOT NULL,
        nomor_induk TEXT NOT NULL,
        password_hash TEXT,
        aktif INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_pembimbing (
        mahasiswa_id INTEGER NOT NULL,
        dosen_id INTEGER NOT NULL,
        urutan INTEGER NOT NULL,
        PRIMARY KEY (mahasiswa_id, urutan),
        FOREIGN KEY (mahasiswa_id) REFERENCES skriva_akun(id),
        FOREIGN KEY (dosen_id) REFERENCES skriva_akun(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_sesi (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        akun_id INTEGER NOT NULL
      )
    ''');

    await _seed(db);
  }

  String hashPassword(String password, String email) {
    // Hanya untuk prototipe offline UAS.
    final input = '$email:${password.trim()}';
    return sha256.convert(utf8.encode(input)).toString();
  }

  Future<void> _seed(Database db) async {
    // Akun demo. Ganti dengan data kampus yang disetujui.
    final akun = <Map<String, String>>[
      {
        'nama': 'Mahasiswa Demo 1',
        'email': 'mahasiswa1@skriva.demo',
        'role': 'mahasiswa',
        'nomor': '20260001',
      },
      {
        'nama': 'Mahasiswa Demo 2',
        'email': 'mahasiswa2@skriva.demo',
        'role': 'mahasiswa',
        'nomor': '20260002',
      },
      {
        'nama': 'Dr. Budi Santoso, M.Kom.',
        'email': 'budi@skriva.demo',
        'role': 'dosen',
        'nomor': 'D001',
      },
      {
        'nama': 'Dr. Siti Rahmawati, M.Kom.',
        'email': 'siti@skriva.demo',
        'role': 'dosen',
        'nomor': 'D002',
      },
      {
        'nama': 'Andi Pratama, S.Kom., M.T.',
        'email': 'andi@skriva.demo',
        'role': 'dosen',
        'nomor': 'D003',
      },
      {
        'nama': 'Dr. Maya Puspita, M.Kom.',
        'email': 'maya@skriva.demo',
        'role': 'dosen',
        'nomor': 'D004',
      },
      {
        'nama': 'Rizky Firmansyah, S.Kom., M.Kom.',
        'email': 'rizky@skriva.demo',
        'role': 'dosen',
        'nomor': 'D005',
      },
      {
        'nama': 'Dr. Nurul Hidayah, M.Kom.',
        'email': 'nurul@skriva.demo',
        'role': 'dosen',
        'nomor': 'D006',
      },
      {
        'nama': 'Dimas Saputra, S.T., M.Kom.',
        'email': 'dimas@skriva.demo',
        'role': 'dosen',
        'nomor': 'D007',
      },
    ];

    for (final item in akun) {
      await db.insert('skriva_akun', {
        'nama': item['nama'],
        'email': item['email'],
        'role': item['role'],
        'nomor_induk': item['nomor'],
        'aktif': 0,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    Future<int> idAkun(String email) async {
      final rows = await db.query(
        'skriva_akun',
        columns: ['id'],
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );
      return rows.first['id'] as int;
    }

    final m1 = await idAkun('mahasiswa1@skriva.demo');
    final m2 = await idAkun('mahasiswa2@skriva.demo');
    final budi = await idAkun('budi@skriva.demo');
    final siti = await idAkun('siti@skriva.demo');
    final andi = await idAkun('andi@skriva.demo');
    final maya = await idAkun('maya@skriva.demo');

    final relasi = [
      [m1, budi, 1],
      [m1, siti, 2],
      [m2, andi, 1],
      [m2, maya, 2],
    ];

    for (final r in relasi) {
      await db.insert('skriva_pembimbing', {
        'mahasiswa_id': r[0],
        'dosen_id': r[1],
        'urutan': r[2],
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<Map<String, Object?>?> cariEmail(String email) async {
    final db = await _db;
    final rows = await db.query(
      'skriva_akun',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<String?> aktivasi({
    required String email,
    required String nomorInduk,
    required String password,
  }) async {
    final akun = await cariEmail(email);

    if (akun == null) {
      return 'Email tidak terdaftar. Hubungi admin kampus.';
    }

    if (akun['nomor_induk'].toString() != nomorInduk.trim()) {
      return 'NIM atau NIDN/ID dosen tidak sesuai.';
    }

    if (akun['aktif'] == 1) {
      return 'Akun sudah aktif. Silakan login.';
    }

    if (password.length < 8) {
      return 'Password minimal 8 karakter.';
    }

    final db = await _db;
    final normalizedEmail = email.trim().toLowerCase();

    await db.update(
      'skriva_akun',
      {'password_hash': hashPassword(password, normalizedEmail), 'aktif': 1},
      where: 'id = ?',
      whereArgs: [akun['id']],
    );

    return null;
  }

  Future<Map<String, Object?>?> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final akun = await cariEmail(normalizedEmail);

    if (akun == null || akun['aktif'] != 1) return null;

    final hash = hashPassword(password, normalizedEmail);
    if (akun['password_hash'] != hash) return null;

    final db = await _db;
    await db.insert('skriva_sesi', {
      'id': 1,
      'akun_id': akun['id'],
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    return akun;
  }

  Future<Map<String, Object?>?> sesiAktif() async {
    final db = await _db;

    final rows = await db.rawQuery('''
      SELECT a.*
      FROM skriva_sesi s
      JOIN skriva_akun a ON a.id = s.akun_id
      WHERE s.id = 1 AND a.aktif = 1
      LIMIT 1
    ''');

    return rows.isEmpty ? null : rows.first;
  }

  Future<void> logout() async {
    final db = await _db;
    await db.delete('skriva_sesi', where: 'id = 1');
  }

  Future<List<Map<String, Object?>>> pembimbing(int mahasiswaId) async {
    final db = await _db;

    return db.rawQuery(
      '''
      SELECT
        a.id,
        a.nama,
        a.email,
        a.nomor_induk,
        p.urutan
      FROM skriva_pembimbing p
      JOIN skriva_akun a ON a.id = p.dosen_id
      WHERE p.mahasiswa_id = ?
      ORDER BY p.urutan ASC
    ''',
      [mahasiswaId],
    );
  }

  Future<List<Map<String, Object?>>> mahasiswaBimbingan(int dosenId) async {
    final db = await _db;

    return db.rawQuery(
      '''
      SELECT
        a.id,
        a.nama,
        a.email,
        a.nomor_induk,
        p.urutan
      FROM skriva_pembimbing p
      JOIN skriva_akun a ON a.id = p.mahasiswa_id
      WHERE p.dosen_id = ?
      ORDER BY a.nama ASC
    ''',
      [dosenId],
    );
  }
}
