import 'package:flutter/material.dart';
import 'package:test/widgets/empty_state.dart';
import 'package:test/theme/jadwal_theme.dart';
import 'package:test/models/checklist_model.dart';
import 'package:test/repositories/checklist_repository.dart';
import 'package:test/database/database_helper.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  static const primary = Color(0xFF694A47);
  static const darkPrimary = Color(0xFF523B39);

  final ChecklistRepository _repo = ChecklistRepository();
  List<ChecklistModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    try {
      await DatabaseHelper.instance.siapkanChecklistAwal();
      final rows = await _repo.semua();

      if (!mounted) return;

      setState(() {
        _items = rows;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showMessage('Gagal memuat checklist: $e');
    }
  }

  void _showMessage(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _toggleItem(ChecklistModel item) async {
    try {
      await _repo.ubah(
        ChecklistModel(
          id: item.id,
          kegiatan: item.kegiatan,
          selesai: !item.selesai,
        ),
      );

      await _loadItems();
    } catch (e) {
      _showMessage('Gagal mengubah status: $e');
    }
  }

  Future<void> _addItem() async {
    String title = '';

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Tahap'),
        content: TextField(
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Nama tahap, contoh: Bab 4',
          ),
          onChanged: (value) => title = value,
          onSubmitted: (value) {
            Navigator.pop(ctx, value.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, title.trim());
            },
            child: const Text('Tambah', style: TextStyle(color: primary)),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      await _repo.tambah(ChecklistModel(kegiatan: result));

      await _loadItems();
    } catch (e) {
      _showMessage('Gagal menambah tahap: $e');
    }
  }

  Future<void> _confirmDelete(ChecklistModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus tahap?'),
        content: Text(item.kegiatan),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: primary)),
          ),
        ],
      ),
    );

    if (confirm != true || item.id == null) return;

    try {
      await _repo.hapus(item.id!);
      await _loadItems();
    } catch (e) {
      _showMessage('Gagal menghapus tahap: $e');
    }
  }

  Widget itemChecklist(ChecklistModel item) {
    final selesai = item.selesai;

    return GestureDetector(
      onTap: () => _toggleItem(item),
      onLongPress: () => _confirmDelete(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: selesai ? primary : Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: selesai ? primary : Colors.grey,
                  width: 2,
                ),
              ),
              child: selesai
                  ? const Icon(Icons.check, size: 17, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.kegiatan,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: selesai ? TextDecoration.lineThrough : null,
                  color: selesai ? Colors.grey : darkPrimary,
                ),
              ),
            ),
            Icon(
              selesai ? Icons.check_circle : Icons.circle_outlined,
              color: selesai ? primary : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: primary));
    }

    if (_items.isEmpty) {
      return EmptyState(
        icon: Icons.checklist_rounded,
        title: 'Checklist masih kosong',
        message: 'Tambahkan tahap skripsi untuk mulai memantau progres kamu.',
        actionLabel: 'Tambah Tahap',
        onAction: _addItem,
      );
    }

    final selesaiCount = _items.where((item) => item.selesai).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              '$selesaiCount dari ${_items.length} tahap selesai',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          ..._items.map(itemChecklist),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPage(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF0DE), Color(0xFFE5F0EF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 17,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Progress Skripsi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
        floatingActionButton: _isLoading
            ? null
            : FloatingActionButton(
                backgroundColor: primary,
                onPressed: _addItem,
                child: const Icon(Icons.add, color: Colors.white),
              ),
      ),
    );
  }
}
