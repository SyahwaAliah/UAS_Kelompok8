import 'package:flutter/material.dart';
import 'package:test/theme/jadwal_theme.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/repositories/checklist_repository.dart';
import 'package:test/models/checklist_model.dart';

import 'checklist_page.dart';

class ProgressSkripsiPage extends StatefulWidget {
  const ProgressSkripsiPage({super.key});

  @override
  State<ProgressSkripsiPage> createState() => _ProgressSkripsiPageState();
}

class _ProgressSkripsiPageState extends State<ProgressSkripsiPage> {
  static const olive = Color(0xFF694A47);
  static const darkOlive = Color(0xFF523B39);
  static const blue = Color(0xFF96C1C5);

  final _repo = ChecklistRepository();

  List<ChecklistModel> _tahapan = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muatProgress();
  }

  Future<void> _muatProgress() async {
    try {
      await DatabaseHelper.instance.siapkanChecklistAwal();
      final hasil = await _repo.semua();

      if (!mounted) return;

      setState(() {
        _tahapan = hasil;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat progress: $e')));
    }
  }

  int get _selesai => _tahapan.where((item) => item.selesai).length;

  int get _persen =>
      _tahapan.isEmpty ? 0 : ((_selesai / _tahapan.length) * 100).round();

  Future<void> _kelolaChecklist() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChecklistPage()),
    );

    if (mounted) await _muatProgress();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPage(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Progress Skripsi'),
          backgroundColor: olive,
          foregroundColor: Colors.white,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF0DE), Color(0xFFE5F0EF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: olive))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: olive,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Progress Skripsi',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '$_persen%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _persen / 100,
                              minHeight: 9,
                              backgroundColor: Colors.white30,
                              color: blue,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '$_selesai dari '
                            '${_tahapan.length} tahap selesai',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Tahapan Skripsi',
                      style: TextStyle(
                        color: darkOlive,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_tahapan.isEmpty)
                      const Text('Belum ada tahapan skripsi.'),
                    ..._tahapan.map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.selesai
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: item.selesai ? olive : blue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.kegiatan,
                                style: TextStyle(
                                  color: darkOlive,
                                  fontWeight: FontWeight.w600,
                                  decoration: item.selesai
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            Text(
                              item.selesai ? 'Selesai' : 'Belum',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _kelolaChecklist,
                      icon: const Icon(Icons.checklist),
                      label: const Text('Kelola Checklist Skripsi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: olive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(15),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
