
import 'package:flutter/material.dart';

import 'package:test/service/notification_service.dart';
import 'package:test/pages/detailbimbingan_page.dart';
import 'package:test/pages/revisi_database_page.dart';
import 'package:test/widgets/skriva_dashboard_ui.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() =>
      _NotificationPageState();
}

class _NotificationPageState
    extends State<NotificationPage> {
  static const blue = SkrivaDashColors.blue;
  static const dark = SkrivaDashColors.dark;

  final service = NotificationService.instance;

  List<Map<String, Object?>> items = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    muat();
  }

  // =====================================================
  // LOAD NOTIFIKASI
  // =====================================================

  Future<void> muat() async {
    try {
      final data = await service.ambilNotifikasiAkun();

      if (!mounted) return;

      setState(() {
        items = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat notifikasi: $e'),
        ),
      );
    }
  }

  Future<void> bukaNotifikasi(
    Map<String, Object?> item,
  ) async {
    final id = item['id'] as int;

    await service.tandaiNotifikasiAkunDibaca(id);
    await muat();

    if (!mounted) return;

    if (item['tipe'] == 'revisi') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const RevisiDatabasePage(),
        ),
      );
      return;
    }

    if (item['tipe'] == 'jadwal' ||
        item['tipe'] == 'selesai') {
      final slotId = item['referensi_id'] as int?;

      DetailBimbinganPage.open(
        context,
        slotId: slotId,
      );
      return;
    }
  }

  Future<void> semuaDibaca() async {
    await service.tandaiSemuaNotifikasiAkunDibaca();
    await muat();
  }

  Future<void> hapusSemua() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SkrivaDashColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Hapus Notifikasi?',
          style: TextStyle(
            color: dark,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'Seluruh riwayat notifikasi akun ini akan dihapus.',
        ),
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
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yes != true) return;

    await service.hapusSemuaNotifikasiAkun();
    await muat();
  }

  String formatWaktu(String? value) {
    final date = DateTime.tryParse(value ?? '');
    if (date == null) return '-';

    String dua(int n) => n.toString().padLeft(2, '0');

    return '${dua(date.day)}/${dua(date.month)}/${date.year} '
        '${dua(date.hour)}:${dua(date.minute)}';
  }

  // =====================================================
  // KARTU NOTIFIKASI
  // =====================================================

  Widget kartu(Map<String, Object?> item) {
    final sudahDibaca = item['sudah_dibaca'] == 1;
    final tipe = item['tipe']?.toString() ?? '';

    final ikon = tipe == 'jadwal'
        ? Icons.calendar_month_rounded
        : tipe == 'selesai'
            ? Icons.task_alt_rounded
            : tipe == 'revisi'
                ? Icons.rate_review_rounded
                : Icons.notifications_rounded;

    final warna = tipe == 'jadwal'
        ? SkrivaDashColors.softBlue
        : tipe == 'selesai'
            ? SkrivaDashColors.lime
            : tipe == 'revisi'
                ? SkrivaDashColors.peach
                : SkrivaDashColors.lavender;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: GestureDetector(
        onTap: () => bukaNotifikasi(item),
        child: SkrivaGlassCard(
          tint: warna,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: warna,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  ikon,
                  color: blue,
                  size: 24,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['judul']?.toString() ?? '',
                            style: const TextStyle(
                              color: dark,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        if (!sudahDibaca)
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      item['pesan']?.toString() ?? '',
                      style: const TextStyle(
                        color: SkrivaDashColors.muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 11),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: blue,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            formatWaktu(
                              item['dibuat_pada']?.toString(),
                            ),
                            style: const TextStyle(
                              color: SkrivaDashColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              const Icon(
                Icons.chevron_right_rounded,
                color: blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // MAIN PAGE
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final belumDibaca = items.where(
      (item) => item['sudah_dibaca'] != 1,
    ).length;

    return Scaffold(
      backgroundColor: SkrivaDashColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        foregroundColor: dark,
        backgroundColor: SkrivaDashColors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'read') {
                semuaDibaca();
              } else if (value == 'clear') {
                hapusSemua();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'read',
                child: Text('Tandai semua dibaca'),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Text('Hapus riwayat'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
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
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: blue,
                ),
              )
            : RefreshIndicator(
                color: blue,
                onRefresh: muat,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    16,
                    18,
                    30,
                  ),
                  children: [
                    const SkrivaDashboardHero(
                      eyebrow: 'SKRIVA / ACTIVITY',
                      title: 'Stay in\nthe Loop.',
                      subtitle:
                          'Every update, all in one place.',
                      icon: Icons.notifications_active_rounded,
                    ),

                    const SizedBox(height: 25),

                    SkrivaSectionTitle(
                      title: 'Your Updates',
                      subtitle: belumDibaca == 0
                          ? 'Semua notifikasi sudah dibaca.'
                          : '$belumDibaca notifikasi belum dibaca',
                    ),

                    const SizedBox(height: 16),

                    if (items.isEmpty)
                      const SkrivaGlassCard(
                        tint: SkrivaDashColors.softBlue,
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              color: blue,
                              size: 46,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Belum ada notifikasi.',
                              style: TextStyle(
                                color: dark,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ...items.map(kartu),
                  ],
                ),
              ),
      ),
    );
  }
}
