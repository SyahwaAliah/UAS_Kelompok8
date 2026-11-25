import 'package:flutter/material.dart';
import 'package:test/theme/jadwal_theme.dart';
import 'package:test/database/database_helper.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  static const olive = Color(0xFF694A47);
  static const darkOlive = Color(0xFF523B39);
  static const orange = Color(0xFF96C1C5);
  static const cream = Color(0xFFFFF0DE);
  static const lightOrange = Color(0xFFE5F0EF);

  final _judulController = TextEditingController();
  final _isiController = TextEditingController();

  int? _catatanId;
  bool _menyimpan = false;

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _simpanCatatan() async {
    if (_menyimpan) return;

    final judul = _judulController.text.trim();
    final isi = _isiController.text.trim();

    if (judul.isEmpty && isi.isEmpty) {
      _pesan('Isi judul atau catatan terlebih dahulu.');
      return;
    }

    setState(() => _menyimpan = true);

    try {
      final hasil = await DatabaseHelper.instance.simpanCatatan(
        id: _catatanId,
        judul: judul,
        isi: isi,
      );

      if (!mounted) return;

      if (_catatanId == null) {
        _catatanId = hasil;
      } else if (hasil == 0) {
        throw StateError('Catatan tidak ditemukan');
      }

      _pesan('Catatan berhasil disimpan.');
    } catch (e) {
      _pesan('Gagal menyimpan catatan: $e');
    } finally {
      if (mounted) {
        setState(() => _menyimpan = false);
      }
    }
  }

  void _pesan(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _catatanBaru() {
    setState(() {
      _catatanId = null;
      _judulController.clear();
      _isiController.clear();
    });
  }

  void _bukaCatatan(Map<String, Object?> item) {
    setState(() {
      _catatanId = item['id'] as int?;
      _judulController.text = item['judul'] as String? ?? '';
      _isiController.text = item['isi'] as String? ?? '';
    });
  }

  Future<void> _hapusCatatan() async {
    if (_catatanId == null) return;

    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: const Text('Catatan yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (setuju != true || !mounted) return;

    try {
      await DatabaseHelper.instance.hapusCatatan(_catatanId!);

      _catatanBaru();
      _pesan('Catatan berhasil dihapus.');
    } catch (e) {
      _pesan('Gagal menghapus catatan: $e');
    }
  }

  Future<void> _tampilkanDaftarCatatan() async {
    try {
      final items = await DatabaseHelper.instance.ambilCatatan();

      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: cream,
        isScrollControlled: true,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Daftar Catatan Pribadi',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: darkOlive,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Belum ada catatan tersimpan.'),
                    ),
                  if (items.isNotEmpty)
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final judul = item['judul'] as String? ?? '';
                          final isi = item['isi'] as String? ?? '';

                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              leading: const Icon(
                                Icons.sticky_note_2_rounded,
                                color: orange,
                              ),
                              title: Text(
                                judul.isEmpty ? 'Tanpa Judul' : judul,
                              ),
                              subtitle: Text(
                                isi,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                _bukaCatatan(item);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _catatanBaru();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Catatan Baru'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: olive,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      _pesan('Gagal memuat daftar catatan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPage(
      child: Scaffold(
        backgroundColor: cream,
        appBar: AppBar(
          title: const Text('Catatan Pribadi'),
          backgroundColor: olive,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _tampilkanDaftarCatatan,
              tooltip: 'Daftar Catatan',
              icon: const Icon(Icons.list_alt_rounded),
            ),
            IconButton(
              onPressed: _catatanBaru,
              tooltip: 'Catatan Baru',
              icon: const Icon(Icons.add),
            ),
            if (_catatanId != null)
              IconButton(
                onPressed: _hapusCatatan,
                tooltip: 'Hapus Catatan',
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _judulController,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkOlive,
                ),
                decoration: const InputDecoration(
                  hintText: 'Judul Catatan',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                ),
              ),
              Container(height: 2, width: double.infinity, color: lightOrange),
              const SizedBox(height: 15),
              Expanded(
                child: TextField(
                  controller: _isiController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: 'Mulai mengetik catatan bimbinganmu di sini',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: _menyimpan ? null : _simpanCatatan,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: orange,
                      shape: BoxShape.circle,
                    ),
                    child: _menyimpan
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
