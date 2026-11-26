import 'package:flutter/material.dart';
import 'package:test/database/auth_database.dart';
import 'package:test/pages/login_page.dart';
import 'package:test/pages/jadwal_bimbingan_baru_page.dart';
import 'package:test/pages/chat_detail_page.dart';
import 'package:test/pages/revisi_database_page.dart';

class DashboardDosenPage extends StatefulWidget {
  const DashboardDosenPage({super.key});

  @override
  State<DashboardDosenPage> createState() => _DashboardDosenPageState();
}

class _DashboardDosenPageState extends State<DashboardDosenPage> {
  static const olive = Color(0xFF694A47);
  static const darkOlive = Color(0xFF523B39);
  static const blue = Color(0xFF96C1C5);
  static const cream = Color(0xFFFFF0DE);

  Map<String, Object?>? akun;
  List<Map<String, Object?>> mahasiswa = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    muatData();
  }

  Future<void> muatData() async {
    try {
      final user = await AuthDatabase.instance.sesiAktif();

      if (user == null || user['role'] != 'dosen') {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
        return;
      }

      final daftar = await AuthDatabase.instance.mahasiswaBimbingan(
        user['id'] as int,
      );

      if (!mounted) return;

      setState(() {
        akun = user;
        mahasiswa = daftar;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat dashboard: $e')));
    }
  }

  Future<void> logout() async {
    await AuthDatabase.instance.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  Widget kartuRingkasan(String angka, String judul, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: blue, size: 28),
            const SizedBox(height: 10),
            Text(
              angka,
              style: const TextStyle(
                color: olive,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              judul,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: olive,
        foregroundColor: Colors.white,
        title: const Text('Skriva - Dosen'),
        actions: [
          IconButton(
            onPressed: logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: olive))
          : RefreshIndicator(
              onRefresh: muatData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: olive,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang,',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          akun?['nama']?.toString() ?? 'Dosen',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pantau perkembangan mahasiswa bimbinganmu.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      kartuRingkasan(
                        '${mahasiswa.length}',
                        'Mahasiswa Bimbingan',
                        Icons.people_alt_outlined,
                      ),
                      const SizedBox(width: 12),
                      kartuRingkasan(
                        '${mahasiswa.where((m) => m['urutan'] == 1).length}',
                        'Sebagai Pembimbing 1',
                        Icons.school_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JadwalBimbinganBaruPage(),
                          ),
                        );

                        if (mounted) {
                          await muatData();
                        }
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: const Text('Kelola Jadwal Bimbingan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: olive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RevisiDatabasePage(),
                          ),
                        );

                        if (mounted) {
                          await muatData();
                        }
                      },
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Kelola Revisi Mahasiswa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: olive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Daftar Mahasiswa Bimbingan',
                    style: TextStyle(
                      color: darkOlive,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (mahasiswa.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'Belum ada mahasiswa yang ditugaskan.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ...mahasiswa.map((m) {
                    final urutan = m['urutan'];

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE5F0EF),
                          child: Icon(Icons.person, color: olive),
                        ),
                        title: Text(
                          m['nama']?.toString() ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'NIM: ${m['nomor_induk']}\n'
                          'Sebagai Pembimbing $urutan',
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(
                                mahasiswaId: m['id'] as int,
                                namaDosen: akun?['nama']?.toString() ?? '',
                              ),
                            ),
                          );
                        },
                        trailing: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Color(0xFF96C1C5),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
