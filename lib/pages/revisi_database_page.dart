
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/database/revisi_bimbingan_service.dart';
import 'package:test/service/file_service.dart';
import 'package:test/widgets/skriva_dashboard_ui.dart';

// =====================================================
// REVISION PAGE
// =====================================================

class RevisiDatabasePage extends StatefulWidget {
  final int? fokusRevisiId;

  const RevisiDatabasePage({
    super.key,
    this.fokusRevisiId,
  });

  @override
  State<RevisiDatabasePage> createState() =>
      _RevisiDatabasePageState();
}

class _RevisiDatabasePageState
    extends State<RevisiDatabasePage> {
  static const blue = SkrivaDashColors.blue;
  static const dark = SkrivaDashColors.dark;
  static const lime = SkrivaDashColors.lime;

  final service = RevisiBimbinganService.instance;

  List<Map<String, Object?>> revisi = [];
  List<Map<String, Object?>> mahasiswa = [];

  Map<int, List<Map<String, Object?>>> lampiran = {};

  bool dosen = false;
  bool loading = true;
  bool proses = false;

  int? akunId;

  @override
  void initState() {
    super.initState();
    muat();
  }

  // =====================================================
  // ATTACHMENT DATABASE
  // =====================================================

  Future<Database> get database async {
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_lampiran_revisi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        revisi_id INTEGER NOT NULL,
        mahasiswa_id INTEGER NOT NULL,
        nama_file TEXT NOT NULL,
        lokasi_file TEXT NOT NULL,
        ukuran_file INTEGER NOT NULL DEFAULT 0,
        dibuat_pada TEXT NOT NULL
      )
    ''');

    return db;
  }

  // =====================================================
  // LOAD DATA
  // =====================================================

  Future<void> muat() async {
    try {
      final user = await AuthDatabase.instance.sesiAktif();

      if (user == null) {
        throw StateError('Silakan login kembali.');
      }

      final isDosen = user['role'] == 'dosen';
      final rows = await service.semua();

      final daftarMahasiswa = isDosen
          ? await AuthDatabase.instance.mahasiswaBimbingan(
              user['id'] as int,
            )
          : <Map<String, Object?>>[];

      final db = await database;

      final hasilLampiran =
          <int, List<Map<String, Object?>>>{};

      for (final item in rows) {
        final revisionId = item['id'] as int;

        hasilLampiran[revisionId] = await db.query(
          'skriva_lampiran_revisi',
          where: 'revisi_id = ? AND mahasiswa_id = ?',
          whereArgs: [
            revisionId,
            item['mahasiswa_id'],
          ],
          orderBy: 'dibuat_pada DESC, id DESC',
        );
      }

      if (!mounted) return;

      setState(() {
        akunId = user['id'] as int;
        dosen = isDosen;
        revisi = rows;
        mahasiswa = daftarMahasiswa;
        lampiran = hasilLampiran;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      pesan('Gagal memuat revisi: $e');
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
  // CREATE REVISION - DOSEN
  // =====================================================

  Future<void> tambahRevisi() async {
    if (mahasiswa.isEmpty) {
      pesan('Belum ada mahasiswa bimbingan.');
      return;
    }

    int mahasiswaId = mahasiswa.first['id'] as int;

    final judul = TextEditingController();
    final instruksi = TextEditingController();

    DateTime? deadline;

    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          backgroundColor: SkrivaDashColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Buat Revisi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: mahasiswaId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Mahasiswa',
                  ),
                  items: mahasiswa.map((item) {
                    return DropdownMenuItem<int>(
                      value: item['id'] as int,
                      child: Text(
                        item['nama']?.toString() ?? '-',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      update(() => mahasiswaId = value);
                    }
                  },
                ),

                const SizedBox(height: 13),

                TextField(
                  controller: judul,
                  decoration: const InputDecoration(
                    labelText: 'Judul Revisi',
                  ),
                ),

                const SizedBox(height: 13),

                TextField(
                  controller: instruksi,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Instruksi Dosen',
                  ),
                ),

                const SizedBox(height: 13),

                OutlinedButton.icon(
                  icon: const Icon(Icons.event_rounded),
                  label: Text(
                    deadline == null
                        ? 'Pilih Deadline'
                        : '${deadline!.day}/${deadline!.month}/${deadline!.year}',
                  ),
                  onPressed: () async {
                    final tanggal = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 730),
                      ),
                    );

                    if (tanggal != null) {
                      update(() => deadline = tanggal);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    final title = judul.text.trim();
    final note = instruksi.text.trim();

    judul.dispose();
    instruksi.dispose();

    if (yes != true) return;

    await aksi(() async {
      await service.buat(
        mahasiswaId: mahasiswaId,
        judul: title,
        catatan: note,
        deadline: deadline?.toIso8601String().substring(0, 10),
      );

      pesan('Revisi berhasil dibuat.');
    });
  }

  // =====================================================
  // UPLOAD ATTACHMENT - MAHASISWA
  // =====================================================

  Future<void> uploadLampiran(
    Map<String, Object?> item,
  ) async {
    if (dosen || proses) return;

    final revisionId = item['id'] as int;
    final mahasiswaId = item['mahasiswa_id'] as int;
    final status = item['status']?.toString() ?? '';

    if (mahasiswaId != akunId) {
      pesan('Revisi bukan milik akun ini.');
      return;
    }

    if (status != 'Dalam Pengerjaan' &&
        status != 'Perlu Perbaikan') {
      pesan(
        'Mulai kerjakan revisi terlebih dahulu '
        'sebelum mengunggah lampiran.',
      );
      return;
    }

    final dipilih = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
      ],
      allowMultiple: false,
    );

    if (dipilih == null) return;

    final picked = dipilih.files.single;
    final sourcePath = picked.path;

    if (sourcePath == null) {
      pesan('File tidak ditemukan.');
      return;
    }

    await aksi(() async {
      final db = await database;

      final rows = await db.query(
        'skriva_revisi',
        where: '''
          id = ?
          AND mahasiswa_id = ?
          AND status IN ('Dalam Pengerjaan', 'Perlu Perbaikan')
        ''',
        whereArgs: [revisionId, mahasiswaId],
        limit: 1,
      );

      if (rows.isEmpty) {
        throw StateError(
          'Revisi tidak ditemukan atau status sudah berubah.',
        );
      }

      final source = File(sourcePath);

      if (!await source.exists()) {
        throw StateError('File sumber tidak ditemukan.');
      }

      final size = await source.length();

      if (size > 15 * 1024 * 1024) {
        throw StateError('Maksimal 15 MB per lampiran.');
      }

      final ext = picked.extension?.toLowerCase() ?? '';

      if (!['pdf', 'doc', 'docx'].contains(ext)) {
        throw StateError('Format file tidak didukung.');
      }

      final dbPath = await getDatabasesPath();

      final folder = Directory(
        '$dbPath/skriva_lampiran/$mahasiswaId/$revisionId',
      );

      await folder.create(recursive: true);

      final target = File(
        '${folder.path}/'
        '${DateTime.now().microsecondsSinceEpoch}.$ext',
      );

      await source.copy(target.path);

      try {
        await db.insert(
          'skriva_lampiran_revisi',
          {
            'revisi_id': revisionId,
            'mahasiswa_id': mahasiswaId,
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

      pesan('Lampiran berhasil diunggah.');
    });
  }

  // =====================================================
  // OPEN ATTACHMENT
  // =====================================================

  Future<void> bukaLampiran(
    Map<String, Object?> item,
    Map<String, Object?> file,
  ) async {
    try {
      await FileService.instance.openRevisiAttachment(
        revisiId: item['id'] as int,
        lampiranId: file['id'] as int,
      );
    } catch (e) {
      pesan('Gagal membuka lampiran: $e');
    }
  }

  // =====================================================
  // DELETE ATTACHMENT - MAHASISWA
  // =====================================================

  Future<void> hapusLampiran(
    Map<String, Object?> item,
    Map<String, Object?> file,
  ) async {
    if (dosen || proses) return;

    final status = item['status']?.toString() ?? '';

    if (status != 'Dalam Pengerjaan' &&
        status != 'Perlu Perbaikan') {
      pesan('Lampiran tidak bisa dihapus setelah dikirim.');
      return;
    }

    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Lampiran?'),
        content: Text(
          file['nama_file']?.toString() ?? '',
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

    await aksi(() async {
      final db = await database;

      final rows = await db.rawQuery(
        '''
        SELECT l.*
        FROM skriva_lampiran_revisi l
        JOIN skriva_revisi r ON r.id = l.revisi_id
        WHERE l.id = ?
          AND l.revisi_id = ?
          AND l.mahasiswa_id = ?
          AND r.mahasiswa_id = ?
          AND r.status IN (
            'Dalam Pengerjaan',
            'Perlu Perbaikan'
          )
        LIMIT 1
        ''',
        [
          file['id'],
          item['id'],
          akunId,
          akunId,
        ],
      );

      if (rows.isEmpty) {
        throw StateError('Lampiran tidak bisa dihapus.');
      }

      await db.delete(
        'skriva_lampiran_revisi',
        where: 'id = ? AND mahasiswa_id = ?',
        whereArgs: [file['id'], akunId],
      );

      final lokasi = rows.first['lokasi_file'].toString();
      final root = await getDatabasesPath();

      final base = Directory(
        '$root/skriva_lampiran/$akunId/${item['id']}',
      ).absolute.path;

      final target = File(lokasi).absolute.path;

      if (target.startsWith('$base${Platform.pathSeparator}')) {
        final dokumen = File(target);

        if (await dokumen.exists()) {
          await dokumen.delete();
        }
      }

      pesan('Lampiran berhasil dihapus.');
    });
  }

  // =====================================================
  // SEND REVISION RESULT
  // =====================================================

  Future<void> kirimHasil(
    Map<String, Object?> item,
  ) async {
    final controller = TextEditingController(
      text: item['tanggapan_mahasiswa']?.toString() ?? '',
    );

    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SkrivaDashColors.background,
        title: const Text('Kirim Hasil Revisi'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText:
                'Jelaskan apa yang sudah kamu perbaiki...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kirim ke Dosen'),
          ),
        ],
      ),
    );

    final tanggapan = controller.text.trim();
    controller.dispose();

    if (yes != true) return;

    await aksi(() async {
      await service.kirimHasil(
        item['id'] as int,
        tanggapan,
      );

      pesan('Hasil revisi berhasil dikirim.');
    });
  }

  // =====================================================
  // REVIEW - DOSEN
  // =====================================================

  Future<void> review(
    Map<String, Object?> item,
    bool disetujui,
  ) async {
    final controller = TextEditingController();

    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SkrivaDashColors.background,
        title: Text(
          disetujui
              ? 'Setujui Revisi?'
              : 'Minta Perbaikan?',
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: disetujui
                ? 'Komentar (opsional)'
                : 'Alasan perbaikan (wajib)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    final feedback = controller.text.trim();
    controller.dispose();

    if (yes != true) return;

    await aksi(() async {
      await service.review(
        revisiId: item['id'] as int,
        disetujui: disetujui,
        feedback: feedback,
      );

      pesan('Review berhasil disimpan.');
    });
  }

  // =====================================================
  // STATUS BADGE
  // =====================================================

  Color warnaStatus(String status) {
    switch (status) {
      case 'Selesai':
        return lime;
      case 'Menunggu Review':
        return SkrivaDashColors.softBlue;
      case 'Perlu Perbaikan':
        return SkrivaDashColors.peach;
      case 'Dalam Pengerjaan':
        return SkrivaDashColors.lavender;
      default:
        return const Color(0xFFE8EEF5);
    }
  }

  Widget statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: warnaStatus(status),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: dark,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // =====================================================
  // ATTACHMENT CARD
  // =====================================================

  Widget kartuLampiran(
    Map<String, Object?> item,
  ) {
    final revisionId = item['id'] as int;

    final files = lampiran[revisionId] ??
        <Map<String, Object?>>[];

    final status = item['status']?.toString() ?? '';

    final bolehUpload = !dosen &&
        (status == 'Dalam Pengerjaan' ||
            status == 'Perlu Perbaikan');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFDDE8F2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.attach_file_rounded,
                color: blue,
                size: 19,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  'Attachments (${files.length})',
                  style: const TextStyle(
                    color: dark,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),

              if (bolehUpload)
                TextButton.icon(
                  onPressed: proses
                      ? null
                      : () => uploadLampiran(item),
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 17,
                  ),
                  label: const Text('Upload'),
                ),
            ],
          ),

          if (files.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Belum ada dokumen terlampir.',
                style: TextStyle(
                  color: SkrivaDashColors.muted,
                  fontSize: 11,
                ),
              ),
            ),

          ...files.map((file) {
            return Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SkrivaDashColors.background,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: SkrivaDashColors.softBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      color: blue,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: InkWell(
                      onTap: () => bukaLampiran(item, file),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            file['nama_file']?.toString() ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: dark,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            formatUkuran(
                              file['ukuran_file'] as int? ?? 0,
                            ),
                            style: const TextStyle(
                              color: SkrivaDashColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  IconButton(
                    tooltip: 'Buka File',
                    onPressed: () => bukaLampiran(item, file),
                    icon: const Icon(
                      Icons.open_in_new_rounded,
                      color: blue,
                    ),
                  ),

                  if (bolehUpload)
                    IconButton(
                      tooltip: 'Hapus File',
                      onPressed: proses
                          ? null
                          : () => hapusLampiran(item, file),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: blue,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String formatUkuran(int bytes) {
    if (bytes < 1024) return '$bytes B';

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  // =====================================================
  // ACTION BUTTON
  // =====================================================

  Widget tombol(
    String label,
    VoidCallback onTap, {
    bool outlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              onPressed: proses ? null : onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: blue,
                padding: const EdgeInsets.all(13),
              ),
              child: Text(label),
            )
          : FilledButton(
              onPressed: proses ? null : onTap,
              style: FilledButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(13),
              ),
              child: Text(label),
            ),
    );
  }

  // =====================================================
  // REVISION CARD
  // =====================================================

  Widget kartuRevisi(
    Map<String, Object?> item,
  ) {
    final status = item['status']?.toString() ?? '';
    final revisionId = item['id'] as int;

    final hasil =
        item['tanggapan_mahasiswa']?.toString() ?? '';

    final feedback =
        item['umpan_balik_dosen']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: SkrivaGlassCard(
        tint: widget.fokusRevisiId == revisionId
            ? lime
            : warnaStatus(status),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: warnaStatus(status),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: blue,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    item['judul']?.toString() ?? '-',
                    style: const TextStyle(
                      color: dark,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            statusBadge(status),

            const SizedBox(height: 12),

            Text(
              dosen
                  ? 'Mahasiswa: ${item['nama_mahasiswa'] ?? '-'}'
                  : 'Dosen: ${item['nama_dosen'] ?? '-'}',
              style: const TextStyle(
                color: blue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 13),

            const Text(
              'Instruksi Revisi',
              style: TextStyle(
                color: dark,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              item['catatan']?.toString() ?? '-',
              style: const TextStyle(
                color: SkrivaDashColors.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),

            if (item['deadline'] != null) ...[
              const SizedBox(height: 11),

              Text(
                'Deadline: ${item['deadline']}',
                style: const TextStyle(
                  color: blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            if (hasil.isNotEmpty) ...[
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: SkrivaDashColors.softBlue
                      .withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hasil Mahasiswa',
                      style: TextStyle(
                        color: dark,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      hasil,
                      style: const TextStyle(
                        color: dark,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (feedback.isNotEmpty) ...[
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: lime.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Feedback Dosen',
                      style: TextStyle(
                        color: dark,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      feedback,
                      style: const TextStyle(
                        color: dark,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            kartuLampiran(item),

            const SizedBox(height: 15),

            if (!dosen &&
                (status == 'Belum Dikerjakan' ||
                    status == 'Perlu Perbaikan'))
              tombol(
                'Mulai Kerjakan',
                () => aksi(
                  () => service.mulai(revisionId),
                ),
              ),

            if (!dosen && status == 'Dalam Pengerjaan')
              tombol(
                'Kirim Hasil Revisi',
                () => kirimHasil(item),
              ),

            if (dosen && status == 'Menunggu Review') ...[
              tombol(
                'Setujui Revisi',
                () => review(item, true),
              ),

              const SizedBox(height: 9),

              tombol(
                'Minta Perbaikan',
                () => review(item, false),
                outlined: true,
              ),
            ],
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
    final daftar = [...revisi];

    if (widget.fokusRevisiId != null) {
      daftar.sort((a, b) {
        if (a['id'] == widget.fokusRevisiId) return -1;
        if (b['id'] == widget.fokusRevisiId) return 1;
        return 0;
      });
    }

    return Scaffold(
      backgroundColor: SkrivaDashColors.background,

      appBar: AppBar(
        backgroundColor: SkrivaDashColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: dark,
        title: Text(
          dosen ? 'Kelola Revisi' : 'Revisi Skripsi',
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

      floatingActionButton: dosen && !loading
          ? FloatingActionButton.extended(
              onPressed: proses ? null : tambahRevisi,
              backgroundColor: blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Buat Revisi'),
            )
          : null,

      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: blue),
            )
          : RefreshIndicator(
              color: blue,
              onRefresh: muat,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  100,
                ),
                children: [
                  SkrivaDashboardHero(
                    eyebrow: dosen
                        ? 'LECTURER / REVISION'
                        : 'STUDENT / REVISION',
                    title: dosen
                        ? 'Review.\nRefine. Guide.'
                        : 'Improve.\nOne Step at a Time.',
                    subtitle: dosen
                        ? 'Tinjau revisi dan dokumen mahasiswa.'
                        : 'Kerjakan revisi dan lampirkan dokumen.',
                    icon: Icons.rate_review_rounded,
                  ),

                  const SizedBox(height: 24),

                  SkrivaSectionTitle(
                    title: dosen
                        ? 'Student Revisions'
                        : 'My Revisions',
                    subtitle:
                        '${daftar.length} revisi tercatat',
                  ),

                  const SizedBox(height: 14),

                  if (daftar.isEmpty)
                    const SkrivaGlassCard(
                      tint: lime,
                      child: Text(
                        'Belum ada revisi.',
                      ),
                    ),

                  ...daftar.map(kartuRevisi),
                ],
              ),
            ),
    );
  }
}
