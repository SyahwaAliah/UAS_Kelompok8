/// Representasi satu baris tabel checklist.
class ChecklistModel {
  final int? id;
  final String kegiatan;
  final bool selesai;

  const ChecklistModel({
    this.id,
    required this.kegiatan,
    this.selesai = false,
  });

  factory ChecklistModel.fromMap(Map<String, Object?> map) {
    return ChecklistModel(
      id: map['id'] as int?,
      kegiatan: (map['kegiatan'] as String?) ?? '',
      selesai: map['selesai'] == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'kegiatan': kegiatan,
      'selesai': selesai ? 1 : 0,
    };
  }
}
