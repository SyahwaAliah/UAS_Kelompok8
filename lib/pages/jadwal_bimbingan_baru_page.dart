
import 'package:flutter/material.dart';
import 'package:test/database/auth_database.dart';
import 'package:test/database/jadwal_bimbingan_service.dart';
import 'package:test/theme/jadwal_theme.dart';

class JadwalBimbinganBaruPage extends StatefulWidget {
  const JadwalBimbinganBaruPage({super.key});

  @override
  State<JadwalBimbinganBaruPage> createState() =>
      _JadwalBimbinganBaruPageState();
}

class _JadwalBimbinganBaruPageState
    extends State<JadwalBimbinganBaruPage> {
  static const olive = Color(0xFF694A47);
  static const blue = Color(0xFF96C1C5);

  final service = JadwalBimbinganService.instance;

  List<Map<String, Object?>> items = [];
  bool loading = true;
  bool dosen = false;
  bool proses = false;

  final jamTersedia = const [
    '08.00 - 09.00',
    '09.00 - 10.00',
    '10.00 - 11.00',
    '11.00 - 12.00',
    '13.00 - 14.00',
    '14.00 - 15.00',
    '15.00 - 16.00',
  ];

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<void> muat() async {
    if (mounted) setState(() => loading = true);

    try {
      final akun = await AuthDatabase.instance.sesiAktif();

      if (akun == null) {
        throw StateError('Silakan login kembali.');
      }

      final isDosen = akun['role'] == 'dosen';

      final rows = isDosen
          ? await service.slotDosen()
          : await service.slotMahasiswa();

      if (!mounted) return;

      setState(() {
        dosen = isDosen;
        items = rows;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      pesan('$e');
    }
  }

  void pesan(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }

  Future<void> jalankan(Future<void> Function() tindakan) async {
    if (proses) return;

    setState(() => proses = true);
    try {
      await tindakan();
      await muat();
    } catch (e) {
      pesan('$e');
    } finally {
      if (mounted) setState(() => proses = false);
    }
  }

  Future<void> buatJadwal() async {
    DateTime tanggal = DateTime.now().add(
      const Duration(days: 1),
    );
    String jam = jamTersedia.first;
    String mode = 'Tatap Muka';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Buat Slot Bimbingan'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tanggal'),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      '${tanggal.day}/${tanggal.month}/${tanggal.year}',
                    ),
                    onPressed: () async {
                      final dipilih = await showDatePicker(
                        context: context,
                        initialDate: tanggal,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365),
                        ),
                      );
                      if (dipilih != null) {
                        setDialogState(() => tanggal = dipilih);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: jam,
                    decoration: const InputDecoration(
                      labelText: 'Jam Bimbingan',
                    ),
                    items: jamTersedia.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => jam = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: mode,
                    decoration: const InputDecoration(
                      labelText: 'Mode Bimbingan',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Tatap Muka',
                        child: Text('Tatap Muka'),
                      ),
                      DropdownMenuItem(
                        value: 'Video Call',
                        child: Text('Video Call'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => mode = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Buat Jadwal'),
              ),
            ],
          );
        },
      ),
    );

    if (result != true) return;

    await jalankan(() async {
      await service.buatSlot(
        tanggal: tanggal,
        jam: jam,
        mode: mode,
      );
      pesan('Slot bimbingan berhasil dibuat.');
    });
  }

  Future<bool> konfirmasi(
    String judul,
    String isi,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(judul),
        content: Text(isi),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Lanjutkan'),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> booking(int id) async {
    final yes = await konfirmasi(
      'Booking Bimbingan',
      'Yakin ingin memesan slot jadwal ini?',
    );

    if (!yes) return;

    await jalankan(() async {
      await service.booking(id);
      pesan('Booking berhasil! Menunggu konfirmasi dosen.');
    });
  }

  Future<void> ubahStatus(int id, String status) async {
    final yes = await konfirmasi(
      'Ubah Status',
      'Ubah status bimbingan menjadi $status?',
    );

    if (!yes) return;

    await jalankan(() async {
      await service.ubahStatus(id, status);
      pesan('Status berhasil diubah menjadi $status.');
    });
  }

  Future<void> hapusSlot(int id) async {
    final yes = await konfirmasi(
      'Hapus Slot',
      'Slot yang belum dibooking ini akan dihapus.',
    );

    if (!yes) return;

    await jalankan(() async {
      await service.hapusSlot(id);
      pesan('Slot berhasil dihapus.');
    });
  }

  Color warnaStatus(String status) {
    switch (status) {
      case 'Tersedia':
        return const Color(0xFF2F806B);
      case 'Menunggu':
        return const Color(0xFFD18935);
      case 'Terjadwal':
        return const Color(0xFF478DA0);
      case 'Selesai':
        return olive;
      default:
        return Colors.grey;
    }
  }

  Widget kartuJadwal(Map<String, Object?> data) {
    final id = data['id'] as int;
    final status = data['status']?.toString() ?? '';
    final tanggal = data['tanggal']?.toString() ?? '';
    final jam = data['jam']?.toString() ?? '';
    final mode = data['mode']?.toString() ?? '';

    final dosenNama =
        data['nama_dosen']?.toString() ?? 'Dosen Pembimbing';

    final mahasiswaNama =
        data['nama_mahasiswa']?.toString() ?? '';

    final tanggalParsed = DateTime.tryParse(tanggal);
    final sudahLewat = tanggalParsed != null &&
        tanggalParsed.isBefore(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ));

    final bisaBooking =
        !dosen && status == 'Tersedia' && !sudahLewat;

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tanggal,
                  style: const TextStyle(
                    color: olive,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: warnaStatus(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: warnaStatus(status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$jam WIB',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mode: $mode',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          if (!dosen) ...[
            Text('Dosen: $dosenNama'),
            Text(
              'Pembimbing ${data['pembimbing_ke']}',
              style: const TextStyle(
                color: olive,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (dosen && mahasiswaNama.isNotEmpty) ...[
            Text('Mahasiswa: $mahasiswaNama'),
            Text('NIM: ${data['nim'] ?? '-'}'),
          ],
          const SizedBox(height: 14),
          if (bisaBooking)
            tombol(
              'Booking Jadwal',
              Icons.add_circle_outline,
              () => booking(id),
            ),
          if (dosen && status == 'Menunggu')
            tombol(
              'Konfirmasi Booking',
              Icons.check_circle_outline,
              () => ubahStatus(id, 'Terjadwal'),
            ),
          if (dosen && status == 'Terjadwal')
            tombol(
              'Tandai Selesai',
              Icons.task_alt,
              () => ubahStatus(id, 'Selesai'),
            ),
          if (dosen && status == 'Tersedia')
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: proses ? null : () => hapusSlot(id),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Slot'),
              ),
            ),
        ],
      ),
    );
  }

  Widget tombol(
    String label,
    IconData icon,
    VoidCallback action,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: proses ? null : action,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: olive,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPage(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF0DE),
        appBar: AppBar(
          title: Text(
            dosen ? 'Kelola Jadwal Dosen' : 'Jadwal Bimbingan',
          ),
          backgroundColor: const Color(0xFFFFF0DE),
          actions: [
            IconButton(
              onPressed: muat,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: !loading && dosen
            ? FloatingActionButton.extended(
                backgroundColor: olive,
                foregroundColor: Colors.white,
                onPressed: proses ? null : buatJadwal,
                icon: const Icon(Icons.add),
                label: const Text('Buat Slot'),
              )
            : null,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFF0DE),
                Color(0xFFEAF3F2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(color: olive),
                )
              : RefreshIndicator(
                  onRefresh: muat,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                    children: [
                      Text(
                        dosen
                            ? 'Atur ketersediaan dan konfirmasi bimbingan.'
                            : 'Pilih jadwal dari dua dosen pembimbingmu.',
                        style: const TextStyle(
                          color: olive,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            dosen
                                ? 'Belum ada slot. Tekan Buat Slot.'
                                : 'Belum ada jadwal dari dosen pembimbingmu.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ...items.map(kartuJadwal),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
