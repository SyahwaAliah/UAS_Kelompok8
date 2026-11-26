import 'package:flutter/material.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/database/jadwal_bimbingan_service.dart';
import 'package:test/widgets/skriva_dashboard_ui.dart';

class JadwalBimbinganBaruPage extends StatefulWidget {
  const JadwalBimbinganBaruPage({super.key});

  @override
  State<JadwalBimbinganBaruPage> createState() =>
      _JadwalBimbinganBaruPageState();
}

class _JadwalBimbinganBaruPageState
    extends State<JadwalBimbinganBaruPage> {
  static const blue = SkrivaDashColors.blue;
  static const dark = SkrivaDashColors.dark;
  static const lime = SkrivaDashColors.lime;

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

  // =====================================================
  // LOAD DATA
  // =====================================================

  Future<void> muat() async {
    if (mounted) {
      setState(() => loading = true);
    }

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
      SnackBar(
        content: Text(value),
        behavior: SnackBarBehavior.floating,
        backgroundColor: blue,
      ),
    );
  }

  Future<void> jalankan(
    Future<void> Function() tindakan,
  ) async {
    if (proses) return;

    setState(() => proses = true);

    try {
      await tindakan();
      await muat();
    } catch (e) {
      pesan('$e');
    } finally {
      if (mounted) {
        setState(() => proses = false);
      }
    }
  }

  // =====================================================
  // BUAT SLOT
  // =====================================================

  Future<void> buatJadwal() async {
    DateTime tanggal = DateTime.now().add(
      const Duration(days: 1),
    );

    String jam = jamTersedia.first;
    String mode = 'Tatap Muka';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: SkrivaDashColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              title: const Text(
                'Buat Slot Bimbingan',
                style: TextStyle(
                  color: dark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal',
                      style: TextStyle(
                        color: dark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final dipilih = await showDatePicker(
                          context: dialogContext,
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
                      icon: const Icon(
                        Icons.calendar_month_rounded,
                      ),
                      label: Text(
                        '${tanggal.day}/${tanggal.month}/${tanggal.year}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: jam,
                      decoration: const InputDecoration(
                        labelText: 'Jam Bimbingan',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: mode,
                      decoration: const InputDecoration(
                        labelText: 'Mode Bimbingan',
                        border: OutlineInputBorder(),
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
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                  ),
                  onPressed: () =>
                      Navigator.pop(dialogContext, true),
                  child: const Text('Buat Jadwal'),
                ),
              ],
            );
          },
        );
      },
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
        backgroundColor: SkrivaDashColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          judul,
          style: const TextStyle(
            color: dark,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(isi),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: blue,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Lanjutkan'),
          ),
        ],
      ),
    );

    return result == true;
  }

  // =====================================================
  // BOOKING / APPROVAL / HAPUS
  // =====================================================

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

  // =====================================================
  // STATUS
  // =====================================================

  Color warnaStatus(String status) {
    switch (status) {
      case 'Tersedia':
        return const Color(0xFF358457);
      case 'Menunggu':
        return const Color(0xFFBA7A20);
      case 'Terjadwal':
        return blue;
      case 'Selesai':
        return const Color(0xFF68758B);
      default:
        return SkrivaDashColors.muted;
    }
  }

  Color backgroundStatus(String status) {
    switch (status) {
      case 'Tersedia':
        return lime;
      case 'Menunggu':
        return const Color(0xFFFFEAC5);
      case 'Terjadwal':
        return SkrivaDashColors.softBlue;
      case 'Selesai':
        return const Color(0xFFE7EAF0);
      default:
        return const Color(0xFFF0F2F5);
    }
  }

  Widget badgeStatus(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: backgroundStatus(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: warnaStatus(status),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget tombol(
    String label,
    IconData icon,
    VoidCallback action, {
    bool outlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: proses ? null : action,
              icon: Icon(icon),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: blue,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )
          : FilledButton.icon(
              onPressed: proses ? null : action,
              icon: Icon(icon),
              label: Text(label),
              style: FilledButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
    );
  }

  // =====================================================
  // KARTU JADWAL
  // =====================================================

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

    final parsed = DateTime.tryParse(tanggal);
    final sekarang = DateTime.now();
    final hariIni = DateTime(
      sekarang.year,
      sekarang.month,
      sekarang.day,
    );

    final sudahLewat =
        parsed != null && parsed.isBefore(hariIni);

    final bisaBooking =
        !dosen && status == 'Tersedia' && !sudahLewat;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: SkrivaGlassCard(
        tint: SkrivaDashColors.softBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: lime,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: dark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tanggal,
                    style: const TextStyle(
                      color: dark,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                badgeStatus(status),
              ],
            ),

            const SizedBox(height: 17),

            Text(
              '$jam WIB',
              style: const TextStyle(
                color: blue,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.video_camera_front_outlined,
                  size: 17,
                  color: SkrivaDashColors.muted,
                ),
                const SizedBox(width: 7),
                Text(
                  mode,
                  style: const TextStyle(
                    color: SkrivaDashColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 11),

            if (!dosen) ...[
              Text(
                'Dosen: $dosenNama',
                style: const TextStyle(
                  color: dark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pembimbing ${data['pembimbing_ke']}',
                style: const TextStyle(
                  color: blue,
                  fontSize: 11,
                ),
              ),
            ],

            if (dosen && mahasiswaNama.isNotEmpty) ...[
              Text(
                'Mahasiswa: $mahasiswaNama',
                style: const TextStyle(
                  color: dark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'NIM: ${data['nim'] ?? '-'}',
                style: const TextStyle(
                  color: SkrivaDashColors.muted,
                  fontSize: 11,
                ),
              ),
            ],

            if (bisaBooking ||
                (dosen && status != 'Selesai')) ...[
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE4EAF1)),
              const SizedBox(height: 8),
            ],

            if (bisaBooking)
              tombol(
                'Booking Jadwal',
                Icons.add_circle_outline_rounded,
                () => booking(id),
              ),

            if (dosen && status == 'Menunggu')
              tombol(
                'Konfirmasi Booking',
                Icons.check_circle_outline_rounded,
                () => ubahStatus(id, 'Terjadwal'),
              ),

            if (dosen && status == 'Terjadwal')
              tombol(
                'Tandai Selesai',
                Icons.task_alt_rounded,
                () => ubahStatus(id, 'Selesai'),
              ),

            if (dosen && status == 'Tersedia')
              tombol(
                'Hapus Slot',
                Icons.delete_outline_rounded,
                () => hapusSlot(id),
                outlined: true,
              ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // MAIN PAGE
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkrivaDashColors.background,
      appBar: AppBar(
        backgroundColor: SkrivaDashColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: dark,
        title: Text(
          dosen ? 'Kelola Jadwal' : 'Jadwal Bimbingan',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: muat,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: !loading && dosen
          ? FloatingActionButton.extended(
              onPressed: proses ? null : buatJadwal,
              backgroundColor: blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Buat Slot'),
            )
          : null,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF6F8FB),
                    Color(0xFFEDF8F8),
                    Color(0xFFF8F5FF),
                  ],
                ),
              ),
            ),
          ),
          if (loading)
            const Center(
              child: CircularProgressIndicator(
                color: blue,
              ),
            )
          else
            RefreshIndicator(
              color: blue,
              onRefresh: muat,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  110,
                ),
                children: [
                  SkrivaDashboardHero(
                    eyebrow: dosen
                        ? 'LECTURER / SCHEDULE'
                        : 'STUDENT / SCHEDULE',
                    title: dosen
                        ? 'Plan.\nGuide. Meet.'
                        : 'Book Your\nNext Session.',
                    subtitle: dosen
                        ? 'Kelola slot dan persetujuan bimbingan.'
                        : 'Temukan slot dari dosen pembimbingmu.',
                    icon: Icons.calendar_month_rounded,
                  ),
                  const SizedBox(height: 24),
                  SkrivaSectionTitle(
                    title: dosen
                        ? 'Jadwal Dosen'
                        : 'Jadwal Tersedia',
                    subtitle:
                        '${items.length} slot tercatat',
                  ),
                  const SizedBox(height: 15),
                  if (items.isEmpty)
                    SkrivaGlassCard(
                      tint: SkrivaDashColors.lime,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.event_busy_rounded,
                            color: blue,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            dosen
                                ? 'Belum ada slot. Tekan Buat Slot.'
                                : 'Belum ada jadwal dari dosen pembimbingmu.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: dark),
                          ),
                        ],
                      ),
                    ),
                  ...items.map(kartuJadwal),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
