import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/database/auth_database.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  static const brown = Color(0xFF694A47);
  static const cream = Color(0xFFFFF0DE);
  static const teal = Color(0xFF96C1C5);

  List<Map<String, Object?>> catatan = [];
  bool loading = true;

  Future<Database> get database async {
    await AuthDatabase.instance.sesiAktif();
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        akun_id INTEGER NOT NULL,
        judul TEXT NOT NULL,
        isi TEXT NOT NULL,
        diperbarui TEXT NOT NULL,
        FOREIGN KEY(akun_id) REFERENCES skriva_akun(id)
      )
    ''');

    return db;
  }

  Future<int> get akunId async {
    final akun = await AuthDatabase.instance.sesiAktif();
    if (akun == null) {
      throw StateError('Silakan login terlebih dahulu.');
    }
    return akun['id'] as int;
  }

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<void> muat() async {
    try {
      final id = await akunId;
      final db = await database;
      final rows = await db.query(
        'skriva_notes',
        where: 'akun_id = ?',
        whereArgs: [id],
        orderBy: 'diperbarui DESC, id DESC',
      );

      if (!mounted) return;
      setState(() {
        catatan = rows;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat Notes: $e')),
      );
    }
  }

  Future<void> editor([Map<String, Object?>? item]) async {
    final judul = TextEditingController(
      text: item?['judul']?.toString() ?? '',
    );
    final isi = TextEditingController(
      text: item?['isi']?.toString() ?? '',
    );

    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => _EditorNotesPage(
          judul: judul,
          isi: isi,
          onSimpan: () async {
            final id = await akunId;
            final db = await database;

            final title = judul.text.trim();
            final body = isi.text.trim();

            if (title.isEmpty && body.isEmpty) {
              throw StateError('Isi catatan terlebih dahulu.');
            }

            final data = {
              'akun_id': id,
              'judul': title.isEmpty ? 'Tanpa Judul' : title,
              'isi': body,
              'diperbarui': DateTime.now().toIso8601String(),
            };

            if (item == null) {
              await db.insert('skriva_notes', data);
            } else {
              final count = await db.update(
                'skriva_notes',
                data,
                where: 'id = ? AND akun_id = ?',
                whereArgs: [item['id'], id],
              );
              if (count != 1) {
                throw StateError('Catatan tidak ditemukan.');
              }
            }
          },
        ),
      ),
    );

    judul.dispose();
    isi.dispose();

    if (hasil == true && mounted) {
      await muat();
    }
  }

  Future<void> hapus(Map<String, Object?> item) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text(
          'Catatan "${item['judul']}" akan dihapus.',
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

    if (setuju != true) return;

    try {
      final id = await akunId;
      final db = await database;
      await db.delete(
        'skriva_notes',
        where: 'id = ? AND akun_id = ?',
        whereArgs: [item['id'], id],
      );
      await muat();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            onPressed: muat,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => editor(),
        backgroundColor: brown,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: brown),
            )
          : RefreshIndicator(
              onRefresh: muat,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
                children: [
                  const Text(
                    'Your thoughts, your progress.',
                    style: TextStyle(
                      color: brown,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Simpan ide, catatan bimbingan, dan hal penting lainnya.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 22),
                  if (catatan.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(35),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 52,
                            color: teal,
                          ),
                          SizedBox(height: 10),
                          Text('Belum ada catatan.'),
                          SizedBox(height: 5),
                          Text('Tekan + untuk membuat catatan.'),
                        ],
                      ),
                    ),
                  ...catatan.map((item) {
                    final title =
                        item['judul']?.toString() ?? '';
                    final body = item['isi']?.toString() ?? '';

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        onTap: () => editor(item),
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(
                          Icons.sticky_note_2_outlined,
                          color: teal,
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            color: brown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            body.isEmpty
                                ? 'Tidak ada isi catatan'
                                : body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Hapus Catatan',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: brown,
                          ),
                          onPressed: () => hapus(item),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _EditorNotesPage extends StatefulWidget {
  final TextEditingController judul;
  final TextEditingController isi;
  final Future<void> Function() onSimpan;

  const _EditorNotesPage({
    required this.judul,
    required this.isi,
    required this.onSimpan,
  });

  @override
  State<_EditorNotesPage> createState() =>
      _EditorNotesPageState();
}

class _EditorNotesPageState extends State<_EditorNotesPage> {
  static const brown = Color(0xFF694A47);
  bool menyimpan = false;

  Future<void> simpan() async {
    if (menyimpan) return;
    setState(() => menyimpan = true);

    try {
      await widget.onSimpan();

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => menyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0DE),
      appBar: AppBar(
        title: const Text('Editor Notes'),
        actions: [
          TextButton.icon(
            onPressed: menyimpan ? null : simpan,
            icon: const Icon(Icons.check, color: brown),
            label: const Text(
              'Simpan',
              style: TextStyle(color: brown),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            TextField(
              controller: widget.judul,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
              decoration: const InputDecoration(
                hintText: 'Judul catatan...',
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: widget.isi,
                expands: true,
                maxLines: null,
                minLines: null,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Mulai menulis di sini...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
