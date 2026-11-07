import 'package:flutter/material.dart';

import 'jadwal_theme.dart';
import 'database/database_helper.dart';

class BookingJadwalPage extends StatefulWidget {
  const BookingJadwalPage({super.key});

  @override
  State<BookingJadwalPage> createState() =>
      _BookingJadwalPageState();
}

class _BookingJadwalPageState
    extends State<BookingJadwalPage> {
  int selectedDate = 0;
  int selectedTime = 0;
  int selectedMode = 0;

  Widget pilihan({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: selected
              ? JadwalColors.olive
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [BoxShadow(color: JadwalColors.olive.withOpacity(0.16), blurRadius: 12, offset: const Offset(0, 5))]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected
                ? Colors.white
                : JadwalColors.darkOlive,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Future<void> konfirmasiBooking() async {
    final tanggal = DateTime.now().add(Duration(days: selectedDate));
    const jam = ['09.00 - 10.00', '10.00 - 11.00',
      '13.00 - 14.00', '14.00 - 15.00'];
    const mode = ['Tatap Muka', 'Video Call'];
    try {
      await DatabaseHelper.instance.tambahJadwal(
        tanggal: tanggal.toIso8601String().split('T').first,
        jam: jam[selectedTime],
        dosen: 'Dr. Budi Santoso',
        mode: mode[selectedMode],
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan jadwal: $error')),
      );
      return;
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: JadwalColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: JadwalColors.olive,
                  size: 34,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Booking Terkirim',
                style: TextStyle(
                  color: JadwalColors.darkOlive,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Permintaan jadwal bimbingan berhasil dikirim.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: JadwalColors.textGrey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: JadwalColors.olive,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text(
                      'Selesai',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPage(child: Scaffold(
      body: JadwalBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const JadwalHeader(
                title: 'Booking Jadwal',
                subtitle:
                    'Pilih tanggal dan waktu bimbingan.',
              ),

              const SizedBox(height: 25),

              const Text(
                'Dosen Pembimbing',
                style: TextStyle(
                  color: JadwalColors.darkOlive,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: JadwalColors.lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: JadwalColors.olive,
                      ),
                    ),

                    const SizedBox(width: 13),

                    const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. Budi Santoso',
                          style: TextStyle(
                            color: JadwalColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Pembimbing Utama',
                          style: TextStyle(
                            color: JadwalColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Pilih Tanggal',
                style: TextStyle(
                  color: JadwalColors.darkOlive,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(4, (index) {
                  final tanggal = DateTime.now().add(Duration(days: index));
                  const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
                  return pilihan(
                    text: '${tanggal.day} ${bulan[tanggal.month - 1]}',
                    selected: selectedDate == index,
                    onTap: () => setState(() => selectedDate = index),
                  );
                }),
              ),

              const SizedBox(height: 25),

              const Text(
                'Pilih Jam',
                style: TextStyle(
                  color: JadwalColors.darkOlive,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                children: [
                  pilihan(
                    text: '09.00 - 10.00',
                    selected: selectedTime == 0,
                    onTap: () {
                      setState(() {
                        selectedTime = 0;
                      });
                    },
                  ),
                  pilihan(
                    text: '10.00 - 11.00',
                    selected: selectedTime == 1,
                    onTap: () {
                      setState(() {
                        selectedTime = 1;
                      });
                    },
                  ),
                  pilihan(
                    text: '13.00 - 14.00',
                    selected: selectedTime == 2,
                    onTap: () {
                      setState(() {
                        selectedTime = 2;
                      });
                    },
                  ),
                  pilihan(
                    text: '14.00 - 15.00',
                    selected: selectedTime == 3,
                    onTap: () {
                      setState(() {
                        selectedTime = 3;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                'Mode Bimbingan',
                style: TextStyle(
                  color: JadwalColors.darkOlive,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                children: [
                  pilihan(
                    text: 'Tatap Muka',
                    selected: selectedMode == 0,
                    onTap: () {
                      setState(() {
                        selectedMode = 0;
                      });
                    },
                  ),
                  pilihan(
                    text: 'Video Call',
                    selected: selectedMode == 1,
                    onTap: () {
                      setState(() {
                        selectedMode = 1;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: konfirmasiBooking,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: JadwalColors.olive,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text(
                      'Konfirmasi Booking',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}