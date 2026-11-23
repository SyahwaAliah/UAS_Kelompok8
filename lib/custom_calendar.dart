import 'package:flutter/material.dart';
import 'jadwal_theme.dart';

class CustomCalendar extends StatefulWidget {
  final DateTime? selectedDate;
  final List<DateTime> bookedDates;
  final ValueChanged<DateTime> onDateSelected;

  const CustomCalendar({
    super.key,
    required this.selectedDate,
    required this.bookedDates,
    required this.onDateSelected,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime bulanDitampilkan = DateTime(DateTime.now().year, DateTime.now().month);

  final List<String> namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  final List<String> namaHari = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

  bool tanggalSama(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final hariPertama = DateTime(bulanDitampilkan.year, bulanDitampilkan.month, 1);
    final jumlahHari = DateTime(bulanDitampilkan.year, bulanDitampilkan.month + 1, 0).day;
    final awalKotak = hariPertama.weekday % 7;
    final jumlahKotak = ((awalKotak + jumlahHari) / 7).ceil() * 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    bulanDitampilkan = DateTime(bulanDitampilkan.year, bulanDitampilkan.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left, color: JadwalColors.olive),
              ),
              Expanded(
                child: Text(
                  '${namaBulan[bulanDitampilkan.month - 1]} ${bulanDitampilkan.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: JadwalColors.darkOlive,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    bulanDitampilkan = DateTime(bulanDitampilkan.year, bulanDitampilkan.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right, color: JadwalColors.olive),
              ),
            ],
          ),
          Row(
            children: namaHari.map((hari) {
              return Expanded(
                child: Center(
                  child: Text(
                    hari,
                    style: const TextStyle(
                      color: JadwalColors.textGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: jumlahKotak,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 3,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final nomorHari = index - awalKotak + 1;
              if (nomorHari < 1 || nomorHari > jumlahHari) {
                return const SizedBox();
              }

              final tanggal = DateTime(bulanDitampilkan.year, bulanDitampilkan.month, nomorHari);
              final hariIni = DateTime.now();
              final tanggalLewat = DateTime(tanggal.year, tanggal.month, tanggal.day)
                  .isBefore(DateTime(hariIni.year, hariIni.month, hariIni.day));
              final dipilih = widget.selectedDate != null && tanggalSama(tanggal, widget.selectedDate!);
              final sudahDipesan = widget.bookedDates.any((item) => tanggalSama(item, tanggal));

              return GestureDetector(
                onTap: tanggalLewat ? null : () => widget.onDateSelected(tanggal),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: dipilih ? JadwalColors.olive
                      : sudahDipesan ? JadwalColors.lightGreen
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$nomorHari',
                          style: TextStyle(
                            color: tanggalLewat
                                ? Colors.grey.shade300
                                : dipilih
                                    ? Colors.white
                                    : JadwalColors.darkOlive,
                            fontSize: 12,
                            fontWeight: dipilih ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (sudahDipesan && !dipilih)
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: JadwalColors.olive,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.circle, color: JadwalColors.lightGreen, size: 10),
              SizedBox(width: 5),
              Text('Sudah ada booking', style: TextStyle(fontSize: 10, color: JadwalColors.textGrey)),
              SizedBox(width: 14),
              Icon(Icons.circle, color: JadwalColors.olive, size: 10),
              SizedBox(width: 5),
              Text('Tanggal dipilih', style: TextStyle(fontSize: 10, color: JadwalColors.textGrey)),
            ],
          ),
        ],
      ),
    );
  }
}
