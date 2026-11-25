class RevisiModel {
  final int? id;
  final String judul;
  final String catatan;
  final String status;
  final String? deadline;

  const RevisiModel({
    this.id,
    required this.judul,
    this.catatan = '',
    this.status = 'Belum Selesai',
    this.deadline,
  });

  factory RevisiModel.fromMap(Map<String, Object?> map) {
    return RevisiModel(
      id: map['id'] as int?,
      judul: (map['judul'] as String?) ?? '',
      catatan: (map['catatan'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'Belum Selesai',
      deadline: map['deadline'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'judul': judul,
      'catatan': catatan,
      'status': status,
      'deadline': deadline,
    };
  }
}
