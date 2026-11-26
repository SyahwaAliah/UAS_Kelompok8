
import 'package:flutter/material.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/service/skriva_chat_service.dart';
import 'package:test/widgets/skriva_dashboard_ui.dart';

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
  static const blue = SkrivaDashColors.blue;
  static const dark = SkrivaDashColors.dark;
  static const lime = SkrivaDashColors.lime;

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

  // =====================================================
  // LOAD CHAT DAN VALIDASI PASANGAN AKUN
  // =====================================================

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
          nama =
              pembimbing.first['nama']?.toString() ?? '';
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

      // Pastikan relasi mahasiswa dan dosen benar.
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
        nama =
            akunLawan.first['nama']?.toString() ?? '';
      }

      if (nama.isEmpty) {
        nama =
            widget.namaDosen ?? 'Konsultasi Skripsi';
      }

      final daftarPesan = await service.pesan(
        mahasiswaId: idMahasiswa,
        dosenId: idDosen,
      );

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

  // =====================================================
  // PESAN SISTEM SKRIVA
  // Tidak dikirim sebagai pesan palsu dari dosen.
  // =====================================================

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

    if (jadwal.isEmpty) return daftar;

    final data = jadwal.first;

    final tanggal =
        data['tanggal']?.toString() ?? '-';

    final jam =
        data['jam']?.toString() ?? '-';

    final status =
        data['status']?.toString() ?? '';

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

  // =====================================================
  // KIRIM PESAN
  // =====================================================

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
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void scrollKeBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) {
        return;
      }

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  // =====================================================
  // BUBBLE PESAN
  // =====================================================

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
          bottom: 11,
          left: milikSaya ? 45 : 0,
          right: milikSaya ? 0 : 45,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          gradient: milikSaya
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4389F0),
                    Color(0xFF2463EB),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white,
                    SkrivaDashColors.softBlue
                        .withValues(alpha: 0.35),
                  ],
                ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(
              milikSaya ? 20 : 5,
            ),
            bottomRight: Radius.circular(
              milikSaya ? 5 : 20,
            ),
          ),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: milikSaya ? 0.25 : 0.95,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: SkrivaDashColors.blue.withValues(
                alpha: milikSaya ? 0.14 : 0.05,
              ),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          isi,
          style: TextStyle(
            color: milikSaya ? Colors.white : dark,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // =====================================================
  // PESAN SISTEM
  // =====================================================

  Widget bubbleSistem(String isi) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFC8F4A4),
              Color(0xFFEAFADB),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
            width: 1.3,
          ),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: dark,
                  size: 15,
                ),
                SizedBox(width: 6),
                Text(
                  'PESAN SISTEM SKRIVA',
                  style: TextStyle(
                    color: dark,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            Text(
              isi,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: dark,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // DAFTAR PERCAKAPAN
  // =====================================================

  Widget daftarPercakapan() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: blue,
        ),
      );
    }

    return RefreshIndicator(
      color: blue,
      onRefresh: muatChat,
      child: ListView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          18,
          18,
          18,
          20,
        ),
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'YOUR CONVERSATION',
                style: TextStyle(
                  color: SkrivaDashColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ),

          ...pesanOtomatis.map(bubbleSistem),

          if (messages.isEmpty)
            const Padding(
              padding: EdgeInsets.all(22),
              child: Text(
                'Belum ada pesan pribadi.\n'
                'Mulai konsultasi melalui kolom pesan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SkrivaDashColors.muted,
                  fontSize: 12,
                  height: 1.5,
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

  // =====================================================
  // CHAT INPUT
  // =====================================================

  Widget _kolomPesan() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        10,
        14,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE7EDF4),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: SkrivaDashColors.background,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFDDEAF2),
                  ),
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
                      color: SkrivaDashColors.muted,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4389F0),
                    Color(0xFF2463EB),
                  ],
                ),
                borderRadius: BorderRadius.circular(17),
              ),
              child: IconButton(
                onPressed: loading || mengirim
                    ? null
                    : kirimPesan,
                icon: mengirim
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // MAIN CHAT PAGE
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkrivaDashColors.background,
      appBar: AppBar(
        backgroundColor: SkrivaDashColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: dark,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: lime,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: blue,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    namaLawanBicara,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: dark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    role == 'dosen'
                        ? 'Mahasiswa Bimbingan'
                        : 'Dosen Pembimbing',
                    style: const TextStyle(
                      color: SkrivaDashColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat Ulang Chat',
            onPressed: muatChat,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6F8FB),
              Color(0xFFEDF8F8),
              Color(0xFFF8F5FF),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: daftarPercakapan(),
            ),
            _kolomPesan(),
          ],
        ),
      ),
    );
  }
}
