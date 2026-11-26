import 'package:flutter/material.dart';
import 'package:test/database/auth_database.dart';
import 'package:test/database/revisi_bimbingan_service.dart';

class RevisiDatabasePage extends StatefulWidget {
  const RevisiDatabasePage({super.key});

  @override
  State<RevisiDatabasePage> createState() =>
      _RevisiDatabasePageState();
}

class _RevisiDatabasePageState extends State<RevisiDatabasePage> {
  static const brown = Color(0xFF694A47);
  static const cream = Color(0xFFFFF0DE);
  static const teal = Color(0xFF96C1C5);

  final service = RevisiBimbinganService.instance;
  List<Map<String, Object?>> revisi = [];
  List<Map<String, Object?>> mahasiswa = [];

  bool dosen = false;
  bool loading = true;
  bool proses = false;

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<void> muat() async {
    try {
      final akun = await AuthDatabase.instance.sesiAktif();
      if (akun == null) throw StateError('Silakan login.');

      final isDosen = akun['role'] == 'dosen';
      final rows = await service.semua();

      final daftar = isDosen
          ? await AuthDatabase.instance.mahasiswaBimbingan(
              akun['id'] as int,
            )
          : <Map<String, Object?>>[];

      if (!mounted) return;
      setState(() {
        dosen = isDosen;
        revisi = rows;
        mahasiswa = daftar;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      pesan('$e');
    }
  }

  void pesan(String isi) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isi)),
    );
  }

  Future<void> aksi(Future<void> Function() callback) async {
    if (proses) return;
    setState(() => proses = true);
    try {
      await callback();
      await muat();
    } catch (e) {
      pesan('$e');
    } finally {
      if (mounted) setState(() => proses = false);
    }
  }

  Future<void> tambahRevisi() async {
    if (mahasiswa.isEmpty) {
      pesan('Belum ada mahasiswa bimbingan.');
      return;
    }

    int mahasiswaId = mahasiswa.first['id'] as int;
    final judul = TextEditingController();
    final instruksi = TextEditingController();
    DateTime? deadline;

    final simpan = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: const Text('Buat Revisi Mahasiswa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: mahasiswaId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Mahasiswa',
                  ),
                  items: mahasiswa.map((m) {
                    return DropdownMenuItem(
                      value: m['id'] as int,
                      child: Text(
                        m['nama'].toString(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      updateDialog(() => mahasiswaId = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: judul,
                  decoration: const InputDecoration(
                    labelText: 'Judul Revisi',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: instruksi,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Instruksi Dosen',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.event),
                  label: Text(
                    deadline == null
                        ? 'Pilih Deadline (Opsional)'
                        : '${deadline!.day}/${deadline!.month}/${deadline!.year}',
                  ),
                  onPressed: () async {
                    final tanggal = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 730),
                      ),
                    );
                    if (tanggal != null) {
                      updateDialog(() => deadline = tanggal);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    final title = judul.text.trim();
    final note = instruksi.text.trim();
    judul.dispose();
    instruksi.dispose();

    if (simpan != true) return;

    await aksi(() async {
      await service.buat(
        mahasiswaId: mahasiswaId,
        judul: title,
        catatan: note,
        deadline: deadline?.toIso8601String().substring(0, 10),
      );
      pesan('Revisi berhasil dikirim ke mahasiswa.');
    });
  }

  Future<void> kirimHasil(Map<String, Object?> item) async {
    final controller = TextEditingController(
      text: item['tanggapan_mahasiswa']?.toString() ?? '',
    );

    final simpan = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kirim Hasil Revisi'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText:
                'Jelaskan apa yang sudah kamu perbaiki...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kirim ke Dosen'),
          ),
        ],
      ),
    );

    final isi = controller.text;
    controller.dispose();
    if (simpan != true) return;

    await aksi(() => service.kirimHasil(
      item['id'] as int,
      isi,
    ));
  }

  Future<void> review(
    Map<String, Object?> item,
    bool setuju,
  ) async {
    final controller = TextEditingController();

    final simpan = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          setuju ? 'Setujui Revisi?' : 'Minta Perbaikan?',
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: setuju
                ? 'Komentar (opsional)'
                : 'Alasan perbaikan (wajib)',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    final feedback = controller.text;
    controller.dispose();
    if (simpan != true) return;

    await aksi(() => service.review(
      revisiId: item['id'] as int,
      disetujui: setuju,
      feedback: feedback,
    ));
  }

  Color warnaStatus(String value) {
    switch (value) {
      case 'Selesai':
        return Colors.green;
      case 'Menunggu Review':
        return Colors.blue;
      case 'Perlu Perbaikan':
        return Colors.deepOrange;
      default:
        return brown;
    }
  }

  Widget kartu(Map<String, Object?> item) {
    final status = item['status']?.toString() ?? '';
    final id = item['id'] as int;
    final tanggapan =
        item['tanggapan_mahasiswa']?.toString() ?? '';
    final feedback =
        item['umpan_balik_dosen']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['judul']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dosen
                  ? 'Mahasiswa: ${item['nama_mahasiswa']}'
                  : 'Dosen: ${item['nama_dosen']}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text('Instruksi: ${item['catatan']}'),
            if (item['deadline'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Deadline: ${item['deadline']}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            const SizedBox(height: 10),
            Chip(
              label: Text(status),
              backgroundColor:
                  warnaStatus(status).withValues(alpha: 0.12),
              labelStyle: TextStyle(color: warnaStatus(status)),
            ),
            if (tanggapan.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Hasil mahasiswa: $tanggapan'),
            ],
            if (feedback.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Feedback dosen: $feedback'),
            ],
            const SizedBox(height: 12),
            if (!dosen &&
                (status == 'Belum Dikerjakan' ||
                    status == 'Perlu Perbaikan'))
              tombol(
                'Mulai Kerjakan',
                () => aksi(() => service.mulai(id)),
              ),
            if (!dosen && status == 'Dalam Pengerjaan')
              tombol(
                'Kirim Hasil Revisi',
                () => kirimHasil(item),
              ),
            if (dosen && status == 'Menunggu Review') ...[
              tombol(
                'Setujui Revisi',
                () => review(item, true),
              ),
              const SizedBox(height: 8),
              tombol(
                'Minta Perbaikan',
                () => review(item, false),
                outline: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget tombol(
    String label,
    VoidCallback onTap, {
    bool outline = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: outline
          ? OutlinedButton(
              onPressed: proses ? null : onTap,
              child: Text(label),
            )
          : ElevatedButton(
              onPressed: proses ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: brown,
                foregroundColor: Colors.white,
              ),
              child: Text(label),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: Text(dosen ? 'Kelola Revisi' : 'Revisi Skripsi'),
        actions: [
          IconButton(
            onPressed: muat,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: dosen && !loading
          ? FloatingActionButton.extended(
              onPressed: proses ? null : tambahRevisi,
              backgroundColor: brown,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Buat Revisi'),
            )
          : null,
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: brown),
            )
          : RefreshIndicator(
              onRefresh: muat,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 95),
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: teal.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      dosen
                          ? 'Buat revisi dan tinjau hasil pekerjaan mahasiswa.'
                          : 'Kerjakan revisi dari dosen pembimbingmu.',
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (revisi.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(35),
                      child: Center(
                        child: Text('Belum ada revisi.'),
                      ),
                    ),
                  ...revisi.map(kartu),
                ],
              ),
            ),
    );
  }
}
