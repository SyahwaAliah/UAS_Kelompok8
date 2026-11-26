import 'package:flutter/material.dart';
import 'package:test/database/auth_database.dart';
import 'package:test/pages/chat_detail_page.dart';

class PembimbingProfileCard extends StatefulWidget {
  const PembimbingProfileCard({super.key});

  @override
  State<PembimbingProfileCard> createState() =>
      _PembimbingProfileCardState();
}

class _PembimbingProfileCardState
    extends State<PembimbingProfileCard> {
  static const brown = Color(0xFF694A47);
  static const teal = Color(0xFF96C1C5);

  Map<String, Object?>? akun;
  List<Map<String, Object?>> dosen = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<void> muat() async {
    try {
      final user = await AuthDatabase.instance.sesiAktif();

      if (user == null || user['role'] != 'mahasiswa') {
        throw StateError('Akun mahasiswa tidak ditemukan.');
      }

      final pembimbing = await AuthDatabase.instance.pembimbing(
        user['id'] as int,
      );

      if (!mounted) return;
      setState(() {
        akun = user;
        dosen = pembimbing;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: brown),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: teal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Akun Mahasiswa',
            style: TextStyle(
              color: brown,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            akun?['nama']?.toString() ?? '-',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('NIM: ${akun?['nomor_induk'] ?? '-'}'),
          Text('Email: ${akun?['email'] ?? '-'}'),
          const Divider(height: 28),
          const Text(
            'Dosen Pembimbing',
            style: TextStyle(
              color: brown,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (dosen.isEmpty)
            const Text('Belum ada pembimbing.'),
          ...dosen.map((item) {
            final id = item['id'] as int;
            final nama = item['nama']?.toString() ?? '-';

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEAF3F2),
                child: Icon(Icons.school, color: brown),
              ),
              title: Text(
                nama,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Pembimbing ${item['urutan']}',
              ),
              trailing: IconButton(
                tooltip: 'Chat Dosen',
                icon: const Icon(
                  Icons.chat_outlined,
                  color: brown,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailPage(
                        dosenId: id,
                        namaDosen: nama,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
