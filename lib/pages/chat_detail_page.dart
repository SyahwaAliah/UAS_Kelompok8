import 'package:flutter/material.dart';
import 'package:test/theme/jadwal_theme.dart';
import 'package:test/database/database_helper.dart';
import 'profil_dosen_page.dart';

class ChatDetailPage extends StatefulWidget {
  final String namaDosen;

  const ChatDetailPage({
    super.key,
    this.namaDosen = 'Dr. Budi Santoso',
  });

  @override
  State<ChatDetailPage> createState() =>
      _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  String get dosen => widget.namaDosen;

  final TextEditingController messageController =
      TextEditingController();

  List<Map<String, Object?>> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muatPesan();
  }

  Future<void> _muatPesan() async {
    try {
      final data = await DatabaseHelper.instance.ambilPesanChat(
        dosen: dosen,
      );

      if (!mounted) return;

      setState(() {
        _messages = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat chat: $e')),
      );
    }
  }

  Future<void> kirimPesan() async {
    final pesan = messageController.text.trim();

    if (pesan.isEmpty) return;

    try {
      await DatabaseHelper.instance.simpanPesanChat(
        dosen: dosen,
        pengirim: 'mahasiswa',
        pesan: pesan,
      );

      // Balasan demo, bukan pesan dari dosen sungguhan.
      final lower = pesan.toLowerCase();
      final balasan = lower.contains('jadwal') || lower.contains('bimbingan')
          ? 'Untuk jadwal bimbingan, silakan cek menu Jadwal dan ajukan waktu yang tersedia.'
          : lower.contains('bab') || lower.contains('revisi')
              ? 'Silakan kirim pertanyaan atau bagian bab yang ingin dibahas. Kita review pada sesi bimbingan.'
              : 'Terima kasih, pesanmu sudah tercatat. Silakan jelaskan kebutuhan konsultasimu lebih lanjut.';
      await DatabaseHelper.instance.simpanPesanChat(
        dosen: dosen, pengirim: 'simulasi_dosen', pesan: balasan);
      messageController.clear();
      await _muatPesan();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim pesan: $e')),
      );
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Widget pesanKiri(String text, {bool simulasi = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 285),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (simulasi) const Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text('SIMULASI BALASAN DOSEN', style: TextStyle(
                color: Color(0xFF694A47), fontSize: 10,
                fontWeight: FontWeight.bold)),
            ),
            Text(text, style: const TextStyle(
              color: Color(0xFF523B39), fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget pesanKanan(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 285),
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

  Widget pesanSistem(String text) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE5F0EF),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            const Text(
              'PESAN SISTEM',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF694A47),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF523B39),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _daftarPesan() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF694A47),
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada percakapan.\n'
          'Booking jadwal untuk memulai bimbingan.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 15),
      children: [
        const Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Text(
              'Riwayat Percakapan',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ),
        ),
        ..._messages.map((item) {
          final pesan = item['pesan']?.toString() ?? '';
          final pengirim =
              item['pengirim']?.toString() ?? '';

          if (pengirim == 'sistem') {
            return pesanSistem(pesan);
          }

          if (pengirim == 'mahasiswa') {
            return pesanKanan(pesan);
          }

          return pesanKiri(pesan, simulasi: pengirim == 'simulasi_dosen');
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFF96C1C5);
    const darkOlive = Color(0xFF523B39);

    return AnimatedPage(
      child: Scaffold(
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
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF3F2),
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
                              builder: (_) =>
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
                Expanded(child: _daftarPesan()),
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
                          padding: const EdgeInsets.symmetric(
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
                            onSubmitted: (_) => kirimPesan(),
                            decoration: const InputDecoration(
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
                          decoration: const BoxDecoration(
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
      ),
    );
  }
}
