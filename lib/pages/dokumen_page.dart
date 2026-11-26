
import 'package:flutter/material.dart';

import 'package:test/service/file_service.dart';
import 'package:test/widgets/skriva_dashboard_ui.dart';

class DokumenPage extends StatefulWidget {
  const DokumenPage({super.key});

  @override
  State<DokumenPage> createState() =>
      _DokumenPageState();
}

class _DokumenPageState extends State<DokumenPage> {
  static const blue = SkrivaDashColors.blue;
  static const dark = SkrivaDashColors.dark;

  List<StoredDocument> dokumen = [];

  bool loading = true;
  bool proses = false;

  @override
  void initState() {
    super.initState();
    muat();
  }

  // =====================================================
  // LOAD DOCUMENT
  // =====================================================

  Future<void> muat() async {
    try {
      final hasil =
          await FileService.instance.getSavedDocuments();

      if (!mounted) return;

      setState(() {
        dokumen = hasil;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      pesan('Gagal memuat dokumen: $e');
    }
  }

  void pesan(String isi) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isi),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =====================================================
  // UPLOAD DOCUMENT
  // =====================================================

  Future<void> upload() async {
    if (proses) return;

    setState(() => proses = true);

    try {
      final hasil =
          await FileService.instance.pickAndSave();

      if (hasil == null) return;

      await muat();
      pesan('${hasil.name} berhasil disimpan.');
    } on FileServiceException catch (e) {
      pesan(e.message);
    } catch (e) {
      pesan('Gagal mengunggah dokumen: $e');
    } finally {
      if (mounted) {
        setState(() => proses = false);
      }
    }
  }

  Future<void> buka(
    StoredDocument item,
  ) async {
    try {
      await FileService.instance.openDocument(item.path);
    } on FileServiceException catch (e) {
      pesan(e.message);
    }
  }

  // =====================================================
  // DELETE DOCUMENT
  // =====================================================

  Future<void> hapus(
    StoredDocument item,
  ) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Dokumen?'),
        content: Text(
          'Dokumen "${item.name}" akan dihapus.',
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
      await FileService.instance.deleteDocument(item.path);
      await muat();
      pesan('Dokumen berhasil dihapus.');
    } on FileServiceException catch (e) {
      pesan(e.message);
    }
  }

  // =====================================================
  // DOCUMENT CARD
  // =====================================================

  Widget kartuDokumen(
    StoredDocument item,
    int index,
  ) {
    const warna = [
      SkrivaDashColors.softBlue,
      SkrivaDashColors.lime,
      SkrivaDashColors.peach,
      SkrivaDashColors.lavender,
    ];

    final pdf = item.extension == 'PDF';

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: InkWell(
        onTap: () => buka(item),
        borderRadius: BorderRadius.circular(24),
        child: SkrivaGlassCard(
          tint: warna[index % warna.length],
          child: Row(
            children: [
              Container(
                width: 50,
                height: 55,
                decoration: BoxDecoration(
                  color: warna[index % warna.length],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  pdf
                      ? Icons.picture_as_pdf_rounded
                      : Icons.description_rounded,
                  color: blue,
                  size: 27,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: dark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: SkrivaDashColors.muted,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Ketuk untuk membuka dokumen',
                      style: TextStyle(
                        color: blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: blue,
                ),
                onSelected: (value) {
                  if (value == 'open') {
                    buka(item);
                  } else if (value == 'delete') {
                    hapus(item);
                  }
                },
                itemBuilder: (ctx) => const [
                  PopupMenuItem(
                    value: 'open',
                    child: Text('Buka Dokumen'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Hapus Dokumen'),
                  ),
                ],
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
    return Scaffold(
      backgroundColor: SkrivaDashColors.background,
      appBar: AppBar(
        title: const Text('Dokumen Skripsi'),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: muat,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: proses ? null : upload,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload File'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              color: blue,
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
                    eyebrow: 'STUDENT / DOCUMENTS',
                    title: 'Your Files.\nYour Work.',
                    subtitle:
                        'Keep your thesis documents in one place.',
                    icon: Icons.folder_copy_rounded,
                  ),

                  const SizedBox(height: 25),

                  SkrivaSectionTitle(
                    title: 'My Documents',
                    subtitle:
                        '${dokumen.length} file tersimpan',
                  ),

                  const SizedBox(height: 15),

                  if (dokumen.isEmpty)
                    const SkrivaGlassCard(
                      tint: SkrivaDashColors.softBlue,
                      child: Column(
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            color: blue,
                            size: 42,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada dokumen.',
                            style: TextStyle(
                              color: dark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'Tekan Upload File untuk menyimpan dokumen.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: SkrivaDashColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ...List.generate(
                    dokumen.length,
                    (index) => kartuDokumen(
                      dokumen[index],
                      index,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
