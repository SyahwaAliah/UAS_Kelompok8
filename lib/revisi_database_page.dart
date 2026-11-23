import 'package:flutter/material.dart';
import 'jadwal_theme.dart';
import 'models/revisi_model.dart';
import 'repositories/revisi_repository.dart';

class RevisiDatabasePage extends StatefulWidget {
  const RevisiDatabasePage({super.key});
  @override
  State<RevisiDatabasePage> createState() => _RevisiDatabasePageState();
}

class _RevisiDatabasePageState extends State<RevisiDatabasePage> {
  final repo = RevisiRepository();
  List<RevisiModel> items = [];
  @override
  void initState() { super.initState(); refresh(); }
  Future<void> refresh() async {
    try {
      final rows = await repo.semua();
      if (mounted) setState(() => items = rows);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membaca revisi: $e')));
    }
  }

  Future<void> edit([RevisiModel? current]) async {
    final title = TextEditingController(text: current?.judul ?? '');
    final note = TextEditingController(text: current?.catatan ?? '');
    final confirm = await showDialog<bool>(context: context, builder: (ctx) =>
      AlertDialog(title: Text(current == null ? 'Tambah Revisi' : 'Ubah Revisi'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Judul')),
          TextField(controller: note, decoration: const InputDecoration(labelText: 'Catatan')),
        ]), actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
        ]));
    if (confirm == true && title.text.trim().isNotEmpty) {
      try {
        final model = RevisiModel(id: current?.id, judul: title.text.trim(),
          catatan: note.text.trim(), status: current?.status ?? 'Belum Selesai',
          deadline: current?.deadline);
        if (current == null) { await repo.tambah(model); }
        else { await repo.ubah(model); }
        await refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan revisi: $e')));
      }
    }
    title.dispose(); note.dispose();
  }

  Future<void> toggle(RevisiModel item) async {
    try {
      await repo.ubah(RevisiModel(id: item.id, judul: item.judul,
        catatan: item.catatan, deadline: item.deadline,
        status: item.status == 'Selesai' ? 'Belum Selesai' : 'Selesai'));
      await refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status: $e')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: JadwalColors.cream,
    appBar: AppBar(title: const Text('Kelola Revisi Skripsi')),
    floatingActionButton: FloatingActionButton(
      backgroundColor: JadwalColors.olive,
      onPressed: () => edit(), child: const Icon(Icons.add, color: Colors.white)),
    body: items.isEmpty
      ? const Center(child: Text('Belum ada revisi. Tekan + untuk menambahkan.'))
      : ListView.builder(padding: const EdgeInsets.all(16), itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            return Card(color: Colors.white, child: ListTile(
              title: Text(item.judul),
              subtitle: Text('${item.catatan}\nStatus: ${item.status}'),
              isThreeLine: true,
              onTap: () => edit(item),
              leading: IconButton(
                icon: Icon(item.status == 'Selesai' ? Icons.check_circle : Icons.circle_outlined),
                onPressed: () => toggle(item)),
              trailing: IconButton(icon: const Icon(Icons.delete_outline),
                onPressed: item.id == null ? null : () async {
                  try { await repo.hapus(item.id!); await refresh(); }
                  catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus revisi: $e')));
                  }
                }),
            ));
          }),
  );
}
