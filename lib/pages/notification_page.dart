import 'package:flutter/material.dart';
import 'package:test/service/notification_service.dart';
import 'package:test/theme/jadwal_theme.dart';
import 'package:test/pages/detailbimbingan_page.dart';
import 'package:test/pages/revisi_database_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const olive = Color(0xFF694A47);
  static const blue = Color(0xFF96C1C5);
  static const darkOlive = Color(0xFF523B39);

  final service = NotificationService.instance;

  List<Map<String, Object?>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    muat();
  }

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat notifikasi: $e')));
    }
  }

  Future<void> bukaNotifikasi(Map<String, Object?> item) async {
    final id = item['id'] as int;

    await service.tandaiNotifikasiAkunDibaca(id);
    await muat();

    if (!mounted) return;

    // Jika notifikasi revisi
    if (item['tipe'] == 'revisi') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RevisiDatabasePage()),
      );
      return;
    }

    // Jika notifikasi jadwal atau bimbingan selesai
    if (item['tipe'] == 'jadwal' || item['tipe'] == 'selesai') {
      final slotId = item['referensi_id'] as int?;

      DetailBimbinganPage.open(context, slotId: slotId);
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
        title: const Text('Hapus Notifikasi?'),
        content: const Text(
          'Seluruh riwayat notifikasi akun ini akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
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

  Widget kartu(Map<String, Object?> item) {
    final sudahDibaca = item['sudah_dibaca'] == 1;
    final tipe = item['tipe']?.toString() ?? '';
    final ikon = tipe == 'jadwal'
        ? Icons.calendar_month_rounded
        : tipe == 'selesai'
        ? Icons.task_alt_rounded
        : Icons.notifications_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: sudahDibaca ? null : Border.all(color: blue, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        onTap: () => bukaNotifikasi(item),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEAF3F2),
          child: Icon(ikon, color: olive),
        ),
        title: Text(
          item['judul']?.toString() ?? '',
          style: const TextStyle(
            color: darkOlive,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['pesan']?.toString() ?? '',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 9),
              Text(
                formatWaktu(item['dibuat_pada']?.toString()),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
        trailing: sudahDibaca
            ? null
            : const Icon(Icons.circle, color: blue, size: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPage(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF0DE),
        appBar: AppBar(
          title: const Text('Notifikasi'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'read') semuaDibaca();
                if (value == 'clear') hapusSemua();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'read',
                  child: Text('Tandai semua dibaca'),
                ),
                PopupMenuItem(value: 'clear', child: Text('Hapus riwayat')),
              ],
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF0DE), Color(0xFFEAF3F2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: loading
              ? const Center(child: CircularProgressIndicator(color: olive))
              : RefreshIndicator(
                  onRefresh: muat,
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      const Text(
                        'Informasi terbaru bimbinganmu',
                        style: TextStyle(color: darkOlive),
                      ),
                      const SizedBox(height: 16),
                      if (items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 65),
                          child: Column(
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                size: 65,
                                color: blue,
                              ),
                              SizedBox(height: 12),
                              Text('Belum ada notifikasi'),
                            ],
                          ),
                        ),
                      ...items.map(kartu),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
