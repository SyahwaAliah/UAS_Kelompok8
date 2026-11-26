
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/widgets/skriva_dashboard_ui.dart';

// =====================================================
// NOTES PAGE
// =====================================================

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  static const blue = SkrivaDashColors.blue;
  static const dark = SkrivaDashColors.dark;

  List<Map<String, Object?>> notes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<void> muat() async {
    try {
      final db = await _NotesStore.database();
      final id = await _NotesStore.akunId();

      final rows = await db.query(
        'skriva_notes',
        where: 'akun_id = ?',
        whereArgs: [id],
        orderBy: 'diperbarui DESC, id DESC',
      );

      if (!mounted) return;

      setState(() {
        notes = rows;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      pesan('Gagal memuat Notes: $e');
    }
  }

  void pesan(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> bukaEditor([int? noteId]) async {
    final berubah = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _NoteEditorPage(noteId: noteId),
      ),
    );

    if (berubah == true && mounted) {
      await muat();
    }
  }

  Future<void> hapusCatatan(
    Map<String, Object?> item,
  ) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text(
          'Catatan "${item['judul']}" beserta lampirannya '
          'akan dihapus.',
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

    try {
      await _NotesStore.hapusCatatan(
        item['id'] as int,
      );

      await muat();
      pesan('Catatan berhasil dihapus.');
    } catch (e) {
      pesan('Gagal menghapus catatan: $e');
    }
  }

  Widget kartuNote(
    Map<String, Object?> item,
    int index,
  ) {
    const warna = [
      SkrivaDashColors.lime,
      SkrivaDashColors.softBlue,
      SkrivaDashColors.peach,
      SkrivaDashColors.lavender,
    ];

    final tint = warna[index % warna.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SkrivaGlassCard(
        tint: tint,
        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.sticky_note_2_rounded,
                color: dark,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: InkWell(
                onTap: () => bukaEditor(item['id'] as int),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['judul']?.toString() ?? 'Tanpa Judul',
                      style: const TextStyle(
                        color: dark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      (item['isi']?.toString() ?? '').isEmpty
                          ? 'Ketuk untuk melihat catatan & lampiran.'
                          : item['isi'].toString(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SkrivaDashColors.muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 9),

                    const Row(
                      children: [
                        Icon(
                          Icons.attach_file_rounded,
                          size: 15,
                          color: blue,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Buka catatan & lampiran',
                          style: TextStyle(
                            color: blue,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            IconButton(
              tooltip: 'Hapus',
              onPressed: () => hapusCatatan(item),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkrivaDashColors.background,
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            onPressed: muat,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => bukaEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Note'),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: blue),
            )
          : RefreshIndicator(
              onRefresh: muat,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  100,
                ),
                children: [
                  const SkrivaDashboardHero(
                    eyebrow: 'STUDENT / NOTES',
                    title: 'Write It.\nKeep It.',
                    subtitle:
                        'Your thoughts, images and documents.',
                    icon: Icons.sticky_note_2_rounded,
                  ),

                  const SizedBox(height: 24),

                  SkrivaSectionTitle(
                    title: 'Your Notes',
                    subtitle: '${notes.length} catatan tersimpan',
                  ),

                  const SizedBox(height: 15),

                  if (notes.isEmpty)
                    const SkrivaGlassCard(
                      tint: SkrivaDashColors.lime,
                      child: Text(
                        'Belum ada catatan. '
                        'Tekan New Note untuk mulai menulis.',
                      ),
                    ),

                  ...List.generate(
                    notes.length,
                    (i) => kartuNote(notes[i], i),
                  ),
                ],
              ),
            ),
    );
  }
}

// =====================================================
// NOTES DATABASE & FILE STORAGE
// =====================================================

class _NotesStore {
  static const allowedExtensions = [
    'pdf',
    'doc',
    'docx',
    'png',
    'jpg',
    'jpeg',
  ];

  static const maxFileSize = 15 * 1024 * 1024;

  static Future<int> akunId() async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (akun == null) {
      throw StateError('Silakan login kembali.');
    }

    return akun['id'] as int;
  }

  static Future<Database> database() async {
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        akun_id INTEGER NOT NULL,
        judul TEXT NOT NULL,
        isi TEXT NOT NULL,
        diperbarui TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_notes_lampiran (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        note_id INTEGER NOT NULL,
        akun_id INTEGER NOT NULL,
        nama_file TEXT NOT NULL,
        lokasi_file TEXT NOT NULL,
        ukuran_file INTEGER NOT NULL,
        dibuat_pada TEXT NOT NULL
      )
    ''');

    return db;
  }

  static Future<Directory> folder(
    int akunId,
    int noteId,
  ) async {
    final root = await getApplicationDocumentsDirectory();

    return Directory(
      p.join(
        root.path,
        'skriva_notes_attachments',
        '$akunId',
        '$noteId',
      ),
    );
  }

  static Future<Map<String, Object?>> ambilCatatan(
    int noteId,
  ) async {
    final id = await akunId();
    final db = await database();

    final rows = await db.query(
      'skriva_notes',
      where: 'id = ? AND akun_id = ?',
      whereArgs: [noteId, id],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw StateError('Catatan tidak ditemukan.');
    }

    return rows.first;
  }

  static Future<List<Map<String, Object?>>> lampiran(
    int noteId,
  ) async {
    await ambilCatatan(noteId);

    final id = await akunId();
    final db = await database();

    return db.query(
      'skriva_notes_lampiran',
      where: 'note_id = ? AND akun_id = ?',
      whereArgs: [noteId, id],
      orderBy: 'id DESC',
    );
  }

  static Future<int> simpanCatatan({
    int? noteId,
    required String judul,
    required String isi,
  }) async {
    final id = await akunId();
    final db = await database();

    final data = <String, Object?>{
      'akun_id': id,
      'judul': judul.isEmpty ? 'Tanpa Judul' : judul,
      'isi': isi,
      'diperbarui': DateTime.now().toIso8601String(),
    };

    if (noteId == null) {
      return db.insert('skriva_notes', data);
    }

    final count = await db.update(
      'skriva_notes',
      data,
      where: 'id = ? AND akun_id = ?',
      whereArgs: [noteId, id],
    );

    if (count != 1) {
      throw StateError('Catatan tidak ditemukan.');
    }

    return noteId;
  }

  static Future<void> simpanLampiran(
    int noteId,
    PlatformFile picked,
  ) async {
    await ambilCatatan(noteId);

    final id = await akunId();
    final db = await database();

    final ext = p.extension(picked.name)
        .replaceFirst('.', '')
        .toLowerCase();

    if (!allowedExtensions.contains(ext)) {
      throw StateError('Format file tidak didukung.');
    }

    if (picked.path == null || picked.path!.isEmpty) {
      throw StateError('File tidak dapat dibaca.');
    }

    final source = File(picked.path!);

    if (!await source.exists()) {
      throw StateError('File sumber tidak ditemukan.');
    }

    final size = await source.length();

    if (size > maxFileSize) {
      throw StateError('Maksimal 15 MB per lampiran.');
    }

    final dir = await folder(id, noteId);
    await dir.create(recursive: true);

    final filename =
        '${DateTime.now().microsecondsSinceEpoch}.$ext';

    final target = File(p.join(dir.path, filename));

    await source.copy(target.path);

    try {
      await db.insert(
        'skriva_notes_lampiran',
        {
          'note_id': noteId,
          'akun_id': id,
          'nama_file': picked.name,
          'lokasi_file': target.path,
          'ukuran_file': size,
          'dibuat_pada': DateTime.now().toIso8601String(),
        },
      );
    } catch (_) {
      if (await target.exists()) {
        await target.delete();
      }
      rethrow;
    }
  }

  static Future<File> ambilFile(
    int noteId,
    int lampiranId,
  ) async {
    await ambilCatatan(noteId);

    final id = await akunId();
    final db = await database();

    final rows = await db.query(
      'skriva_notes_lampiran',
      where: 'id = ? AND note_id = ? AND akun_id = ?',
      whereArgs: [lampiranId, noteId, id],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw StateError('Lampiran tidak ditemukan.');
    }

    final path = p.normalize(
      p.absolute(rows.first['lokasi_file'].toString()),
    );

    final dir = await folder(id, noteId);

    final base = p.normalize(p.absolute(dir.path));

    if (!p.isWithin(base, path)) {
      throw StateError('Lokasi lampiran tidak diizinkan.');
    }

    final file = File(path);

    if (!await file.exists()) {
      throw StateError('File tidak ditemukan.');
    }

    return file;
  }

  static Future<void> hapusLampiran(
    int noteId,
    int lampiranId,
  ) async {
    final file = await ambilFile(noteId, lampiranId);
    final id = await akunId();
    final db = await database();

    await db.delete(
      'skriva_notes_lampiran',
      where: 'id = ? AND note_id = ? AND akun_id = ?',
      whereArgs: [lampiranId, noteId, id],
    );

    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> hapusCatatan(int noteId) async {
    await ambilCatatan(noteId);

    final id = await akunId();
    final db = await database();

    await db.transaction((txn) async {
      await txn.delete(
        'skriva_notes_lampiran',
        where: 'note_id = ? AND akun_id = ?',
        whereArgs: [noteId, id],
      );

      await txn.delete(
        'skriva_notes',
        where: 'id = ? AND akun_id = ?',
        whereArgs: [noteId, id],
      );
    });

    final dir = await folder(id, noteId);

    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}

// =====================================================
// NOTE EDITOR
// =====================================================

class _NoteEditorPage extends StatefulWidget {
  final int? noteId;

  const _NoteEditorPage({
    this.noteId,
  });

  @override
  State<_NoteEditorPage> createState() =>
      _NoteEditorPageState();
}

class _NoteEditorPageState extends State<_NoteEditorPage> {
  static const blue = SkrivaDashColors.blue;
  static const dark = SkrivaDashColors.dark;

  final judul = TextEditingController();
  final isi = TextEditingController();

  int? savedId;

  List<Map<String, Object?>> files = [];
  List<PlatformFile> pendingFiles = [];

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    savedId = widget.noteId;
    muat();
  }

  @override
  void dispose() {
    judul.dispose();
    isi.dispose();
    super.dispose();
  }

  Future<void> muat() async {
    try {
      if (savedId != null) {
        final note = await _NotesStore.ambilCatatan(
          savedId!,
        );

        final daftar = await _NotesStore.lampiran(
          savedId!,
        );

        judul.text = note['judul']?.toString() ?? '';
        isi.text = note['isi']?.toString() ?? '';

        files = daftar;
      }

      if (!mounted) return;

      setState(() => loading = false);
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      pesan('Gagal membuka catatan: $e');
    }
  }

  void pesan(String value) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }

  Future<void> pilihFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _NotesStore.allowedExtensions,
        allowMultiple: true,
      );

      if (result == null) return;

      for (final item in result.files) {
        if (item.path == null) {
          throw StateError(
            '${item.name} tidak dapat dibaca.',
          );
        }

        if (item.size > _NotesStore.maxFileSize) {
          throw StateError(
            '${item.name} melebihi batas 15 MB.',
          );
        }
      }

      if (!mounted) return;

      setState(() {
        pendingFiles.addAll(result.files);
      });
    } catch (e) {
      pesan('Gagal memilih file: $e');
    }
  }

  Future<void> simpan() async {
    if (saving) return;

    if (judul.text.trim().isEmpty &&
        isi.text.trim().isEmpty &&
        pendingFiles.isEmpty &&
        files.isEmpty) {
      pesan('Isi catatan atau tambahkan lampiran.');
      return;
    }

    setState(() => saving = true);

    try {
      savedId = await _NotesStore.simpanCatatan(
        noteId: savedId,
        judul: judul.text.trim(),
        isi: isi.text.trim(),
      );

      // Jika satu file gagal, file lain yang sudah
      // tersimpan tetap aman dan belum dihapus.
      for (final picked in List<PlatformFile>.from(
        pendingFiles,
      )) {
        await _NotesStore.simpanLampiran(savedId!, picked);
        pendingFiles.remove(picked);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (savedId != null) {
        try {
          files = await _NotesStore.lampiran(savedId!);
        } catch (_) {}
      }

      pesan('Gagal menyimpan: $e');
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  Future<void> bukaLampiran(
    Map<String, Object?> item,
  ) async {
    if (savedId == null) return;

    try {
      final file = await _NotesStore.ambilFile(
        savedId!,
        item['id'] as int,
      );

      final ext = p.extension(file.path).toLowerCase();

      if (ext == '.png' ||
          ext == '.jpg' ||
          ext == '.jpeg') {
        if (!mounted) return;

        await showDialog<void>(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: InteractiveViewer(
                    child: Image.file(file),
                  ),
                ),

                Positioned(
                  right: 6,
                  top: 6,
                  child: IconButton.filled(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        final result = await OpenFilex.open(file.path);

        if (result.type != ResultType.done) {
          throw StateError(
            'Tidak ada aplikasi untuk membuka file.',
          );
        }
      }
    } catch (e) {
      pesan('Gagal membuka lampiran: $e');
    }
  }

  Future<void> hapusLampiran(
    Map<String, Object?> item,
  ) async {
    if (savedId == null) return;

    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Lampiran?'),
        content: Text(
          item['nama_file']?.toString() ?? '',
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

    try {
      await _NotesStore.hapusLampiran(
        savedId!,
        item['id'] as int,
      );

      final daftar = await _NotesStore.lampiran(savedId!);

      if (!mounted) return;

      setState(() => files = daftar);
    } catch (e) {
      pesan('Gagal menghapus lampiran: $e');
    }
  }

  String ukuran(int size) {
    if (size >= 1048576) {
      return '${(size / 1048576).toStringAsFixed(1)} MB';
    }

    if (size >= 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    }

    return '$size B';
  }

  Widget kartuLampiran(
    String nama,
    String ukuranFile, {
    VoidCallback? onOpen,
    VoidCallback? onDelete,
  }) {
    final ext = p.extension(nama).toLowerCase();

    final isImage =
        ext == '.png' || ext == '.jpg' || ext == '.jpeg';

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: SkrivaDashColors.softBlue
            .withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: SkrivaDashColors.lime,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isImage
                  ? Icons.image_rounded
                  : Icons.description_rounded,
              color: dark,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: InkWell(
              onTap: onOpen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: dark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ukuranFile,
                    style: const TextStyle(
                      color: SkrivaDashColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (onOpen != null)
            IconButton(
              tooltip: 'Buka',
              onPressed: onOpen,
              icon: const Icon(
                Icons.open_in_new_rounded,
                color: blue,
              ),
            ),

          if (onDelete != null)
            IconButton(
              tooltip: 'Hapus',
              onPressed: onDelete,
              icon: const Icon(
                Icons.close_rounded,
                color: blue,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkrivaDashColors.background,

      appBar: AppBar(
        title: Text(
          savedId == null ? 'New Note' : 'Edit Note',
        ),
        actions: [
          TextButton.icon(
            onPressed: saving ? null : simpan,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Simpan'),
          ),
        ],
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: blue),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                40,
              ),
              children: [
                const SkrivaDashboardHero(
                  eyebrow: 'SKRIVA / NOTE EDITOR',
                  title: 'Capture\nYour Ideas.',
                  subtitle:
                      'Save your writing and attachments.',
                  icon: Icons.edit_note_rounded,
                ),

                const SizedBox(height: 20),

                SkrivaGlassCard(
                  tint: SkrivaDashColors.softBlue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: judul,
                        maxLines: 2,
                        minLines: 1,
                        style: const TextStyle(
                          color: dark,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Judul catatan...',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),

                      const Divider(),

                      TextField(
                        controller: isi,
                        minLines: 7,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText: 'Tulis catatan di sini...',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                const SkrivaSectionTitle(
                  title: 'Attachments',
                  subtitle:
                      'PDF, Word, PNG, JPG, JPEG • Maks. 15 MB/file',
                ),

                const SizedBox(height: 12),

                SkrivaGlassCard(
                  tint: SkrivaDashColors.lime,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: saving ? null : pilihFile,
                        icon: const Icon(
                          Icons.attach_file_rounded,
                        ),
                        label: const Text('Add Attachments'),
                      ),

                      const SizedBox(height: 13),

                      if (files.isEmpty && pendingFiles.isEmpty)
                        const Text(
                          'Belum ada lampiran.',
                          style: TextStyle(
                            color: SkrivaDashColors.muted,
                            fontSize: 12,
                          ),
                        ),

                      ...files.map((file) {
                        return kartuLampiran(
                          file['nama_file']?.toString() ?? '',
                          ukuran(
                            file['ukuran_file'] as int? ?? 0,
                          ),
                          onOpen: () => bukaLampiran(file),
                          onDelete: saving
                              ? null
                              : () => hapusLampiran(file),
                        );
                      }),

                      ...pendingFiles.asMap().entries.map(
                        (entry) {
                          final index = entry.key;
                          final file = entry.value;

                          return kartuLampiran(
                            file.name,
                            '${ukuran(file.size)} • Belum disimpan',
                            onDelete: saving
                                ? null
                                : () {
                                    setState(() {
                                      pendingFiles.removeAt(index);
                                    });
                                  },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 21),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: saving ? null : simpan,
                    style: FilledButton.styleFrom(
                      backgroundColor: blue,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.save_rounded),
                    label: Text(
                      saving ? 'Menyimpan...' : 'Save Note',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
