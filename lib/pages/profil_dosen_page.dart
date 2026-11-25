import 'package:flutter/material.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/theme/jadwal_theme.dart';

import 'booking_jadwal_page.dart';
import 'chat_detail_page.dart';

class ProfilDosenPage extends StatefulWidget {
  const ProfilDosenPage({super.key, this.dosenId = 1});

  final int dosenId;

  @override
  State<ProfilDosenPage> createState() => _ProfilDosenPageState();
}

class _ProfilDosenPageState extends State<ProfilDosenPage> {
  Map<String, Object?> _data = {};
  bool _loading = true;
  List<Map<String, Object?>> _daftarDosen = [];
  late int _dipilihId;

  String nilai(String key) => _data[key]?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _dipilihId = widget.dosenId;
    _muat();
  }

  Future<void> _muat() async {
    try {
      final helper = DatabaseHelper.instance;
      final daftar = await helper.ambilDaftarDosen();
      final data = await helper.ambilProfilDosen(id: _dipilihId);
      if (!mounted) return;
      setState(() {
        _daftarDosen = daftar;
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat data dosen: $e')));
    }
  }

  static const Color olive = Color(0xFF694A47);
  static const Color lightOlive = Color(0xFFEAF3F2);
  static const Color orange = Color(0xFF96C1C5);
  static const Color lightOrange = Color(0xFFE5F0EF);
  static const Color darkOlive = Color(0xFF523B39);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.055,
                15,
                screenWidth * 0.055,
                30,
              ),
              child: Column(
                children: [
                  // HEADER
                  Row(
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
                            size: 17,
                            color: orange,
                          ),
                        ),
                      ),

                      const Expanded(
                        child: Center(
                          child: Text(
                            'Profil Dosen',
                            style: TextStyle(
                              color: darkOlive,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 42),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // PEMILIHAN 7 DOSEN
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _daftarDosen.any((e) => e['id'] == _dipilihId)
                            ? _dipilihId
                            : null,
                        hint: const Text('Pilih dosen pembimbing'),
                        items: _daftarDosen.map((item) {
                          final id = item['id'] as int;
                          final nama = item['nama']?.toString() ?? '-';
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(nama, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (id) async {
                          if (id == null) return;
                          setState(() {
                            _dipilihId = id;
                            _loading = true;
                          });
                          await _muat();
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // FOTO DOSEN
                  Container(
                    width: 115,
                    height: 115,
                    decoration: BoxDecoration(
                      color: lightOlive,
                      shape: BoxShape.circle,
                      border: Border.all(color: olive, width: 3),
                    ),
                    child: const Icon(Icons.person, color: orange, size: 65),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    _loading ? 'Memuat...' : nilai('nama'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkOlive,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Dosen Pembimbing Skripsi',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 25),

                  // INFORMASI
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Dosen',
                          style: TextStyle(
                            color: darkOlive,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 18),

                        infoDosen(
                          Icons.school_outlined,
                          'Fakultas',
                          nilai('fakultas'),
                        ),

                        infoDosen(
                          Icons.account_balance_outlined,
                          'Program Studi',
                          nilai('prodi'),
                        ),

                        infoDosen(
                          Icons.email_outlined,
                          'Email',
                          nilai('email'),
                        ),

                        infoDosen(
                          Icons.badge_outlined,
                          'NIDN',
                          nilai('nidn').isEmpty ? 'Belum diisi' : nilai('nidn'),
                        ),
                        infoDosen(
                          Icons.phone_outlined,
                          'Telepon',
                          nilai('telepon').isEmpty
                              ? 'Belum diisi'
                              : nilai('telepon'),
                        ),
                        infoDosen(
                          Icons.room_outlined,
                          'Ruangan',
                          nilai('ruangan'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // BIDANG KEAHLIAN
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: lightOlive,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bidang Keahlian',
                          style: TextStyle(
                            color: darkOlive,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: nilai('keahlian')
                              .split(',')
                              .where((v) => v.trim().isNotEmpty)
                              .map((v) => bidang(v.trim()))
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TOMBOL CHAT
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailPage(
                              namaDosen: nilai('nama'),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: olive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Chat Dosen'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // TOMBOL BOOKING
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookingJadwalPage(dosen: nilai('nama')),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Booking Jadwal Bimbingan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget infoDosen(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: orange, size: 20),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    color: darkOlive,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bidang(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: darkOlive,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
