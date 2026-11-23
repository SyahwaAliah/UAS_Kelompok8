import 'package:flutter/material.dart';
import 'jadwal_theme.dart';

import 'profile_mahasiswa_page.dart';
import 'chat_page.dart';
import 'notification_page.dart';
import 'video_call_page.dart';
import 'jadwal_page.dart';
import 'booking_jadwal_page.dart';
import 'animated_button.dart';
import 'database/database_helper.dart';
import 'detailbimbingan_page.dart';
import 'detailrevisi_page.dart';
import 'notes_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;
  Map<String, dynamic>? jadwalBerikutnya;

  @override
  void initState() {
    super.initState();
    muatJadwalBerikutnya();
  }

  Future<void> muatJadwalBerikutnya() async {
    final data = await DatabaseHelper.instance.ambilJadwal();
    final sekarang = DateTime.now();
    final mendatang = data.where((item) {
      final tanggal = DateTime.tryParse((item['tanggal'] ?? '').toString());
      return tanggal != null && !tanggal.isBefore(DateTime(sekarang.year, sekarang.month, sekarang.day));
    }).toList();

    if (!mounted) return;
    setState(() {
      jadwalBerikutnya = mendatang.isEmpty ? null : mendatang.first;
    });
  }

  String tanggalJadwal() {
    if (jadwalBerikutnya == null) return 'Belum ada jadwal';
    final tanggal = DateTime.parse((jadwalBerikutnya!['tanggal'] ?? '').toString());
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
  }

  Future<void> bukaBookingJadwal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BookingJadwalPage()),
    );
    muatJadwalBerikutnya();
  }

  static const Color olive = Color(0xFF694A47);
  static const Color darkOlive = Color(0xFF523B39);

  static const Color maroon = Color(0xFF694A47);
  static const Color darkMaroon = Color(0xFF523B39);

  static const Color orange = Color(0xFF96C1C5);

  static const Color cream = Color(0xFFFFF0DE);
  static const Color peach = Color(0xFFE5F0EF);
  static const Color lightPeach = Color(0xFFFFF7EC);

  static const Color lightBlue = Color(0xFFD9ECEC);
  static const Color lightPink = Color(0xFFF4E6E3);
  static const Color softYellow = Color(0xFFFFF5E5);

  void bukaProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileMahasiswaPage()),
    );
  }

  void bukaDetailBimbingan() {
    DetailBimbinganPage.open(context);
  }

  void bukaDetailRevisi() {
    DetailRevisiPage.buka(context);
  }

  void bukaNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotesPage()),
    );
  }

  void bukaChat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          decoration: const BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 18),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Konsultasi',
                  style: TextStyle(
                    color: darkOlive,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              GestureDetector(
                onTap: () {
                  Navigator.pop(sheetContext);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatPage()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: peach,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: olive,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chat',
                              style: TextStyle(
                                color: darkOlive,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),

                            SizedBox(height: 3),

                            Text(
                              'Konsultasi melalui pesan',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(Icons.chevron_right_rounded, color: olive),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: () {
                  Navigator.pop(sheetContext);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VideoCallPage(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: lightPeach,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.videocam_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Video Call',
                              style: TextStyle(
                                color: darkOlive,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),

                            SizedBox(height: 3),

                            Text(
                              'Konsultasi secara langsung',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(Icons.chevron_right_rounded, color: orange),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void pilihBottomNav(int index) {
    if (index == 0) {
      setState(() {
        selectedIndex = 0;
      });
      return;
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const JadwalPage()),
      ).then((_) => muatJadwalBerikutnya()); // Perbarui ringkasan saat kembali.
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationPage()),
      );
      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatPage()),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedPage(child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [cream, Color(0xFFEAF3F2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.055,
                  20,
                  screenWidth * 0.055,
                  100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Halo, Syahwa 👋',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: darkOlive,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'Yuk lanjutkan bimbinganmu hari ini.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        GestureDetector(
                          onTap: bukaProfile,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 27,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: olive,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Progress Skripsi',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            '60%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            width: double.infinity,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.6,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            '3 dari 5 tahapan selesai',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Bimbingan Terdekat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkOlive,
                      ),
                    ),

                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: bukaDetailBimbingan,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: lightBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    jadwalBerikutnya == null ? 'KOSONG' : '${jadwalBerikutnya!['status']}'.toUpperCase(),
                                    style: const TextStyle(
                                      color: olive,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                Text(
                                  jadwalBerikutnya == null ? '--' : '${jadwalBerikutnya!['jam']} WIB',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),

                            const SizedBox(height: 13),

                            Text(
                              jadwalBerikutnya == null ? 'Belum ada booking' : 'Bimbingan Skripsi',
                              style: const TextStyle(
                                color: darkOlive,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              jadwalBerikutnya == null ? 'Silakan buat jadwal bimbingan.' : '${jadwalBerikutnya!['dosen']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              tanggalJadwal(),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Icon(
                                  Icons.video_call_outlined,
                                  size: 17,
                                  color: orange,
                                ),

                                const SizedBox(width: 5),

                                Expanded(
                                  child: Text(
                                    jadwalBerikutnya == null ? 'Tanggal bimbingan belum dipilih' : '${jadwalBerikutnya!['mode']}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    AnimatedButton(
                      text: 'Booking Jadwal Baru',
                      icon: Icons.add,
                      onPressed: bukaBookingJadwal,
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Revisi Terakhir',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkOlive,
                      ),
                    ),

                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: bukaDetailRevisi,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: lightPink,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4E6E3),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.edit_note_rounded,
                                color: maroon,
                              ),
                            ),

                            const SizedBox(width: 13),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bab 2',
                                    style: TextStyle(
                                      color: darkOlive,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),

                                  SizedBox(height: 5),

                                  Text(
                                    'Perbaiki landasan teori dan tambahkan referensi terbaru.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                  Text(
                                    '28 September 2026',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Catatan Pribadi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkOlive,
                      ),
                    ),

                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: bukaNotes,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: softYellow,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0xFF96C1C5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.sticky_note_2_rounded,
                                  color: orange,
                                  size: 20,
                                ),

                                const SizedBox(width: 8),

                                const Expanded(
                                  child: Text(
                                    'Catatan Pribadi',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),

                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: orange,
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              'Revisi Teori Bab 2',
                              style: TextStyle(
                                color: darkOlive,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              'Cari 3 jurnal internasional terbaru tentang algoritma CNN di atas tahun 2020 sesuai titipan Dr. Budi kemarin.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),

              Positioned(
                right: 20,
                bottom: 18,
                child: GestureDetector(
                  onTap: bukaChat,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: pilihBottomNav,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFF7EC),
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedItemColor: olive,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: 'Jadwal',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_rounded),
            activeIcon: Icon(Icons.notifications_rounded),
            label: 'Notifikasi',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
        ],
      ),
    ));
  }
}
