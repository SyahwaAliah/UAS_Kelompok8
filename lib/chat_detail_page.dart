import 'package:flutter/material.dart';
import 'jadwal_theme.dart';

import 'profil_dosen_page.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key});

  @override
  State<ChatDetailPage> createState() =>
      _ChatDetailPageState();
}

class _ChatDetailPageState
    extends State<ChatDetailPage> {
  final TextEditingController messageController =
      TextEditingController();

  String pesan1 = 'Selamat pagi, Pak.';
  String pesan2 =
      'Saya ingin konsultasi mengenai Bab 3.';
  String pesan3 = '';
  String pesan4 = '';
  String pesan5 = '';

  void kirimPesan() {
    if (messageController.text.isNotEmpty) {
      setState(() {
        if (pesan3.isEmpty) {
          pesan3 = messageController.text;
        } else if (pesan4.isEmpty) {
          pesan4 = messageController.text;
        } else {
          pesan5 = messageController.text;
        }
      });

      messageController.clear();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Widget pesanKiri(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints:
            const BoxConstraints(maxWidth: 285),
        margin: const EdgeInsets.only(
          bottom: 10,
          right: 55,
        ),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF523B39),
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget pesanKanan(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints:
            const BoxConstraints(maxWidth: 285),
        margin: const EdgeInsets.only(
          bottom: 10,
          left: 55,
        ),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFF96C1C5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFF96C1C5);
    const darkOlive = Color(0xFF523B39);

    return AnimatedPage(child: Scaffold(
      backgroundColor: const Color(0xFFFFF0DE),
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
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  15,
                  12,
                  15,
                  12,
                ),
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
                            color:
                                Colors.black.withOpacity(0.05),
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
                          size: 17,
                          color: orange,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: orange,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. Budi Santoso, M.Kom.',
                            style: TextStyle(
                              color: darkOlive,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Dosen Pembimbing',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ProfilDosenPage(),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.info_outline,
                        color: orange,
                      ),
                    ),
                  ],
                ),
              ),

              // CHAT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    10,
                    18,
                    15,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Hari ini',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),

                      const SizedBox(height: 14),

                      pesanKanan(pesan1),

                      pesanKanan(pesan2),

                      pesanKiri(
                        'Selamat pagi. Silakan, ada yang ingin ditanyakan?',
                      ),

                      pesanKiri(
                        'Bagian mana dari Bab 3 yang ingin dikonsultasikan?',
                      ),

                      if (pesan3.isNotEmpty)
                        pesanKanan(pesan3),

                      if (pesan4.isNotEmpty)
                        pesanKanan(pesan4),

                      if (pesan5.isNotEmpty)
                        pesanKanan(pesan5),
                    ],
                  ),
                ),
              ),

              // INPUT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  15,
                  10,
                  15,
                  12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7EC),
                          borderRadius:
                              BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: messageController,
                          textInputAction:
                              TextInputAction.send,
                          onSubmitted: (value) {
                            kirimPesan();
                          },
                          decoration:
                              const InputDecoration(
                            hintText: 'Tulis pesan...',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    GestureDetector(
                      onTap: kirimPesan,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration:
                            const BoxDecoration(
                          color: orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}