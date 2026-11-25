import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test/service/file_service.dart';
import 'package:test/theme/jadwal_theme.dart';

class DokumenPage extends StatefulWidget {
  const DokumenPage({super.key});

  @override
  State<DokumenPage> createState() => _DokumenPageState();
}

class _DokumenPageState extends State<DokumenPage> {
  static const primary = Color(0xFF694A47);
  static const darkPrimary = Color(0xFF523B39);
  static const orange = Color(0xFF96C1C5);

  List<StoredDocument> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  // ---------------------------------------------------------------
  // LOGIC
  // ---------------------------------------------------------------

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);

    try {
      final docs = await FileService.instance.getSavedDocuments();

      if (!mounted) return;

      setState(() {
        _documents = docs;
        _isLoading = false;
      });
    } on FileServiceException catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showMessage(e.message);
    }
  }

  Future<void> _uploadDocument() async {
    try {
      final doc = await FileService.instance.pickAndSave();

      if (doc == null) return;

      await _loadDocuments();

      _showMessage('${doc.name} berhasil disimpan.');
    } on FileServiceException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      debugPrint('upload error: $e');
      _showMessage('Terjadi kesalahan saat mengunggah dokumen.');
    }
  }

  Future<void> _openDocument(StoredDocument doc) async {
    try {
      await FileService.instance.openDocument(doc.path);
    } on FileServiceException catch (e) {
      _showMessage(e.message);
    }
  }

  Future<void> _confirmDelete(StoredDocument doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus dokumen?'),
          content: Text(doc.name),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: primary)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FileService.instance.deleteDocument(doc.path);
      await _loadDocuments();

      _showMessage('Dokumen berhasil dihapus.');
    } on FileServiceException catch (e) {
      _showMessage(e.message);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------

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
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: primary,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        'Dokumen Skripsi',
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

        floatingActionButton: FloatingActionButton(
          backgroundColor: primary,
          onPressed: _uploadDocument,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: primary));
    }

    if (_documents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open_rounded, size: 64, color: orange),
              SizedBox(height: 12),
              Text(
                'Belum ada dokumen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tekan tombol + untuk mengunggah dokumen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: primary,
      onRefresh: _loadDocuments,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 90),
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          return documentCard(_documents[index]);
        },
      ),
    );
  }

  Widget documentCard(StoredDocument doc) {
    final isPdf = doc.extension == 'PDF';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openDocument(doc),
          onLongPress: () => _confirmDelete(doc),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3F2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isPdf
                        ? Icons.picture_as_pdf_rounded
                        : Icons.description_rounded,
                    color: orange,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc.subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.open_in_new_rounded, color: orange),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
