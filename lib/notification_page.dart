import 'package:flutter/material.dart';
import 'jadwal_theme.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFF96C1C5);
    const darkOlive = Color(0xFF523B39);
    const olive = Color(0xFF694A47);

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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  15,
                  15,
                  15,
                  10,
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

                    const SizedBox(width: 13),

                    const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifikasi',
                          style: TextStyle(
                            color: darkOlive,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Informasi terbaru bimbingan',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    10,
                    18,
                    25,
                  ),
                  child: Column(
                    children: [
                      notificationCard(
                        Icons.calendar_month_outlined,
                        'Jadwal Bimbingan',
                        'Bimbingan kamu dijadwalkan pada Senin, 12 Oktober 2026 pukul 09.00.',
                        'Hari ini',
                        false,
                      ),

                      notificationCard(
                        Icons.edit_note,
                        'Revisi Baru',
                        'Dosen memberikan revisi pada Bab 3. Silakan cek detail revisi kamu.',
                        'Kemarin',
                        true,
                      ),

                      notificationCard(
                        Icons.chat_bubble_outline,
                        'Pesan Baru',
                        'Dr. Budi Santoso mengirimkan pesan baru melalui chat.',
                        '2 hari lalu',
                        false,
                      ),

                      notificationCard(
                        Icons.check_circle_outline,
                        'Bimbingan Selesai',
                        'Sesi bimbingan sebelumnya telah selesai. Lihat riwayat bimbingan untuk detail.',
                        '3 hari lalu',
                        true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget notificationCard(
    IconData icon,
    String title,
    String description,
    String time,
    bool useOrange,
  ) {
    final background = useOrange
        ? const Color(0xFFE5F0EF)
        : const Color(0xFFEAF3F2);

    final iconColor = useOrange
        ? const Color(0xFF96C1C5)
        : const Color(0xFF694A47);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF523B39),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  time,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 10,
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
}