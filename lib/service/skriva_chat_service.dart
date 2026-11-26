import 'package:sqflite/sqflite.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/database/auth_database.dart';

class SkrivaChatService {
  SkrivaChatService._();

  static final instance = SkrivaChatService._();

  Future<Database> get _db async {
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_chat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mahasiswa_id INTEGER NOT NULL,
        dosen_id INTEGER NOT NULL,
        pengirim_id INTEGER NOT NULL,
        pesan TEXT NOT NULL,
        dibuat_pada TEXT NOT NULL,
        FOREIGN KEY(mahasiswa_id) REFERENCES skriva_akun(id),
        FOREIGN KEY(dosen_id) REFERENCES skriva_akun(id),
        FOREIGN KEY(pengirim_id) REFERENCES skriva_akun(id)
      )
    ''');

    return db;
  }

  Future<Map<String, Object?>> _akun() async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (akun == null) {
      throw StateError('Silakan login kembali.');
    }

    return akun;
  }

  Future<void> _validasiPasangan(
    Database db,
    int mahasiswaId,
    int dosenId,
    int pengirimId,
  ) async {
    if (pengirimId != mahasiswaId && pengirimId != dosenId) {
      throw StateError('Akun tidak memiliki akses ke percakapan ini.');
    }

    final rows = await db.rawQuery('''
      SELECT 1
      FROM skriva_pembimbing
      WHERE mahasiswa_id = ?
        AND dosen_id = ?
      LIMIT 1
    ''', [mahasiswaId, dosenId]);

    if (rows.isEmpty) {
      throw StateError('Dosen bukan pembimbing mahasiswa ini.');
    }
  }

  Future<List<Map<String, Object?>>> pesan({
    required int mahasiswaId,
    required int dosenId,
  }) async {
    final akun = await _akun();
    final db = await _db;

    await _validasiPasangan(
      db,
      mahasiswaId,
      dosenId,
      akun['id'] as int,
    );

    return db.rawQuery('''
      SELECT c.*, a.nama AS nama_pengirim
      FROM skriva_chat c
      JOIN skriva_akun a ON a.id = c.pengirim_id
      WHERE c.mahasiswa_id = ?
        AND c.dosen_id = ?
      ORDER BY c.dibuat_pada ASC, c.id ASC
    ''', [mahasiswaId, dosenId]);
  }

  Future<void> kirim({
    required int mahasiswaId,
    required int dosenId,
    required String isi,
  }) async {
    final text = isi.trim();
    if (text.isEmpty) return;

    final akun = await _akun();
    final pengirimId = akun['id'] as int;
    final db = await _db;

    await _validasiPasangan(
      db,
      mahasiswaId,
      dosenId,
      pengirimId,
    );

    await db.insert('skriva_chat', {
      'mahasiswa_id': mahasiswaId,
      'dosen_id': dosenId,
      'pengirim_id': pengirimId,
      'pesan': text,
      'dibuat_pada': DateTime.now().toIso8601String(),
    });
  }

  Future<String> pesanTerakhir({
    required int mahasiswaId,
    required int dosenId,
  }) async {
    final rows = await pesan(
      mahasiswaId: mahasiswaId,
      dosenId: dosenId,
    );

    if (rows.isEmpty) return 'Belum ada percakapan.';
    return rows.last['pesan']?.toString() ?? '';
  }
}
