
import 'package:flutter/material.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/service/skriva_chat_service.dart';
import 'package:test/pages/chat_detail_page.dart';
import 'package:test/widgets/skriva_dashboard_ui.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const blue = SkrivaDashColors.blue;
  static const dark = SkrivaDashColors.dark;

  List<Map<String, Object?>> pembimbing = [];
  Map<int, String> preview = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    muat();
  }

  // =====================================================
  // LOAD CHAT
  // =====================================================

  Future<void> muat() async {
    try {
      final akun = await AuthDatabase.instance.sesiAktif();

      if (akun == null || akun['role'] != 'mahasiswa') {
        throw StateError(
          'Halaman ini khusus mahasiswa.',
        );
      }

      final mahasiswaId = akun['id'] as int;

      final dosenList =
          await AuthDatabase.instance.pembimbing(
        mahasiswaId,
      );

      final previews = <int, String>{};

      for (final dosen in dosenList) {
        final dosenId = dosen['id'] as int;

        previews[dosenId] =
            await SkrivaChatService.instance.pesanTerakhir(
          mahasiswaId: mahasiswaId,
          dosenId: dosenId,
        );
      }

      if (!mounted) return;

      setState(() {
        pembimbing = dosenList;
        preview = previews;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat chat: $e'),
        ),
      );
    }
  }

  Future<void> bukaChat(
    Map<String, Object?> dosen,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          dosenId: dosen['id'] as int,
          namaDosen: dosen['nama']?.toString() ?? '',
        ),
      ),
    );

    if (mounted) {
      await muat();
    }
  }

  // =====================================================
  // KARTU DOSEN
  // =====================================================

  Widget kartuDosen(
    Map<String, Object?> dosen,
  ) {
    final id = dosen['id'] as int;
    final nama = dosen['nama']?.toString() ?? '-';
    final urutan = dosen['urutan'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => bukaChat(dosen),
          borderRadius: BorderRadius.circular(24),
          child: SkrivaGlassCard(
            tint: urutan == 1
                ? SkrivaDashColors.softBlue
                : SkrivaDashColors.lime,
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: urutan == 1
                          ? const [
                              Color(0xFFB9E8EF),
                              Color(0xFFE8F5FF),
                            ]
                          : const [
                              Color(0xFFC8F4A4),
                              Color(0xFFF0FFD9),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: blue,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(
                          color: dark,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Pembimbing $urutan',
                        style: const TextStyle(
                          color: blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        preview[id] ?? 'Belum ada percakapan.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SkrivaDashColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 7),

                const Icon(
                  Icons.arrow_outward_rounded,
                  color: blue,
                ),
              ],
            ),
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
        title: const Text(
          'Chat',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        foregroundColor: dark,
        backgroundColor: SkrivaDashColors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: muat,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6F8FB),
              Color(0xFFEDF8F8),
              Color(0xFFF8F5FF),
            ],
          ),
        ),
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: blue,
                ),
              )
            : RefreshIndicator(
                onRefresh: muat,
                color: blue,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    16,
                    18,
                    30,
                  ),
                  children: [
                    const SkrivaDashboardHero(
                      eyebrow: 'STUDENT / CONSULTATION',
                      title: 'Let\'s\nTalk Thesis.',
                      subtitle:
                          'Connect with your supervisors, one message at a time.',
                      icon: Icons.forum_rounded,
                    ),

                    const SizedBox(height: 25),

                    const SkrivaSectionTitle(
                      title: 'Your Supervisors',
                      subtitle:
                          'Pilih dosen untuk melanjutkan konsultasi.',
                    ),

                    const SizedBox(height: 15),

                    if (pembimbing.isEmpty)
                      const SkrivaGlassCard(
                        child: Text(
                          'Belum ada dosen pembimbing.',
                          style: TextStyle(color: dark),
                        ),
                      ),

                    ...pembimbing.map(kartuDosen),
                  ],
                ),
              ),
      ),
    );
  }
}
