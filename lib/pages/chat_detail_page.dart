import 'package:flutter/material.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/service/skriva_chat_service.dart';
import 'package:test/theme/jadwal_theme.dart';

class ChatDetailPage extends StatefulWidget {
  final int? dosenId;
  final int? mahasiswaId;
  final String? namaDosen;

  const ChatDetailPage({
    super.key,
    this.dosenId,
    this.mahasiswaId,
    this.namaDosen,
  });

  @override
  State<ChatDetailPage> createState() =>
      _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  static const olive = Color(0xFF694A47);
  static const darkOlive = Color(0xFF523B39);
  static const blue = Color(0xFF96C1C5);
  static const cream = Color(0xFFFFF0DE);
  static const lightBlue = Color(0xFFE5F0EF);

  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  final service = SkrivaChatService.instance;

  List<Map<String, Object?>> messages = [];
  List<String> pesanOtomatis = [];

  int? mahasiswaId;
  int? dosenId;
  int? akunId;

  String namaLawanBicara = 'Konsultasi Skripsi';
  String role = '';

  bool loading = true;
  bool mengirim = false;

  @override
  void initState() {
    super.initState();
    muatChat();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ===================================================
  // AKUN DAN PASANGAN CHAT
  // ===================================================

  Future<void> muatChat() async {
    try {
      final akun = await AuthDatabase.instance.sesiAktif();

      if (akun == null) {
        throw StateError(
          'Silakan login terlebih dahulu.',
        );
      }

      final idAktif = akun['id'] as int;
      final roleAktif = akun['role']?.toString() ?? '';

      int? idMahasiswa;
      int? idDosen;
      String nama = '';

      final db = await DatabaseHelper.instance.database;

      if (roleAktif == 'mahasiswa') {
        idMahasiswa = idAktif;
        idDosen = widget.dosenId;

        if (idDosen == null) {
          final pembimbing =
              await AuthDatabase.instance.pembimbing(
            idMahasiswa,
          );

          if (pembimbing.isEmpty) {
            throw StateError(
              'Belum ada dosen pembimbing.',
            );
          }

          idDosen = pembimbing.first['id'] as int;
          nama = pembimbing.first['nama']?.toString() ?? '';
        }
      } else if (roleAktif == 'dosen') {
        idDosen = idAktif;
        idMahasiswa = widget.mahasiswaId;

        if (idMahasiswa == null) {
          throw StateError(
            'Pilih mahasiswa bimbingan terlebih dahulu.',
          );
        }
      } else {
        throw StateError(
          'Role akun tidak didukung untuk chat.',
        );
      }

      // Pastikan pasangan dosen-mahasiswa benar.
      final pasangan = await db.query(
        'skriva_pembimbing',
        where: 'mahasiswa_id = ? AND dosen_id = ?',
        whereArgs: [idMahasiswa, idDosen],
        limit: 1,
      );

      if (pasangan.isEmpty) {
        throw StateError(
          'Kamu tidak memiliki akses percakapan ini.',
        );
      }

      // Nama lawan bicara diambil dari akun asli.
      final idLawan = roleAktif == 'mahasiswa'
          ? idDosen
          : idMahasiswa;

      final akunLawan = await db.query(
        'skriva_akun',
        columns: ['nama'],
        where: 'id = ?',
        whereArgs: [idLawan],
        limit: 1,
      );

      if (akunLawan.isNotEmpty) {
        nama = akunLawan.first['nama']?.toString() ?? '';
      }

      if (nama.isEmpty) {
        nama = widget.namaDosen ?? 'Konsultasi Skripsi';
      }

      // Ambil pesan asli dari layanan chat dua arah.
      final daftarPesan = await service.pesan(
        mahasiswaId: idMahasiswa,
        dosenId: idDosen,
      );

      // Ambil pesan sistem berdasarkan jadwal aktual.
      final sistem = await buatPesanOtomatis(
        mahasiswa: idMahasiswa,
        dosen: idDosen,
      );

      if (!mounted) return;

      setState(() {
        akunId = idAktif;
        role = roleAktif;
        mahasiswaId = idMahasiswa;
        dosenId = idDosen;
        namaLawanBicara = nama;

        messages = daftarPesan;
        pesanOtomatis = sistem;
        loading = false;
      });

      scrollKeBawah();
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      tampilPesan('Gagal memuat chat: $e');
    }
  }

  // ===================================================
  // PESAN OTOMATIS SKRIVA
  // ===================================================

  Future<List<String>> buatPesanOtomatis({
    required int mahasiswa,
    required int dosen,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final daftar = <String>[
      'Halo! Selamat datang di ruang konsultasi Skriva. '
          'Gunakan chat ini untuk berdiskusi mengenai '
          'skripsi bersama dosen pembimbingmu.',
    ];

    final jadwal = await db.query(
      'skriva_slot_jadwal',
      columns: [
        'tanggal',
        'jam',
        'status',
      ],
      where: 'mahasiswa_id = ? AND dosen_id = ?',
      whereArgs: [mahasiswa, dosen],
      orderBy: 'tanggal DESC, jam DESC',
      limit: 1,
    );

    if (jadwal.isEmpty) {
      return daftar;
    }

    final data = jadwal.first;

    final tanggal = data['tanggal']?.toString() ?? '-';
    final jam = data['jam']?.toString() ?? '-';
    final status = data['status']?.toString() ?? '';

    switch (status) {
      case 'Menunggu':
        daftar.add(
          'Booking bimbingan tanggal $tanggal '
          'pukul $jam WIB sedang menunggu persetujuan dosen.',
        );
        break;

      case 'Terjadwal':
        daftar.add(
          'Jadwal bimbingan tanggal $tanggal '
          'pukul $jam WIB sudah disetujui dosen. '
          'Silakan persiapkan materi bimbinganmu.',
        );
        break;

      case 'Selesai':
        daftar.add(
          'Bimbingan tanggal $tanggal '
          'pukul $jam WIB telah selesai. '
          'Jangan lupa mencatat hasil diskusi dan revisi.',
        );
        break;

      default:
        break;
    }

    return daftar;
  }

  // ===================================================
  // KIRIM PESAN ASLI
  // ===================================================

  Future<void> kirimPesan() async {
    final isi = messageController.text.trim();

    if (isi.isEmpty || mengirim) return;

    if (mahasiswaId == null || dosenId == null) {
      tampilPesan('Percakapan belum siap.');
      return;
    }

    setState(() => mengirim = true);

    try {
      await service.kirim(
        mahasiswaId: mahasiswaId!,
        dosenId: dosenId!,
        isi: isi,
      );

      messageController.clear();

      await muatChat();
    } catch (e) {
      tampilPesan('Gagal mengirim pesan: $e');
    } finally {
      if (mounted) {
        setState(() => mengirim = false);
      }
    }
  }

  void tampilPesan(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void scrollKeBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) {
        return;
      }

      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
      );
    });
  }

  // ===================================================
  // TAMPILAN BUBBLE
  // ===================================================

  Widget bubblePesan({
    required String isi,
    required bool milikSaya,
  }) {
    return Align(
      alignment: milikSaya
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 290,
        ),
        margin: EdgeInsets.only(
          bottom: 10,
          left: milikSaya ? 55 : 0,
          right: milikSaya ? 0 : 55,
        ),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: milikSaya ? blue : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          isi,
          style: TextStyle(
            color: milikSaya
                ? Colors.white
                : darkOlive,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget bubbleSistem(String isi) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: lightBlue,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: olive,
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  'PESAN SISTEM SKRIVA',
                  style: TextStyle(
                    color: olive,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              isi,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkOlive,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget daftarPercakapan() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: olive,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: muatChat,
      child: ListView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          18,
          16,
          18,
          20,
        ),
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: Text(
                'Riwayat Percakapan',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ),
          ),

          // Pesan otomatis bukan pesan dosen.
          ...pesanOtomatis.map(bubbleSistem),

          if (messages.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Belum ada pesan pribadi.\n'
                'Mulai konsultasi melalui kolom pesan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),

          ...messages.map((item) {
            final isi =
                item['isi']?.toString() ??
                item['pesan']?.toString() ??
                '';

            final pengirimId = item['pengirim_id'];

            final pengirim =
                item['pengirim']?.toString() ?? '';

            // Kompatibel dengan pesan yang memakai
            // ID pengirim maupun label pengirim.
            final milikSaya = pengirimId != null
                ? pengirimId.toString() ==
                    akunId.toString()
                : pengirim == role;

            if (pengirim == 'sistem') {
              return bubbleSistem(isi);
            }

            return bubblePesan(
              isi: isi,
              milikSaya: milikSaya,
            );
          }),
        ],
      ),
    );
  }

  // ===================================================
  // HALAMAN CHAT
  // ===================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedPage(
      child: Scaffold(
        backgroundColor: cream,
        appBar: AppBar(
          backgroundColor: olive,
          foregroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                namaLawanBicara,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                role == 'dosen'
                    ? 'Mahasiswa Bimbingan'
                    : 'Dosen Pembimbing',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Muat Ulang Chat',
              icon: const Icon(Icons.refresh),
              onPressed: muatChat,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: daftarPercakapan(),
            ),

            // KOLOM KIRIM PESAN
            Container(
              padding: const EdgeInsets.fromLTRB(
                14,
                10,
                14,
                14,
              ),
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: cream,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: messageController,
                          enabled: !loading && !mengirim,
                          maxLines: 4,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => kirimPesan(),
                          decoration: const InputDecoration(
                            hintText: 'Tulis pesan...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed:
                          loading || mengirim
                              ? null
                              : kirimPesan,
                      style: IconButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                      ),
                      icon: mengirim
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
