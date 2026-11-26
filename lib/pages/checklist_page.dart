import 'package:flutter/material.dart';
import 'package:test/theme/jadwal_theme.dart';
import 'package:test/models/checklist_model.dart';
import 'package:test/database/progress_akun_service.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  static const primary = Color(0xFF694A47);
  static const darkPrimary = Color(0xFF523B39);

  final service = ProgressAkunService.instance;

  List<ChecklistModel> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<void> muat() async {
    try {
      final rows = await service.semua();
      if (!mounted) return;

      setState(() {
        items = rows;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      pesan('$e');
    }
  }

  void pesan(String isi) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isi)),
    );
  }

  Future<void> toggle(ChecklistModel item) async {
    try {
      await service.ubahStatus(
        item.id!,
        !item.selesai,
      );
      await muat();
    } catch (e) {
      pesan('Gagal memperbarui: $e');
    }
  }

  Future<void> tambah() async {
    final controller = TextEditingController();

    final simpan = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Tahap Skripsi'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Contoh: Bab 4',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    final judul = controller.text.trim();
    controller.dispose();

    if (simpan != true) return;

    try {
      await service.tambah(judul);
      await muat();
    } catch (e) {
      pesan('Gagal menambah: $e');
    }
  }

  Future<void> hapus(ChecklistModel item) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tahap?'),
        content: Text(item.kegiatan),
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

    if (setuju != true) return;

    try {
      await service.hapus(item.id!);
      await muat();
    } catch (e) {
      pesan('Gagal menghapus: $e');
    }
  }

  Widget kartu(ChecklistModel item) {
    return InkWell(
      onTap: () => toggle(item),
      onLongPress: () => hapus(item),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              item.selesai
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: item.selesai
                  ? primary
                  : Colors.grey,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.kegiatan,
                style: TextStyle(
                  color: darkPrimary,
                  fontWeight: FontWeight.w600,
                  decoration: item.selesai
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Hapus tahap',
              onPressed: () => hapus(item),
              icon: const Icon(
                Icons.delete_outline,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jumlahSelesai =
        items.where((item) => item.selesai).length;

    final persen = items.isEmpty
        ? 0
        : (jumlahSelesai / items.length * 100).round();

    return AnimatedPage(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF0DE),
        appBar: AppBar(
          title: const Text('Progress Skripsi'),
          actions: [
            IconButton(
              onPressed: muat,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          onPressed: tambah,
          child: const Icon(Icons.add),
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: primary,
                ),
              )
            : RefreshIndicator(
                onRefresh: muat,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    18, 18, 18, 95,
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Progress Skripsi Kamu',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$persen%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: persen / 100,
                            backgroundColor: Colors.white30,
                            color: const Color(0xFF96C1C5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$jumlahSelesai dari '
                            '${items.length} tahapan selesai',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (items.isEmpty)
                      const Text(
                        'Belum ada tahapan.',
                        textAlign: TextAlign.center,
                      ),
                    ...items.map(kartu),
                  ],
                ),
              ),
      ),
    );
  }
}
