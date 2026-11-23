/// Representasi satu baris tabel jadwal_bimbingan.
class JadwalModel {
  final int? id;
  final String tanggal;
  final String jam;
  final String dosen;
  final String mode;
  final String status;

  const JadwalModel({
    this.id,
    required this.tanggal,
    required this.jam,
    required this.dosen,
    required this.mode,
    this.status = 'Menunggu',
  });

  factory JadwalModel.fromMap(Map<String, Object?> map) {
    return JadwalModel(
      id: map['id'] as int?,
      tanggal: (map['tanggal'] as String?) ?? '',
      jam: (map['jam'] as String?) ?? '',
      dosen: (map['dosen'] as String?) ?? '',
      mode: (map['mode'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'Menunggu',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'tanggal': tanggal,
      'jam': jam,
      'dosen': dosen,
      'mode': mode,
      'status': status,
    };
  }
}
