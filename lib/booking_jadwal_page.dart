import 'package:flutter/material.dart';
import 'jadwal_theme.dart';
import 'database/database_helper.dart';
import 'custom_calendar.dart';
import 'animated_button.dart';
import 'booking_validator.dart';

class BookingJadwalPage extends StatefulWidget {
  const BookingJadwalPage({super.key});

  @override
  State<BookingJadwalPage> createState() => _BookingJadwalPageState();
}

class _BookingJadwalPageState extends State<BookingJadwalPage> {
  DateTime? selectedDate;
  String? selectedTime;
  String? selectedMode;
  List<Map<String, dynamic>> jadwalTersimpan = [];

  final List<String> daftarJam = [
    '09.00 - 10.00',
    '10.00 - 11.00',
    '13.00 - 14.00',
    '14.00 - 15.00',
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    ambilJadwal();
  }

  Future<void> ambilJadwal() async {
    final data = await DatabaseHelper.instance.ambilJadwal();
    if (!mounted) return;
    setState(() => jadwalTersimpan = data);
  }

  String formatTanggal(DateTime tanggal) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
  }

  Future<void> konfirmasiBooking() async {
    final pesan = BookingValidator.validasi(
      tanggal: selectedDate,
      jam: selectedTime,
      mode: selectedMode,
      jadwalTersimpan: jadwalTersimpan,
    );

    if (pesan != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
      return;
    }

    try {
      await DatabaseHelper.instance.tambahJadwal(
        tanggal: selectedDate!.toIso8601String().split('T').first,
        jam: selectedTime!,
        dosen: 'Dr. Budi Santoso',
        mode: selectedMode!,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan jadwal: $error')),
      );
      return;
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: JadwalColors.olive, size: 55),
            SizedBox(height: 12),
            Text('Booking Berhasil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            Text('Jadwal bimbingan berhasil disimpan.', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );

    await ambilJadwal();
    if (mounted) Navigator.pop(context, true);
  }

  Widget pilihanJam(String jam) {
    final dipilih = selectedTime == jam;
    return GestureDetector(
      onTap: () => setState(() => selectedTime = jam),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        decoration: BoxDecoration(
          color: dipilih ? JadwalColors.olive : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dipilih ? JadwalColors.olive : JadwalColors.lightGreen),
        ),
        child: Text(
          jam,
          style: TextStyle(
            color: dipilih ? Colors.white : JadwalColors.darkOlive,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daftarTanggalBooking = jadwalTersimpan
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
                  title: 'Booking Jadwal',
                  subtitle: 'Pilih tanggal dan waktu bimbingan.',
                ),
                const SizedBox(height: 22),
                const Text('Dosen Pembimbing', style: TextStyle(
                  color: JadwalColors.darkOlive, fontSize: 16, fontWeight: FontWeight.bold,
                )),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: JadwalColors.lightGreen,
                        child: Icon(Icons.person, color: JadwalColors.olive),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dr. Budi Santoso', style: TextStyle(fontWeight: FontWeight.bold, color: JadwalColors.darkOlive)),
                            SizedBox(height: 4),
                            Text('Pembimbing Utama', style: TextStyle(color: JadwalColors.textGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text('Pilih Tanggal', style: TextStyle(
                  color: JadwalColors.darkOlive, fontSize: 16, fontWeight: FontWeight.bold,
                )),
                const SizedBox(height: 10),
                CustomCalendar(
                  selectedDate: selectedDate,
                  bookedDates: daftarTanggalBooking,
                  onDateSelected: (tanggal) => setState(() {
                    selectedDate = tanggal;
                    selectedTime = null;
                  }),
                ),
                if (selectedDate != null) ...[
                  const SizedBox(height: 10),
                  Text('Tanggal dipilih: ${formatTanggal(selectedDate!)}',
                    style: const TextStyle(color: JadwalColors.darkOlive, fontWeight: FontWeight.bold)),
                ],
                const SizedBox(height: 22),
                const Text('Pilih Jam', style: TextStyle(
                  color: JadwalColors.darkOlive, fontSize: 16, fontWeight: FontWeight.bold,
                )),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: daftarJam.map(pilihanJam).toList()),
                const SizedBox(height: 22),
                const Text('Mode Bimbingan', style: TextStyle(
                  color: JadwalColors.darkOlive, fontSize: 16, fontWeight: FontWeight.bold,
                )),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: ['Tatap Muka', 'Video Call'].map((mode) {
                    final dipilih = selectedMode == mode;
                    return GestureDetector(
                      onTap: () => setState(() => selectedMode = mode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        decoration: BoxDecoration(
                          color: dipilih ? JadwalColors.olive : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(mode, style: TextStyle(
                          color: dipilih ? Colors.white : JadwalColors.darkOlive,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                AnimatedButton(
                  text: 'Konfirmasi Booking',
                  icon: Icons.calendar_month,
                  onPressed: konfirmasiBooking,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
