import 'package:flutter/material.dart';
import 'package:test/database/auth_database.dart';
import 'package:test/database/database_helper.dart';

class ChatPesanOtomatis extends StatefulWidget {
  final int dosenId;
  final int? mahasiswaId;

  const ChatPesanOtomatis({
    super.key,
    required this.dosenId,
    this.mahasiswaId,
  });

  @override
  State<ChatPesanOtomatis> createState() =>
      _ChatPesanOtomatisState();
}

class _ChatPesanOtomatisState
    extends State<ChatPesanOtomatis> {
  static const olive = Color(0xFF694A47);

  List<String> pesan = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<void> muat() async {
    try {
      final akun = await AuthDatabase.instance.sesiAktif();

      if (akun == null) {
        throw StateError('Silakan login.');
      }

      final role = akun['role']?.toString();
      final akunId = akun['id'] as int;

      if (role != 'mahasiswa' && role != 'dosen') {
        throw StateError('Role tidak didukung.');
      }

      if (role == 'dosen' && akunId != widget.dosenId) {
        throw StateError('Tidak memiliki akses chat.');
      }

      final mahasiswaId = role == 'mahasiswa'
          ? akunId
          : widget.mahasiswaId;

      if (mahasiswaId == null) {
        throw StateError('Mahasiswa belum dipilih.');
      }

      final db = await DatabaseHelper.instance.database;

      // Hanya izinkan pasangan bimbingan terdaftar.
      final pasangan = await db.query(
        'skriva_pembimbing',
        where: 'mahasiswa_id = ? AND dosen_id = ?',
        whereArgs: [mahasiswaId, widget.dosenId],
        limit: 1,
      );

      if (pasangan.isEmpty) {
        throw StateError('Pasangan bimbingan tidak ditemukan.');
      }

      final rows = await db.query(
        'skriva_slot_jadwal',
        columns: ['tanggal', 'jam', 'status'],
        where: 'mahasiswa_id = ? AND dosen_id = ?',
        whereArgs: [mahasiswaId, widget.dosenId],
        orderBy: 'tanggal DESC, jam DESC',
        limit: 1,
      );

      final daftar = <String>[
        'Halo! Selamat datang di ruang konsultasi Skriva. '
            'Silakan gunakan chat ini untuk berdiskusi '
            'mengenai skripsi dengan dosen pembimbing.',
      ];

      if (rows.isNotEmpty) {
        final jadwal = rows.first;
        final status = jadwal['status']?.toString() ?? '';
        final tanggal = jadwal['tanggal']?.toString() ?? '-';
        final jam = jadwal['jam']?.toString() ?? '-';

        if (status == 'Menunggu') {
          daftar.add(
            'Booking bimbingan tanggal $tanggal '
            'pukul $jam WIB sedang menunggu persetujuan dosen.',
          );
        } else if (status == 'Terjadwal') {
          daftar.add(
            'Jadwal bimbingan tanggal $tanggal '
            'pukul $jam WIB telah disetujui dosen. '
            'Silakan persiapkan materi bimbingan.',
          );
        } else if (status == 'Selesai') {
          daftar.add(
            'Bimbingan tanggal $tanggal '
            'pukul $jam WIB telah selesai. '
            'Jangan lupa mencatat hasil diskusi dan revisi.',
          );
        }
      }

      if (!mounted) return;

      setState(() {
        pesan = daftar;
        loading = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat pesan sistem: $e');

      if (!mounted) return;
      setState(() {
        pesan = [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || pesan.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 205),
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: pesan.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F0EF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Text(
                  'PESAN SISTEM SKRIVA',
                  style: TextStyle(
                    color: olive,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  pesan[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF523B39),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
