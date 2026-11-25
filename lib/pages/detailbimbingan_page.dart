import 'package:flutter/material.dart';
import 'package:test/database/database_helper.dart';

class DetailBimbinganPage {
  static const Color olive = Color(0xFF694A47);
  static const Color darkOlive = Color(0xFF523B39);
  static const Color softGreen = Color(0xFFEAF3F2);
  static const Color lightPeach = Color(0xFFFFF7EC);
  static const Color orange = Color(0xFF96C1C5);
  static const Color textGrey = Color(0xFF8B7774);

  static void open(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Detail Bimbingan',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const _DetailBimbinganContent();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
    );
  }

  static Widget infoCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: olive, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: olive,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBimbinganContent extends StatefulWidget {
  const _DetailBimbinganContent();

  @override
  State<_DetailBimbinganContent> createState() =>
      _DetailBimbinganContentState();
}

class _DetailBimbinganContentState extends State<_DetailBimbinganContent> {
  Map<String, Object?>? jadwal;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    muatJadwal();
  }

  Future<void> muatJadwal() async {
    try {
      final rows = await DatabaseHelper.instance.ambilJadwal();

      final sekarang = DateTime.now();
      final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);

      Map<String, Object?>? terpilih;

      for (final item in rows) {
        final tanggal = DateTime.tryParse(item['tanggal']?.toString() ?? '');

        if (tanggal != null &&
            !tanggal.isBefore(hariIni) &&
            item['status'] != 'Selesai') {
          terpilih = item;
          break;
        }
      }

      if (terpilih == null && rows.isNotEmpty) {
        terpilih = rows.last;
      }

      if (!mounted) return;

      setState(() {
        jadwal = terpilih;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat jadwal: $e')));
    }
  }

  Future<void> ubahStatus(String status) async {
    final id = jadwal?['id'] as int?;

    if (id == null) return;

    try {
      await DatabaseHelper.instance.ubahStatusJadwal(id, status);

      await muatJadwal();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status berubah menjadi $status')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengubah status: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: DetailBimbinganPage.olive,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Bimbingan',
                      style: TextStyle(
                        color: DetailBimbinganPage.darkOlive,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (jadwal == null)
                      const Text('Belum ada jadwal bimbingan.'),
                    if (jadwal != null) ...[
                      DetailBimbinganPage.infoCard(
                        color: DetailBimbinganPage.softGreen,
                        icon: Icons.menu_book_rounded,
                        title: 'Bimbingan Skripsi',
                        subtitle: 'Konsultasi Skripsi',
                      ),
                      const SizedBox(height: 10),
                      DetailBimbinganPage.infoCard(
                        color: DetailBimbinganPage.lightPeach,
                        icon: Icons.person,
                        title: 'Dosen Pembimbing',
                        subtitle: jadwal!['dosen']?.toString() ?? '-',
                      ),
                      const SizedBox(height: 10),
                      DetailBimbinganPage.infoCard(
                        color: DetailBimbinganPage.softGreen,
                        icon: Icons.calendar_month_rounded,
                        title: 'Tanggal & Waktu',
                        subtitle:
                            '${jadwal!['tanggal']}\n'
                            '${jadwal!['jam']} WIB',
                      ),
                      const SizedBox(height: 10),
                      DetailBimbinganPage.infoCard(
                        color: DetailBimbinganPage.lightPeach,
                        icon: Icons.location_on_rounded,
                        title: 'Mode Bimbingan',
                        subtitle: jadwal!['mode']?.toString() ?? '-',
                      ),
                      const SizedBox(height: 10),
                      DetailBimbinganPage.infoCard(
                        color: DetailBimbinganPage.softGreen,
                        icon: Icons.info_outline,
                        title: 'Status Bimbingan',
                        subtitle: jadwal!['status']?.toString() ?? 'Menunggu',
                      ),
                      const SizedBox(height: 16),
                      if (jadwal!['status'] != 'Selesai')
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            '${jadwal!['id']}-'
                            '${jadwal!['status']}',
                          ),
                          initialValue:
                              jadwal!['status']?.toString() ?? 'Menunggu',
                          decoration: InputDecoration(
                            labelText: 'Ubah Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Menunggu',
                              child: Text('Menunggu'),
                            ),
                            DropdownMenuItem(
                              value: 'Terjadwal',
                              child: Text('Terjadwal'),
                            ),
                            DropdownMenuItem(
                              value: 'Selesai',
                              child: Text('Selesai'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              ubahStatus(value);
                            }
                          },
                        ),
                    ],
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            color: DetailBimbinganPage.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
