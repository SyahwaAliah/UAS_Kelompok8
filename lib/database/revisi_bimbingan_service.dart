import 'package:sqflite/sqflite.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/database/auth_database.dart';
import 'package:test/service/notification_service.dart';

class RevisiBimbinganService {
  RevisiBimbinganService._();

  static final instance = RevisiBimbinganService._();

  Future<Database> get _db async {
    await AuthDatabase.instance.sesiAktif();
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_revisi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mahasiswa_id INTEGER NOT NULL,
        dosen_id INTEGER NOT NULL,
        judul TEXT NOT NULL,
        catatan TEXT NOT NULL,
        deadline TEXT,
        status TEXT NOT NULL DEFAULT 'Belum Dikerjakan',
        tanggapan_mahasiswa TEXT NOT NULL DEFAULT '',
        umpan_balik_dosen TEXT NOT NULL DEFAULT '',
        dibuat_pada TEXT NOT NULL,
        diperbarui_pada TEXT NOT NULL,
        FOREIGN KEY(mahasiswa_id) REFERENCES skriva_akun(id),
        FOREIGN KEY(dosen_id) REFERENCES skriva_akun(id)
      )
    ''');

    return db;
  }

  Future<Map<String, Object?>> _akun(String role) async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (akun == null || akun['role'] != role) {
      throw StateError('Akses hanya untuk akun $role.');
    }
    return akun;
  }

  Future<bool> _pasangan(
    Database db,
    int mahasiswaId,
    int dosenId,
  ) async {
    final rows = await db.query(
      'skriva_pembimbing',
      columns: ['mahasiswa_id'],
      where: 'mahasiswa_id = ? AND dosen_id = ?',
      whereArgs: [mahasiswaId, dosenId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<List<Map<String, Object?>>> semua() async {
    final akun = await AuthDatabase.instance.sesiAktif();
    if (akun == null) return [];

    final db = await _db;
    final id = akun['id'];
    final isDosen = akun['role'] == 'dosen';

    return db.rawQuery('''
      SELECT
        r.*,
        m.nama AS nama_mahasiswa,
        m.nomor_induk AS nim,
        d.nama AS nama_dosen
      FROM skriva_revisi r
      JOIN skriva_akun m ON m.id = r.mahasiswa_id
      JOIN skriva_akun d ON d.id = r.dosen_id
      JOIN skriva_pembimbing p
        ON p.mahasiswa_id = r.mahasiswa_id
       AND p.dosen_id = r.dosen_id
      WHERE ${isDosen ? 'r.dosen_id' : 'r.mahasiswa_id'} = ?
      ORDER BY r.diperbarui_pada DESC, r.id DESC
    ''', [id]);
  }

  Future<int> buat({
    required int mahasiswaId,
    required String judul,
    required String catatan,
    String? deadline,
  }) async {
    final dosen = await _akun('dosen');
    final dosenId = dosen['id'] as int;
    final db = await _db;

    if (!await _pasangan(db, mahasiswaId, dosenId)) {
      throw StateError('Mahasiswa bukan bimbinganmu.');
    }
    if (judul.trim().isEmpty || catatan.trim().isEmpty) {
      throw StateError('Judul dan instruksi revisi harus diisi.');
    }

    final sekarang = DateTime.now().toIso8601String();

    final id = await db.insert('skriva_revisi', {
      'mahasiswa_id': mahasiswaId,
      'dosen_id': dosenId,
      'judul': judul.trim(),
      'catatan': catatan.trim(),
      'deadline': deadline,
      'status': 'Belum Dikerjakan',
      'tanggapan_mahasiswa': '',
      'umpan_balik_dosen': '',
      'dibuat_pada': sekarang,
      'diperbarui_pada': sekarang,
    });

    // Notifikasi ini bersifat pendamping, bukan syarat
    // agar transaksi revisi berhasil disimpan.
    try {
      await NotificationService.instance.kirimKeAkun(
        penerimaId: mahasiswaId,
        judul: 'Revisi Baru dari Dosen',
        pesan:
            '${dosen['nama']} memberikan revisi: ${judul.trim()}.',
        tipe: 'revisi',
        referensiId: id,
      );
    } catch (_) {
      // Revisi tetap tersimpan meskipun notifikasi gagal.
    }

    return id;
  }

  Future<void> mulai(int revisiId) async {
    final mahasiswa = await _akun('mahasiswa');
    final db = await _db;

    final count = await db.update(
      'skriva_revisi',
      {
        'status': 'Dalam Pengerjaan',
        'diperbarui_pada': DateTime.now().toIso8601String(),
      },
      where: '''
        id = ?
        AND mahasiswa_id = ?
        AND status IN ('Belum Dikerjakan', 'Perlu Perbaikan')
      ''',
      whereArgs: [revisiId, mahasiswa['id']],
    );

    if (count != 1) {
      throw StateError('Revisi tidak dapat mulai dikerjakan.');
    }
  }

  Future<void> kirimHasil(
    int revisiId,
    String tanggapan,
  ) async {
    final mahasiswa = await _akun('mahasiswa');
    if (tanggapan.trim().isEmpty) {
      throw StateError('Isi hasil perbaikan terlebih dahulu.');
    }

    final db = await _db;

    final rows = await db.query(
      'skriva_revisi',
      where: 'id = ? AND mahasiswa_id = ?',
      whereArgs: [revisiId, mahasiswa['id']],
      limit: 1,
    );

    if (rows.isEmpty) throw StateError('Revisi tidak ditemukan.');

    final revisi = rows.first;
    final status = revisi['status'];

    if (status != 'Dalam Pengerjaan' &&
        status != 'Perlu Perbaikan') {
      throw StateError('Status revisi tidak mengizinkan pengiriman.');
    }

    final updated = await db.update(
      'skriva_revisi',
      {
        'status': 'Menunggu Review',
        'tanggapan_mahasiswa': tanggapan.trim(),
        'diperbarui_pada': DateTime.now().toIso8601String(),
      },
      where: '''
        id = ?
        AND mahasiswa_id = ?
        AND status IN ('Dalam Pengerjaan', 'Perlu Perbaikan')
      ''',
      whereArgs: [revisiId, mahasiswa['id']],
    );

    if (updated != 1) {
      throw StateError('Status berubah. Muat ulang revisi.');
    }

    try {
      await NotificationService.instance.kirimKeAkun(
        penerimaId: revisi['dosen_id'] as int,
        judul: 'Hasil Revisi Dikirim',
        pesan:
            '${mahasiswa['nama']} mengirim hasil perbaikan '
            'untuk ${revisi['judul']}.',
        tipe: 'revisi',
        referensiId: revisiId,
      );
    } catch (_) {}
  }

  Future<void> review({
    required int revisiId,
    required bool disetujui,
    required String feedback,
  }) async {
    final dosen = await _akun('dosen');
    final db = await _db;

    final rows = await db.query(
      'skriva_revisi',
      where: 'id = ? AND dosen_id = ? AND status = ?',
      whereArgs: [revisiId, dosen['id'], 'Menunggu Review'],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw StateError('Tidak ada revisi yang menunggu review.');
    }

    if (!disetujui && feedback.trim().isEmpty) {
      throw StateError('Tuliskan alasan perbaikan.');
    }

    final revisi = rows.first;
    final statusBaru = disetujui ? 'Selesai' : 'Perlu Perbaikan';

    final updated = await db.update(
      'skriva_revisi',
      {
        'status': statusBaru,
        'umpan_balik_dosen': feedback.trim(),
        'diperbarui_pada': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND dosen_id = ? AND status = ?',
      whereArgs: [revisiId, dosen['id'], 'Menunggu Review'],
    );

    if (updated != 1) {
      throw StateError('Status sudah berubah. Muat ulang.');
    }

    try {
      await NotificationService.instance.kirimKeAkun(
        penerimaId: revisi['mahasiswa_id'] as int,
        judul: disetujui
            ? 'Revisi Disetujui'
            : 'Revisi Perlu Perbaikan',
        pesan:
            '${dosen['nama']} telah meninjau revisi '
            '${revisi['judul']}. Status: $statusBaru.',
        tipe: 'revisi',
        referensiId: revisiId,
      );
    } catch (_) {}
  }
}
