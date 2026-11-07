import 'package:flutter/material.dart';

class DetailBimbinganPage {
  static const Color olive = Color(0xFF694A47);
  static const Color darkOlive = Color(0xFF523B39);
  static const Color cream = Color(0xFFFFF0DE);
  static const Color softGreen = Color(0xFFEAF3F2);
  static const Color lightPeach = Color(0xFFFFF7EC);
  static const Color orange = Color(0xFF96C1C5);
  static const Color textGrey = Color(0xFF8B7774);

  static void open(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Detail Bimbingan',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              18,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Bimbingan',
                    style: TextStyle(
                      color: darkOlive,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _infoCard(
                    color: softGreen,
                    icon: Icons.menu_book_rounded,
                    title: 'Bimbingan Skripsi',
                    subtitle:
                        'Pembahasan Bab 3 - Metodologi Penelitian',
                  ),

                  const SizedBox(height: 10),

                  _infoCard(
                    color: lightPeach,
                    icon: Icons.person,
                    title: 'Dosen Pembimbing',
                    subtitle: 'Dr. Budi Santoso',
                  ),

                  const SizedBox(height: 10),

                  _infoCard(
                    color: softGreen,
                    icon: Icons.calendar_month_rounded,
                    title: 'Tanggal & Waktu',
                    subtitle:
                        'Senin, 5 Oktober 2026\n10.00 - 11.00 WIB',
                  ),

                  const SizedBox(height: 10),

                  _infoCard(
                    color: lightPeach,
                    icon: Icons.location_on_rounded,
                    title: 'Ruangan',
                    subtitle: 'Ruang R905',
                  ),

                  const SizedBox(height: 10),

                  _infoCard(
                    color: softGreen,
                    icon: Icons.edit_note_rounded,
                    title: 'Catatan',
                    subtitle:
                        'Membawa revisi Bab 2 dan rancangan metodologi.',
                  ),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          color: orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final scaleAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  static Widget _infoCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: olive,
            size: 22,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF694A47),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 12,
                    height: 1.4,
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