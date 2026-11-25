class MahasiswaModel {
  final int? id;
  final String nama;
  final String nim;
  final String email;
  final String prodi;
  final int semester;
  final String judulSkripsi;

  const MahasiswaModel({
    this.id,
    required this.nama,
    required this.nim,
    this.email = '',
    this.prodi = '',
    this.semester = 1,
    this.judulSkripsi = '',
  });

  factory MahasiswaModel.fromMap(Map<String, Object?> map) {
    return MahasiswaModel(
      id: map['id'] as int?,
      nama: (map['nama'] as String?) ?? '',
      nim: (map['nim'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      prodi: (map['prodi'] as String?) ?? '',
      semester: (map['semester'] as int?) ?? 1,
      judulSkripsi: (map['judul_skripsi'] as String?) ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'nama': nama,
      'nim': nim,
      'email': email,
      'prodi': prodi,
      'semester': semester,
      'judul_skripsi': judulSkripsi,
    };
  }
}
