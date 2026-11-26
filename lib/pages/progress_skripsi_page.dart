
import 'package:flutter/material.dart';

import 'package:test/database/progress_akun_service.dart';
import 'package:test/models/checklist_model.dart';
import 'package:test/widgets/skriva_dashboard_ui.dart';

import 'package:test/pages/checklist_page.dart';

class ProgressSkripsiPage extends StatefulWidget {
  const ProgressSkripsiPage({super.key});

  @override
  State<ProgressSkripsiPage> createState() =>
      _ProgressSkripsiPageState();
}

class _ProgressSkripsiPageState
    extends State<ProgressSkripsiPage> {
  static const blue = SkrivaDashColors.blue;
  static const dark = SkrivaDashColors.dark;
  static const lime = SkrivaDashColors.lime;

  final service = ProgressAkunService.instance;

  List<ChecklistModel> tahapan = [];

  bool loading = true;

  int get jumlahSelesai =>
      tahapan.where((item) => item.selesai).length;

  int get persen => tahapan.isEmpty
      ? 0
      : ((jumlahSelesai / tahapan.length) * 100).round();

  @override
  void initState() {
    super.initState();
    muatProgress();
  }

  // =====================================================
  // LOAD PROGRESS PER AKUN
  // =====================================================

  Future<void> muatProgress() async {
    try {
      final hasil = await service.semua();

      if (!mounted) return;

      setState(() {
        tahapan = hasil;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat progress: $e'),
        ),
      );
    }
  }

  // =====================================================
  // NAVIGATION
  // =====================================================

  Future<void> bukaChecklist() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChecklistPage(),
      ),
    );

    if (mounted) {
      await muatProgress();
    }
  }

  // =====================================================
  // TIMELINE ITEM
  // =====================================================

  Widget kartuTahapan(
    ChecklistModel item,
    int index,
  ) {
    final selesai = item.selesai;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selesai
                    ? lime
                    : SkrivaDashColors.softBlue,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Icon(
                selesai
                    ? Icons.check_rounded
                    : Icons.circle_outlined,
                color: selesai ? dark : blue,
                size: 21,
              ),
            ),

            if (index < tahapan.length - 1)
              Container(
                width: 2,
                height: 63,
                color: selesai
                    ? lime
                    : const Color(0xFFDDE6EF),
              ),
          ],
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: SkrivaGlassCard(
              tint: selesai
                  ? lime
                  : SkrivaDashColors.white,
              padding: const EdgeInsets.all(14),
              radius: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STEP ${index + 1}',
                    style: const TextStyle(
                      color: blue,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    item.kegiatan,
                    style: const TextStyle(
                      color: dark,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    selesai
                        ? 'Milestone completed'
                        : 'Waiting to be completed',
                    style: const TextStyle(
                      color: SkrivaDashColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // MAIN PROGRESS PAGE
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkrivaDashColors.background,
      appBar: AppBar(
        backgroundColor: SkrivaDashColors.background,
        foregroundColor: dark,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Progress Skripsi',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: blue,
              ),
            )
          : RefreshIndicator(
              color: blue,
              onRefresh: muatProgress,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  35,
                ),
                children: [
                  const SkrivaDashboardHero(
                    eyebrow: 'STUDENT / THESIS PROGRESS',
                    title: 'Every Step\nMatters.',
                    subtitle:
                        'See how far you have come and what comes next.',
                    icon: Icons.insights_rounded,
                  ),

                  const SizedBox(height: 20),

                  SkrivaGlassCard(
                    tint: SkrivaDashColors.softBlue,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'THESIS COMPLETION',
                          style: TextStyle(
                            color: blue,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$persen%',
                                    style: const TextStyle(
                                      color: dark,
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    '$jumlahSelesai dari ${tahapan.length} tahap',
                                    style: const TextStyle(
                                      color: SkrivaDashColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(height: 13),

                                  const Text(
                                    'Keep going, you got this!',
                                    style: TextStyle(
                                      color: blue,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SkrivaProgressDiagram(
                              percent: persen,
                              completed: jumlahSelesai,
                              total: tahapan.length,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: persen / 100,
                            minHeight: 9,
                            backgroundColor:
                                const Color(0xFFDCE8F0),
                            color: blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  const SkrivaSectionTitle(
                    title: 'Your Timeline',
                    subtitle:
                        'Perjalanan tahapan skripsimu.',
                  ),

                  const SizedBox(height: 15),

                  if (tahapan.isEmpty)
                    const SkrivaGlassCard(
                      tint: lime,
                      child: Text(
                        'Belum ada tahapan skripsi.',
                      ),
                    ),

                  ...List.generate(
                    tahapan.length,
                    (index) => kartuTahapan(
                      tahapan[index],
                      index,
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: bukaChecklist,
                      style: FilledButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      icon: const Icon(
                        Icons.checklist_rounded,
                      ),
                      label: const Text(
                        'Kelola Checklist Skripsi',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
