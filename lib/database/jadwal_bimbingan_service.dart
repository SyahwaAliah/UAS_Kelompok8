import 'package:test/service/notification_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/database/auth_database.dart';

class JadwalBimbinganService {
  JadwalBimbinganService._();

  static final JadwalBimbinganService instance =
      JadwalBimbinganService._();

  Future<Database> get _database async {
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_slot_jadwal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dosen_id INTEGER NOT NULL,
        tanggal TEXT NOT NULL,
        jam TEXT NOT NULL,
        mode TEXT NOT NULL,
        mahasiswa_id INTEGER,
        status TEXT NOT NULL DEFAULT 'Tersedia',
        UNIQUE(dosen_id, tanggal, jam),
        FOREIGN KEY(dosen_id) REFERENCES skriva_akun(id),
        FOREIGN KEY(mahasiswa_id) REFERENCES skriva_akun(id)
      )
    ''');

    return db;
  }

  Future<Map<String, Object?>> _akun(String role) async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (akun == null || akun['role'] != role) {
      throw StateError('Akses hanya untuk $role yang sedang login.');
    }

    return akun;
  }

  Future<int> buatSlot({
    required DateTime tanggal,
    required String jam,
    required String mode,
  }) async {
    final akun = await _akun('dosen');
    final dosenId = akun['id'] as int;
    final db = await _database;

    final hari = DateTime(tanggal.year, tanggal.month, tanggal.day);

    if (hari.isBefore(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ))) {
      throw StateError('Tidak bisa membuat jadwal di tanggal lampau.');
    }

    final tanggalString = hari.toIso8601String().substring(0, 10);

    if (jam.trim().isEmpty || mode.trim().isEmpty) {
      throw StateError('Jam dan mode harus diisi.');
    }

    final jamAwal = jam.split(' - ').first.replaceAll('.', ':');
    final bagianJam = jamAwal.split(':');

    if (bagianJam.length != 2) {
      throw StateError('Format jam tidak valid.');
    }

    final jamMulai = int.tryParse(bagianJam[0]);
    final menitMulai = int.tryParse(bagianJam[1]);

    if (jamMulai == null ||
        menitMulai == null ||
        jamMulai < 0 ||
        jamMulai > 23 ||
        menitMulai < 0 ||
        menitMulai > 59) {
      throw StateError('Format jam tidak valid.');
    }

    final waktuSlot = DateTime(
      tanggal.year,
      tanggal.month,
      tanggal.day,
      jamMulai,
      menitMulai,
    );

    if (!waktuSlot.isAfter(DateTime.now())) {
      throw StateError('Jam bimbingan harus di masa depan.');
    }

    try {
      return await db.insert('skriva_slot_jadwal', {
        'dosen_id': dosenId,
        'tanggal': tanggalString,
        'jam': jam,
        'mode': mode,
        'status': 'Tersedia',
      });
    } on DatabaseException {
      throw StateError(
        'Slot pada tanggal dan jam tersebut sudah ada.',
      );
    }
  }

  Future<List<Map<String, Object?>>> slotDosen() async {
    final akun = await _akun('dosen');
    final db = await _database;

    return db.rawQuery('''
      SELECT
        j.*,
        d.nama AS nama_dosen,
        m.nama AS nama_mahasiswa,
        m.nomor_induk AS nim
      FROM skriva_slot_jadwal j
      JOIN skriva_akun d ON d.id = j.dosen_id
      LEFT JOIN skriva_akun m ON m.id = j.mahasiswa_id
      WHERE j.dosen_id = ?
      ORDER BY j.tanggal ASC, j.jam ASC
    ''', [akun['id']]);
  }

  Future<List<Map<String, Object?>>> slotMahasiswa() async {
    final akun = await _akun('mahasiswa');
    final db = await _database;

    return db.rawQuery('''
      SELECT
        j.*,
        d.nama AS nama_dosen,
        p.urutan AS pembimbing_ke
      FROM skriva_slot_jadwal j
      JOIN skriva_pembimbing p
        ON p.dosen_id = j.dosen_id
      JOIN skriva_akun d
        ON d.id = j.dosen_id
      WHERE p.mahasiswa_id = ?
        AND (
          j.status = 'Tersedia'
          OR j.mahasiswa_id = ?
        )
      ORDER BY j.tanggal ASC, j.jam ASC
    ''', [akun['id'], akun['id']]);
  }

  Future<void> booking(int slotId) async {
    final akun = await _akun('mahasiswa');
    final mahasiswaId = akun['id'] as int;
    final db = await _database;

    await db.transaction((txn) async {
      final rows = await txn.rawQuery('''
        SELECT j.*
        FROM skriva_slot_jadwal j
        JOIN skriva_pembimbing p
          ON p.dosen_id = j.dosen_id
        WHERE j.id = ? AND p.mahasiswa_id = ?
        LIMIT 1
      ''', [slotId, mahasiswaId]);

      if (rows.isEmpty) {
        throw StateError('Jadwal bukan milik dosen pembimbingmu.');
      }

      final slot = rows.first;
      final tanggal = slot['tanggal'].toString();
      final jam = slot['jam'].toString();
      final mulai = jam.split(' - ').first.replaceAll('.', ':');
      final waktu = DateTime.tryParse('${tanggal}T$mulai:00');

      if (waktu == null || !waktu.isAfter(DateTime.now())) {
        throw StateError('Jadwal sudah lewat.');
      }

      final updated = await txn.update(
        'skriva_slot_jadwal',
        {
          'mahasiswa_id': mahasiswaId,
          'status': 'Menunggu',
        },
        where: '''
          id = ?
          AND mahasiswa_id IS NULL
          AND status = ?
        ''',
        whereArgs: [slotId, 'Tersedia'],
      );

      if (updated != 1) {
        throw StateError('Slot ini sudah dibooking mahasiswa lain.');
      }
    });
  }

 
Future<void> ubahStatus(int slotId, String status) async {
  final akun = await _akun('dosen');

  if (!['Terjadwal', 'Selesai'].contains(status)) {
    throw StateError('Status tidak valid.');
  }

  final db = await _database;

  final rows = await db.query(
    'skriva_slot_jadwal',
    where: 'id = ? AND dosen_id = ?',
    whereArgs: [slotId, akun['id']],
    limit: 1,
  );

  if (rows.isEmpty) {
    throw StateError('Jadwal tidak ditemukan.');
  }

  final slot = rows.first;
  final statusLama = slot['status']?.toString();
  final mahasiswaId = slot['mahasiswa_id'] as int?;

  if (mahasiswaId == null) {
    throw StateError('Belum ada mahasiswa yang booking.');
  }

  if ((status == 'Terjadwal' && statusLama != 'Menunggu') ||
      (status == 'Selesai' && statusLama != 'Terjadwal')) {
    throw StateError('Perubahan status tidak diperbolehkan.');
  }

  final updated = await db.update(
    'skriva_slot_jadwal',
    {'status': status},
    where: 'id = ? AND dosen_id = ? AND status = ?',
    whereArgs: [slotId, akun['id'], statusLama],
  );

  if (updated != 1) {
    throw StateError('Status sudah berubah. Muat ulang jadwal.');
  }

  final namaDosen = akun['nama']?.toString() ?? 'Dosen Pembimbing';
  final tanggal = slot['tanggal']?.toString() ?? '';
  final jam = slot['jam']?.toString() ?? '';

  try {
    if (status == 'Terjadwal') {
      await NotificationService.instance.kirimKeAkun(
        penerimaId: mahasiswaId,
        judul: 'Booking Bimbingan Disetujui',
        pesan:
            '$namaDosen telah menyetujui bimbinganmu '
            'pada $tanggal pukul $jam WIB. '
            'Kamu dapat memulai konsultasi melalui Chat.',
        tipe: 'jadwal',
        referensiId: slotId,
      );
    } else if (status == 'Selesai') {
      await NotificationService.instance.kirimKeAkun(
        penerimaId: mahasiswaId,
        judul: 'Bimbingan Selesai',
        pesan:
            'Bimbingan dengan $namaDosen pada $tanggal '
            'telah ditandai selesai.',
        tipe: 'selesai',
        referensiId: slotId,
      );
    }
  } catch (e) {
    print('Gagal menyimpan notifikasi jadwal: $e');
  }
}


  Future<void> hapusSlot(int slotId) async {
    final akun = await _akun('dosen');
    final db = await _database;

    final deleted = await db.delete(
      'skriva_slot_jadwal',
      where: '''
        id = ?
        AND dosen_id = ?
        AND status = ?
        AND mahasiswa_id IS NULL
      ''',
      whereArgs: [slotId, akun['id'], 'Tersedia'],
    );

    if (deleted != 1) {
      throw StateError(
        'Hanya slot yang belum dibooking yang bisa dihapus.',
      );
    }
  }
}
