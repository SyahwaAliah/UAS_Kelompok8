import 'package:flutter/material.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/database/auth_database.dart';
import 'package:test/pages/chat_detail_page.dart';

class DetailBimbinganPage {
  static void open(BuildContext context, {int? slotId}) {
    showDialog<void>(
      context: context,
      builder: (_) => _DetailBimbinganDialog(slotId: slotId),
    );
  }
}

class _DetailBimbinganDialog extends StatefulWidget {
  final int? slotId;

  const _DetailBimbinganDialog({this.slotId});

  @override
  State<_DetailBimbinganDialog> createState() =>
      _DetailBimbinganDialogState();
}

class _DetailBimbinganDialogState
    extends State<_DetailBimbinganDialog> {
  static const olive = Color(0xFF694A47);
  static const blue = Color(0xFF96C1C5);
  static const darkOlive = Color(0xFF523B39);

  Map<String, Object?>? jadwal;
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<void> muat() async {
    try {
      final akun = await AuthDatabase.instance.sesiAktif();

      if (akun == null || akun['role'] != 'mahasiswa') {
        throw StateError('Silakan login sebagai mahasiswa.');
      }

      final db = await DatabaseHelper.instance.database;
      final mahasiswaId = akun['id'] as int;

      final rows = await db.rawQuery('''
        SELECT
          j.*,
          d.nama AS nama_dosen
        FROM skriva_slot_jadwal j
        JOIN skriva_akun d ON d.id = j.dosen_id
        JOIN skriva_pembimbing p
          ON p.dosen_id = j.dosen_id
          AND p.mahasiswa_id = j.mahasiswa_id
        WHERE j.mahasiswa_id = ?
          AND (? IS NULL OR j.id = ?)
        ORDER BY
          CASE
            WHEN j.status = 'Terjadwal' THEN 0
            WHEN j.status = 'Menunggu' THEN 1
            ELSE 2
          END,
          j.tanggal ASC,
          j.jam ASC
        LIMIT 1
      ''', [mahasiswaId, widget.slotId, widget.slotId]);

      if (!mounted) return;

      setState(() {
        jadwal = rows.isEmpty ? null : rows.first;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = '$e';
        loading = false;
      });
    }
  }

  Widget info(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: olive),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkOlive,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void bukaChat() {
    final data = jadwal;
    if (data == null) return;

    final dosenId = data['dosen_id'] as int;
    final namaDosen = data['nama_dosen']?.toString() ?? '';

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          dosenId: dosenId,
          namaDosen: namaDosen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = jadwal;
    final status = data?['status']?.toString() ?? '';

    final bolehChat = status == 'Terjadwal' ||
        status == 'Selesai';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: olive),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Bimbingan',
                    style: TextStyle(
                      color: darkOlive,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (errorMessage != null)
                    Text(errorMessage!),
                  if (data == null && errorMessage == null)
                    const Text(
                      'Belum ada booking bimbingan untuk akun ini.',
                    ),
                  if (data != null) ...[
                    info(
                      'Dosen Pembimbing',
                      data['nama_dosen']?.toString() ?? '-',
                      Icons.person,
                    ),
                    info(
                      'Tanggal',
                      data['tanggal']?.toString() ?? '-',
                      Icons.calendar_month,
                    ),
                    info(
                      'Jam',
                      '${data['jam']} WIB',
                      Icons.access_time,
                    ),
                    info(
                      'Mode Bimbingan',
                      data['mode']?.toString() ?? '-',
                      Icons.location_on,
                    ),
                    info(
                      'Status Bimbingan',
                      status,
                      Icons.info_outline,
                    ),
                    const SizedBox(height: 12),
                    if (bolehChat) ...[
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5E5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Jadwal bimbinganmu telah dikonfirmasi. '
                          'Kamu bisa memulai konsultasi bersama '
                          'dosen pembimbing melalui Chat.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: bukaChat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.chat_rounded),
                          label: const Text('Chat Dosen'),
                        ),
                      ),
                    ],
                    if (status == 'Menunggu')
                      const Text(
                        'Booking sedang menunggu persetujuan dosen.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(color: olive),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
