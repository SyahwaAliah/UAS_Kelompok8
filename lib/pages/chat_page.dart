import 'package:flutter/material.dart';
import 'package:test/database/auth_database.dart';
import 'package:test/service/skriva_chat_service.dart';
import 'package:test/pages/chat_detail_page.dart';
import 'package:test/theme/jadwal_theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const olive = Color(0xFF694A47);
  static const blue = Color(0xFF96C1C5);
  static const darkOlive = Color(0xFF523B39);

  List<Map<String, Object?>> pembimbing = [];
  Map<int, String> preview = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<void> muat() async {
    try {
      final akun = await AuthDatabase.instance.sesiAktif();

      if (akun == null || akun['role'] != 'mahasiswa') {
        throw StateError('Halaman ini khusus mahasiswa.');
      }

      final mahasiswaId = akun['id'] as int;
      final dosenList =
          await AuthDatabase.instance.pembimbing(mahasiswaId);

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
        SnackBar(content: Text('Gagal memuat chat: $e')),
      );
    }
  }

  Future<void> bukaChat(Map<String, Object?> dosen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          dosenId: dosen['id'] as int,
          namaDosen: dosen['nama'].toString(),
        ),
      ),
    );

    if (mounted) await muat();
  }

  Widget kartuDosen(Map<String, Object?> dosen) {
    final id = dosen['id'] as int;
    final nama = dosen['nama']?.toString() ?? '-';
    final urutan = dosen['urutan'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: () => bukaChat(dosen),
        contentPadding: const EdgeInsets.all(15),
        leading: const CircleAvatar(
          radius: 27,
          backgroundColor: Color(0xFFEAF3F2),
          child: Icon(Icons.person, color: blue, size: 30),
        ),
        title: Text(
          nama,
          style: const TextStyle(
            color: darkOlive,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pembimbing $urutan',
              style: const TextStyle(
                color: olive,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              preview[id] ?? 'Belum ada percakapan.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: olive,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPage(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF0DE),
        appBar: AppBar(
          title: const Text('Chat'),
          actions: [
            IconButton(
              onPressed: muat,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFF0DE),
                Color(0xFFEAF3F2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(color: olive),
                )
              : RefreshIndicator(
                  onRefresh: muat,
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      const Text(
                        'Konsultasi dengan Dosen Pembimbing',
                        style: TextStyle(
                          color: darkOlive,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Pilih dosen untuk memulai atau melanjutkan chat.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (pembimbing.isEmpty)
                        const Text(
                          'Belum ada dosen pembimbing yang ditetapkan.',
                        ),
                      ...pembimbing.map(kartuDosen),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
