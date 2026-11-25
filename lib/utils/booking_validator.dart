class BookingValidator {
  static String? validasi({
    required DateTime? tanggal,
    required String? jam,
    required String? mode,
    required List<Map<String, dynamic>> jadwalTersimpan,
  }) {
    if (tanggal == null) return 'Silakan pilih tanggal bimbingan.';
    if (jam == null || jam.isEmpty) return 'Silakan pilih jam bimbingan.';
    if (mode == null || mode.isEmpty) return 'Silakan pilih mode bimbingan.';

    final hariIni = DateTime.now();
    final tanggalDipilih = DateTime(tanggal.year, tanggal.month, tanggal.day);
    final tanggalSekarang = DateTime(hariIni.year, hariIni.month, hariIni.day);

    if (tanggalDipilih.isBefore(tanggalSekarang)) {
      return 'Tanggal yang sudah lewat tidak bisa dipilih.';
    }

    // Cek apakah jam yang dipilih pada hari ini sudah terlewat.
    if (tanggalDipilih == tanggalSekarang) {
      final jamMulai = jam.split(' - ').first.replaceAll('.', ':').split(':');
      final waktuMulai = int.parse(jamMulai[0]) * 60 + int.parse(jamMulai[1]);
      final waktuSekarang = DateTime.now().hour * 60 + DateTime.now().minute;
      if (waktuMulai <= waktuSekarang) {
        return 'Jam tersebut sudah lewat. Pilih jam yang masih tersedia.';
      }
    }

    // Cek apakah jam pada tanggal tersebut sudah dipesan.
    for (final item in jadwalTersimpan) {
      final tanggalLama = DateTime.tryParse(item['tanggal'] ?? '');
      if (tanggalLama != null &&
          tanggalLama.year == tanggal.year &&
          tanggalLama.month == tanggal.month &&
          tanggalLama.day == tanggal.day &&
          item['jam'] == jam) {
        return 'Jam tersebut sudah memiliki booking. Pilih jam lain.';
      }
    }

    return null; // Tidak ada kesalahan.
  }
}
