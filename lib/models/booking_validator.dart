class BookingValidator {
  static String? validasi({
    required DateTime? tanggal,
    required String? jam,
    required String? mode,
    required List<Map<String, dynamic>> jadwalTersimpan,
  }) {
    if (tanggal == null) {
      return 'Silakan pilih tanggal bimbingan.';
    }

    final sekarang = DateTime.now();
    final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);

    final tanggalDipilih = DateTime(tanggal.year, tanggal.month, tanggal.day);

    if (tanggalDipilih.isBefore(hariIni)) {
      return 'Tidak dapat memilih tanggal yang sudah lewat.';
    }

    if (jam == null || jam.trim().isEmpty) {
      return 'Silakan pilih jam bimbingan.';
    }

    if (mode == null || mode.trim().isEmpty) {
      return 'Silakan pilih mode bimbingan.';
    }

    final tanggalString = tanggalDipilih.toIso8601String().split('T').first;

    final sudahAda = jadwalTersimpan.any((item) {
      final tanggalTersimpan = item['tanggal']?.toString().split('T').first;

      final jamTersimpan = item['jam']?.toString().trim();

      return tanggalTersimpan == tanggalString && jamTersimpan == jam.trim();
    });

    if (sudahAda) {
      return 'Jadwal pada tanggal dan jam tersebut sudah dibooking.';
    }

    return null;
  }
}
