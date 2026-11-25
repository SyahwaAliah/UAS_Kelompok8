class DokumenModel {
  final int? id;
  final int? mahasiswaId;
  final String namaFile;
  final String pathFile;
  final String kategori;
  final String tanggalUpload;

  const DokumenModel({
    this.id,
    this.mahasiswaId,
    required this.namaFile,
    required this.pathFile,
    this.kategori = 'Skripsi',
    required this.tanggalUpload,
  });

  factory DokumenModel.fromMap(Map<String, Object?> map) {
    return DokumenModel(
      id: map['id'] as int?,
      mahasiswaId: map['mahasiswa_id'] as int?,
      namaFile: (map['nama_file'] as String?) ?? '',
      pathFile: (map['path_file'] as String?) ?? '',
      kategori: (map['kategori'] as String?) ?? 'Skripsi',
      tanggalUpload: (map['tanggal_upload'] as String?) ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'mahasiswa_id': mahasiswaId,
      'nama_file': namaFile,
      'path_file': pathFile,
      'kategori': kategori,
      'tanggal_upload': tanggalUpload,
    };
  }
}
