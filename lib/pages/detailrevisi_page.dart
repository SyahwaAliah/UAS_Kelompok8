import 'package:flutter/material.dart';

class DetailRevisiPage {
  static const Color maroon = Color(0xFF694A47);
  static const Color darkMaroon = Color(0xFF523B39);
  static const Color lightSky = Color(0xFFD9ECEC);
  static const Color lightAmber = Color(0xFFFFF5E5);

  // Lima tahapan yang dihitung pada progress dashboard.
  static const List<String> daftarTahapan = [
    'Penentuan Topik',
    'Bab 1',
    'Bab 2',
    'Bab 3',
    'Seminar Proposal',
  ];

  static void buka(
    BuildContext context, {
    required List<bool> statusAwal,
    required ValueChanged<List<bool>> onProgressChanged,
  }) {
    // Salin status agar checklist dialog bisa diperbarui.
    List<bool> status = List<bool>.from(statusAwal);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Detail Revisi',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            int selesai = status.where((item) => item).length;
            int progress = ((selesai / status.length) * 100).round();

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Revisi Bimbingan',
                      style: TextStyle(
                        color: darkMaroon,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Menampilkan status revisi dari dosen.
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: lightAmber,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.assignment_late_rounded,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Revisi Bab 2 & Bab 3',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Status: Revisi Mayor (Perbaikan Total)',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Checklist ini mengubah progress di dashboard.
                    const Text(
                      'Checklist Progress Skripsi',
                      style: TextStyle(
                        color: darkMaroon,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$selesai dari 5 tahapan selesai ($progress%)',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: selesai / status.length,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF96C1C5),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Centang tahapan yang sudah selesai.
                    for (int i = 0; i < daftarTahapan.length; i++)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: maroon,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          daftarTahapan[i],
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: status[i],
                        onChanged: (value) {
                          setDialogState(() {
                            status[i] = value ?? false;
                          });
                          // Kirim perubahan ke dashboard saat dicentang.
                          onProgressChanged(List<bool>.from(status));
                        },
                      ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: lightSky,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Poin Perbaikan dari Dosen',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Perbarui landasan teori dengan jurnal di atas tahun 2020.',
                          ),
                          SizedBox(height: 4),
                          Text(
                            '• Perbaiki metode pengambilan sampel pada Bab 3.',
                          ),
                          SizedBox(height: 4),
                          Text('• Rapikan format penulisan daftar pustaka.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4E6E3),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.alarm_on_rounded, color: maroon),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Target Pengumpulan Kembali',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Senin, 12 Oktober 2026 (Sebelum Jam 12.00 WIB)',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            color: maroon,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final slide =
            Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }
}
