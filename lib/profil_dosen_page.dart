import 'package:flutter/material.dart';
import 'jadwal_theme.dart';

import 'booking_jadwal_page.dart';
import 'chat_detail_page.dart';

class ProfilDosenPage extends StatelessWidget {
  const ProfilDosenPage({super.key});

  static const Color olive = Color(0xFF694A47);
  static const Color lightOlive = Color(0xFFEAF3F2);
  static const Color orange = Color(0xFF96C1C5);
  static const Color lightOrange = Color(0xFFE5F0EF);
  static const Color darkOlive = Color(0xFF523B39);

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width;

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

                // FOTO DOSEN
                Container(
                  width: 115,
                  height: 115,
                  decoration: BoxDecoration(
                    color: lightOlive,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: olive,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: orange,
                    size: 65,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Dr. Budi Santoso, M.Kom.',
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
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
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
                        color:
                            Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                        'Fakultas Ilmu Komputer',
                      ),

                      infoDosen(
                        Icons.account_balance_outlined,
                        'Program Studi',
                        'Sistem Informasi',
                      ),

                      infoDosen(
                        Icons.email_outlined,
                        'Email',
                        'budi.santoso@kampus.ac.id',
                      ),

                      infoDosen(
                        Icons.room_outlined,
                        'Ruangan',
                        'Gedung A - Ruang 203',
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                        children: [
                          bidang('Sistem Informasi'),
                          bidang('Mobile Application'),
                          bidang('UI/UX'),
                          bidang('Data Management'),
                        ],
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
                          builder: (context) =>
                              const ChatDetailPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: olive,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                    ),
                    label: const Text(
                      'Chat Dosen',
                    ),
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
                              const BookingJadwalPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(
                      Icons.calendar_month_outlined,
                    ),
                    label: const Text(
                      'Booking Jadwal Bimbingan',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget infoDosen(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: orange,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
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