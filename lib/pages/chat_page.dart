import 'package:flutter/material.dart';
import 'package:test/theme/jadwal_theme.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/pages/chat_detail_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _pesanTerakhir = 'Belum ada percakapan.';
  String _waktuTerakhir = '';
  bool _adaChat = false;

  @override
  void initState() {
    super.initState();
    _muatChat();
  }

  Future<void> _muatChat() async {
    try {
      final rows = await DatabaseHelper.instance.ambilPesanChat(
        dosen: 'Dr. Budi Santoso',
      );

      if (!mounted) return;

      setState(() {
        _adaChat = rows.isNotEmpty;

        if (rows.isEmpty) {
          _pesanTerakhir = 'Belum ada percakapan.';
          _waktuTerakhir = '';
        } else {
          final terakhir = rows.last;
          _pesanTerakhir = terakhir['pesan']?.toString() ?? '';

          final tanggal = DateTime.tryParse(
            terakhir['created_at']?.toString() ?? '',
          );

          _waktuTerakhir = tanggal == null
              ? ''
              : '${tanggal.hour.toString().padLeft(2, '0')}:'
                    '${tanggal.minute.toString().padLeft(2, '0')}';
        }
      });
    } catch (e) {
      debugPrint('Gagal memuat chat: $e');
    }
  }

  Future<void> _bukaDetailChat() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatDetailPage()),
    );

    if (mounted) await _muatChat();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFF96C1C5);
    const darkOlive = Color(0xFF523B39);
    const olive = Color(0xFF694A47);

    return AnimatedPage(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF0DE),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF0DE), Color(0xFFEAF3F2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
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
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 17,
                            color: orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chat',
                            style: TextStyle(
                              color: darkOlive,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Konsultasi dengan dosen',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 25),
                    child: GestureDetector(
                      onTap: _bukaDetailChat,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 55,
                              height: 55,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEAF3F2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: orange,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Dr. Budi Santoso, M.Kom.',
                                    style: TextStyle(
                                      color: darkOlive,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _pesanTerakhir,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _adaChat ? _waktuTerakhir : 'Belum dimulai',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: olive,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
