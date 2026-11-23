import 'package:flutter/material.dart';
import 'jadwal_theme.dart';
import 'booking_jadwal_page.dart';
import 'custom_calendar.dart';
import 'animated_button.dart';
import 'database/database_helper.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  DateTime selectedDate = DateTime.now();
  int selectedFilter = 0;
  List<Map<String, dynamic>> daftarJadwal = [];

  @override
  void initState() {
    super.initState();
    muatJadwal();
  }

  Future<void> muatJadwal() async {
    final data = await DatabaseHelper.instance.ambilJadwal();
    if (!mounted) return;
    setState(() => daftarJadwal = data);
  }

  bool tanggalSama(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String formatTanggal(DateTime tanggal) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
  }

  Future<void> bukaBooking() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BookingJadwalPage()),
    );
    muatJadwal(); // Perbarui daftar setelah kembali dari booking.
  }

  @override
  Widget build(BuildContext context) {
    final jadwalTanggal = daftarJadwal.where((item) {
      final tanggal = DateTime.tryParse(item['tanggal'] ?? '');
      return tanggal != null && tanggalSama(tanggal, selectedDate);
    }).where((item) {
      if (selectedFilter == 0) return true;
      if (selectedFilter == 1) return item['status'] == 'Terjadwal';
      if (selectedFilter == 2) return item['status'] == 'Menunggu';
      return item['status'] == 'Selesai';
    }).toList();

    final semuaTanggal = daftarJadwal
        .map((item) => DateTime.tryParse(item['tanggal'] ?? ''))
        .where((tanggal) => tanggal != null)
        .cast<DateTime>()
        .toList();

    return AnimatedPage(
      child: Scaffold(
        body: JadwalBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const JadwalHeader(
                  title: 'Jadwal Bimbingan',
                  subtitle: 'Lihat dan kelola jadwal konsultasi skripsimu.',
                ),
                const SizedBox(height: 22),
                const Text('Kalender Bimbingan', style: TextStyle(
                  color: JadwalColors.darkOlive, fontSize: 16, fontWeight: FontWeight.bold,
                )),
                const SizedBox(height: 10),
                CustomCalendar(
                  selectedDate: selectedDate,
                  bookedDates: semuaTanggal,
                  onDateSelected: (tanggal) => setState(() => selectedDate = tanggal),
                ),
                const SizedBox(height: 20),
                Text('Jadwal pada ${formatTanggal(selectedDate)}',
                  style: const TextStyle(color: JadwalColors.darkOlive, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    'Semua', 'Terjadwal', 'Menunggu', 'Selesai'
                  ].asMap().entries.map((entry) {
                    final dipilih = selectedFilter == entry.key;
                    return GestureDetector(
                      onTap: () => setState(() => selectedFilter = entry.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: dipilih ? JadwalColors.olive : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(entry.value, style: TextStyle(
                          color: dipilih ? Colors.white : JadwalColors.darkOlive,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 15),
                if (jadwalTanggal.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: const Column(
                      children: [
                        Icon(Icons.event_busy, color: JadwalColors.orange, size: 35),
                        SizedBox(height: 8),
                        Text('Belum ada jadwal pada tanggal ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: JadwalColors.textGrey)),
                      ],
                    ),
                  )
                else
                  ...jadwalTanggal.map((item) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: JadwalColors.orange, size: 18),
                              const SizedBox(width: 7),
                              Expanded(child: Text('${item['jam']} WIB',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: JadwalColors.darkOlive))),
                              Text('${item['status']}',
                                style: const TextStyle(color: JadwalColors.orange, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text('Bimbingan Skripsi',
                            style: TextStyle(fontWeight: FontWeight.bold, color: JadwalColors.darkOlive, fontSize: 15)),
                          const SizedBox(height: 5),
                          Text('${item['dosen']}', style: const TextStyle(color: JadwalColors.textGrey)),
                          const SizedBox(height: 5),
                          Text('Mode: ${item['mode']}', style: const TextStyle(color: JadwalColors.textGrey, fontSize: 12)),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 15),
                AnimatedButton(
                  text: 'Booking Jadwal Bimbingan',
                  icon: Icons.add,
                  onPressed: bukaBooking,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
