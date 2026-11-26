
import 'package:flutter/material.dart';

import 'package:test/database/progress_akun_service.dart';
import 'package:test/models/checklist_model.dart';
import 'package:test/widgets/skriva_dashboard_ui.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() =>
      _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  static const blue = SkrivaDashColors.blue;
  static const dark = SkrivaDashColors.dark;
  static const lime = SkrivaDashColors.lime;

  final service = ProgressAkunService.instance;

  List<ChecklistModel> items = [];

  bool loading = true;
  bool proses = false;

  int get jumlahSelesai =>
      items.where((item) => item.selesai).length;

  int get persen => items.isEmpty
      ? 0
      : ((jumlahSelesai / items.length) * 100).round();

  @override
  void initState() {
    super.initState();
    muat();
  }

  // =====================================================
  // LOAD DATA
  // =====================================================

  Future<void> muat() async {
    try {
      final hasil = await service.semua();

      if (!mounted) return;

      setState(() {
        items = hasil;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      pesan('Gagal memuat checklist: $e');
    }
  }

  void pesan(String isi) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isi),
        behavior: SnackBarBehavior.floating,
        backgroundColor: blue,
      ),
    );
  }

  Future<void> aksi(
    Future<void> Function() callback,
  ) async {
    if (proses) return;

    setState(() => proses = true);

    try {
      await callback();
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
  // TOGGLE STATUS
  // =====================================================

  Future<void> ubahStatus(ChecklistModel item) async {
    if (item.id == null) return;

    await aksi(() {
      return service.ubahStatus(
        item.id!,
        !item.selesai,
      );
    });
  }

  // =====================================================
  // TAMBAH TAHAPAN
  // =====================================================

  Future<void> tambahTahapan() async {
    final controller = TextEditingController();

    final hasil = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: SkrivaDashColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Text(
            'Tambah Tahapan',
            style: TextStyle(
              color: dark,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Contoh: Bab 4',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: blue,
              ),
              onPressed: () {
                Navigator.pop(
                  ctx,
                  controller.text.trim(),
                );
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (hasil == null || hasil.isEmpty) return;

    await aksi(() => service.tambah(hasil));
  }

  // =====================================================
  // HAPUS TAHAPAN
  // =====================================================

  Future<void> hapusTahapan(ChecklistModel item) async {
    if (item.id == null) return;

    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SkrivaDashColors.background,
        title: const Text('Hapus Tahapan?'),
        content: Text(
          'Tahapan "${item.kegiatan}" akan dihapus.',
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

    if (setuju != true) return;

    await aksi(() => service.hapus(item.id!));
  }

  // =====================================================
  // ITEM CHECKLIST
  // =====================================================

  Widget kartuTahapan(
    ChecklistModel item,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: SkrivaGlassCard(
        tint: item.selesai
            ? lime
            : SkrivaDashColors.softBlue,
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            InkWell(
              onTap: proses ? null : () => ubahStatus(item),
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: item.selesai
                      ? lime
                      : const Color(0xFFE8EFF7),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  item.selesai
                      ? Icons.check_rounded
                      : Icons.circle_outlined,
                  color: item.selesai ? dark : blue,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: InkWell(
                onTap: proses ? null : () => ubahStatus(item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MILESTONE ${index + 1}',
                      style: const TextStyle(
                        color: blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.kegiatan,
                      style: TextStyle(
                        color: dark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        decoration: item.selesai
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.selesai ? 'Selesai' : 'Belum selesai',
                      style: const TextStyle(
                        color: SkrivaDashColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            IconButton(
              tooltip: 'Hapus Tahapan',
              onPressed: proses
                  ? null
                  : () => hapusTahapan(item),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: SkrivaDashColors.muted,
              ),
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
        foregroundColor: dark,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Checklist Skripsi',
          style: TextStyle(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: proses ? null : tambahTahapan,
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Tahap'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: blue),
            )
          : RefreshIndicator(
              color: blue,
              onRefresh: muat,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  105,
                ),
                children: [
                  const SkrivaDashboardHero(
                    eyebrow: 'STUDENT / MILESTONES',
                    title: 'Small Steps.\nBig Progress.',
                    subtitle:
                        'Track every milestone on your thesis journey.',
                    icon: Icons.checklist_rounded,
                  ),

                  const SizedBox(height: 20),

                  SkrivaGlassCard(
                    tint: SkrivaDashColors.softBlue,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'YOUR PROGRESS',
                                style: TextStyle(
                                  color: blue,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                '$jumlahSelesai / ${items.length}',
                                style: const TextStyle(
                                  color: dark,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 5),

                              const Text(
                                'Tahapan selesai',
                                style: TextStyle(
                                  color: SkrivaDashColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SkrivaProgressDiagram(
                          percent: persen,
                          completed: jumlahSelesai,
                          total: items.length,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const SkrivaSectionTitle(
                    title: 'Thesis Milestones',
                    subtitle:
                        'Ketuk tahapan untuk mengubah status.',
                  ),

                  const SizedBox(height: 14),

                  if (items.isEmpty)
                    const SkrivaGlassCard(
                      tint: lime,
                      child: Text(
                        'Checklist masih kosong. Tambahkan tahap baru.',
                      ),
                    ),

                  ...List.generate(
                    items.length,
                    (index) => kartuTahapan(
                      items[index],
                      index,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
