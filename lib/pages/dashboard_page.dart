
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:test/database/auth_database.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/database/jadwal_bimbingan_service.dart';
import 'package:test/database/progress_akun_service.dart';
import 'package:test/database/revisi_bimbingan_service.dart';
import 'package:test/models/checklist_model.dart';

import 'package:test/pages/login_page.dart';
import 'package:test/pages/profile_mahasiswa_page.dart';
import 'package:test/pages/progress_skripsi_page.dart';
import 'package:test/pages/jadwal_bimbingan_baru_page.dart';
import 'package:test/pages/revisi_database_page.dart';
import 'package:test/pages/notes_page.dart';
import 'package:test/pages/chat_page.dart';
import 'package:test/pages/notification_page.dart';
import 'package:test/pages/video_call_page.dart';
import 'package:test/pages/detailbimbingan_page.dart';
import 'package:test/pages/dokumen_page.dart';

// =====================================================
// DASHBOARD MAHASISWA
// =====================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // =====================================================
  // COLORS
  // =====================================================

  static const Color blue = Color(0xFF2463EB);
  static const Color darkBlue = Color(0xFF1647B5);
  static const Color dark = Color(0xFF243F53);
  static const Color muted = Color(0xFF74818D);

  static const Color lime = Color(0xFFC8F4A4);
  static const Color softBlue = Color(0xFFB9E8EF);
  static const Color peach = Color(0xFFFFDAC7);
  static const Color lavender = Color(0xFFDAD5FF);
  static const Color background = Color(0xFFF6F8FB);

  // =====================================================
  // DATA
  // =====================================================

  String nama = 'Mahasiswa';

  int avatarIndex = 0;
  String? fotoCustom;

  List<ChecklistModel> tahapan = [];

  Map<String, Object?>? jadwalTerdekat;
  Map<String, Object?>? revisiTerakhir;
  Map<String, Object?>? notesTerakhir;

  bool loading = true;

  int get totalSelesai =>
      tahapan.where((item) => item.selesai).length;

  int get persentase => tahapan.isEmpty
      ? 0
      : ((totalSelesai / tahapan.length) * 100).round();

  @override
  void initState() {
    super.initState();
    muatDashboard();
  }

  // =====================================================
  // LOAD DASHBOARD
  // =====================================================

  Future<void> muatDashboard() async {
    try {
      final akun = await AuthDatabase.instance.sesiAktif();

      if (akun == null || akun['role'] != 'mahasiswa') {
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
          (_) => false,
        );
        return;
      }

      final id = akun['id'] as int;
      final db = await DatabaseHelper.instance.database;

      // Checklist asli milik mahasiswa.
      final daftarProgress =
          await ProgressAkunService.instance.semua();

      // Revisi asli per akun.
      final daftarRevisi =
          await RevisiBimbinganService.instance.semua();

      // Jadwal dosen pembimbing.
      final daftarJadwal =
          await JadwalBimbinganService.instance.slotMahasiswa();

      // Visual profil per akun.
      await db.execute('''
        CREATE TABLE IF NOT EXISTS skriva_profile_visual (
          akun_id INTEGER PRIMARY KEY,
          avatar_index INTEGER NOT NULL DEFAULT 0,
          foto_custom TEXT
        )
      ''');

      // Notes per akun.
      await db.execute('''
        CREATE TABLE IF NOT EXISTS skriva_notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          akun_id INTEGER NOT NULL,
          judul TEXT NOT NULL,
          isi TEXT NOT NULL,
          diperbarui TEXT NOT NULL
        )
      ''');

      final avatarRows = await db.query(
        'skriva_profile_visual',
        where: 'akun_id = ?',
        whereArgs: [id],
        limit: 1,
      );

      final notesRows = await db.query(
        'skriva_notes',
        where: 'akun_id = ?',
        whereArgs: [id],
        orderBy: 'diperbarui DESC, id DESC',
        limit: 1,
      );

      final mahasiswaRows = await db.query(
        'mahasiswa',
        where: 'nim = ?',
        whereArgs: [akun['nomor_induk']],
        limit: 1,
      );

      // Ambil jadwal booking milik mahasiswa,
      // bukan slot milik mahasiswa lain.
      final sekarang = DateTime.now();

      Map<String, Object?>? upcoming;

      for (final item in daftarJadwal) {
        final mahasiswaId = item['mahasiswa_id'];

        if (mahasiswaId != id) continue;

        final status = item['status']?.toString() ?? '';

        if (status != 'Menunggu' &&
            status != 'Terjadwal') {
          continue;
        }

        final tanggal = item['tanggal']?.toString() ?? '';
        final jam = item['jam']?.toString() ?? '';

        final jamAwal =
            jam.split(' - ').first.replaceAll('.', ':');

        final waktu = DateTime.tryParse(
          '${tanggal}T$jamAwal:00',
        );

        if (waktu == null || waktu.isBefore(sekarang)) {
          continue;
        }

        if (upcoming == null) {
          upcoming = item;
        } else {
          final tanggalLama =
              upcoming['tanggal']?.toString() ?? '';

          final jamLama =
              upcoming['jam']?.toString() ?? '';

          final waktuLama = DateTime.tryParse(
            '${tanggalLama}T'
            '${jamLama.split(' - ').first.replaceAll('.', ':')}:00',
          );

          if (waktuLama == null ||
              waktu.isBefore(waktuLama)) {
            upcoming = item;
          }
        }
      }

      if (!mounted) return;

      final namaProfil = mahasiswaRows.isEmpty
          ? ''
          : mahasiswaRows.first['nama']?.toString() ?? '';

      setState(() {
        nama = namaProfil.isNotEmpty
            ? namaProfil
            : akun['nama']?.toString() ?? 'Mahasiswa';

        avatarIndex = avatarRows.isEmpty
            ? 0
            : avatarRows.first['avatar_index'] as int? ?? 0;

        fotoCustom = avatarRows.isEmpty
            ? null
            : avatarRows.first['foto_custom']?.toString();

        tahapan = daftarProgress;
        jadwalTerdekat = upcoming;

        revisiTerakhir = daftarRevisi.isEmpty
            ? null
            : daftarRevisi.first;

        notesTerakhir = notesRows.isEmpty
            ? null
            : notesRows.first;

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat dashboard: $e'),
        ),
      );
    }
  }

  // =====================================================
  // NAVIGATION
  // =====================================================

  Future<void> bukaHalaman(Widget halaman) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => halaman,
      ),
    );

    if (mounted) {
      await muatDashboard();
    }
  }

  void bukaProfil() {
    bukaHalaman(const ProfileMahasiswaPage());
  }

  void bukaProgress() {
    bukaHalaman(const ProgressSkripsiPage());
  }

  void bukaJadwal() {
    bukaHalaman(const JadwalBimbinganBaruPage());
  }

  void bukaRevisi() {
    bukaHalaman(
      RevisiDatabasePage(
        fokusRevisiId: revisiTerakhir?['id'] as int?,
      ),
    );
  }

  void bukaNotes() {
    bukaHalaman(const NotesPage());
  }

  void bukaDokumen() {
    bukaHalaman(const DokumenPage());
  }

  void bukaChat() {
    bukaHalaman(const ChatPage());
  }

  void bukaNotifikasi() {
    bukaHalaman(const NotificationPage());
  }

  void bukaVideoCall() {
    bukaHalaman(const VideoCallPage());
  }

  void bukaDetailBimbingan() {
    final jadwal = jadwalTerdekat;

    if (jadwal == null) {
      bukaJadwal();
      return;
    }

    DetailBimbinganPage.open(
      context,
      slotId: jadwal['id'] as int,
    );
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> logout() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Yakin ingin keluar dari akun Skriva?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (yakin != true || !mounted) return;

    await AuthDatabase.instance.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (_) => false,
    );
  }

  // =====================================================
  // AVATAR
  // =====================================================

  Widget avatarMahasiswa() {
    const gambar = [
      'assets/icon/icon_albert.jpeg',
      'assets/icon/icon_tracy.jpeg',
      'assets/icon/icon_syahwa.jpeg',
    ];

    if (avatarIndex == 6 &&
        fotoCustom != null &&
        File(fotoCustom!).existsSync()) {
      return Image.file(
        File(fotoCustom!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.person_rounded,
            color: blue,
          );
        },
      );
    }

    if (avatarIndex >= 0 && avatarIndex < gambar.length) {
      return Image.asset(
        gambar[avatarIndex],
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.person_rounded,
            color: blue,
          );
        },
      );
    }

    const icons = [
      Icons.person_rounded,
      Icons.face_rounded,
      Icons.school_rounded,
    ];

    final index = avatarIndex - 3;

    return Icon(
      index >= 0 && index < icons.length
          ? icons[index]
          : Icons.person_rounded,
      color: blue,
      size: 27,
    );
  }

  // =====================================================
  // REUSABLE GLASS CARD
  // =====================================================

  Widget glassCard({
    required Widget child,
    Color tint = Colors.white,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: blue.withValues(alpha: 0.06),
            blurRadius: 23,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.96),
                  tint.withValues(alpha: 0.53),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.95),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // =====================================================
  // SECTION HEADER
  // =====================================================

  Widget judulSection(
    String title, {
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: dark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SKRIVA / STUDENT SPACE',
                style: TextStyle(
                  color: blue,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Hello, $nama!',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: dark,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Ready to make progress today?',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          tooltip: 'Logout',
          onPressed: logout,
          icon: const Icon(
            Icons.logout_rounded,
            color: dark,
          ),
        ),

        const SizedBox(width: 5),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: bukaProfil,
            borderRadius: BorderRadius.circular(17),
            child: Container(
              width: 49,
              height: 49,
              decoration: BoxDecoration(
                color: softBlue,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: avatarMahasiswa(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // MAIN HERO
  // =====================================================

  Widget hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2463EB),
            Color(0xFF4389F0),
            Color(0xFF91CBEA),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: blue.withValues(alpha: 0.20),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -25,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: lime,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'STUDENT / OVERVIEW',
                  style: TextStyle(
                    color: dark,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 19),

              const Text(
                'Create.\nRevise. Graduate.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'One milestone closer to your graduation.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ANIMATED PROGRESS DIAGRAM
  // =====================================================

  Widget diagramProgress() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: persentase / 100,
      ),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 112,
          height: 112,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 11,
                  backgroundColor:
                      blue.withValues(alpha: 0.10),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    blue,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(value * 100).round()}%',
                    style: const TextStyle(
                      color: dark,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'COMPLETE',
                    style: TextStyle(
                      color: muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // =====================================================
  // PROGRESS CARD
  // =====================================================

  Widget kartuProgress() {
    return GestureDetector(
      onTap: bukaProgress,
      child: glassCard(
        tint: softBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'THESIS PROGRESS',
              style: TextStyle(
                color: blue,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 17),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Progress\nat a Glance.',
                        style: TextStyle(
                          color: dark,
                          fontSize: 20,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 13),

                      Text(
                        '$totalSelesai dari '
                        '${tahapan.length} tahapan selesai',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'View milestones →',
                        style: TextStyle(
                          color: blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                diagramProgress(),
              ],
            ),

            if (tahapan.isNotEmpty) ...[
              const SizedBox(height: 17),

              Wrap(
                spacing: 7,
                runSpacing: 8,
                children: tahapan.take(5).map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: item.selesai
                          ? lime
                          : const Color(0xFFE8EEF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.kegiatan,
                      style: const TextStyle(
                        color: dark,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =====================================================
  // QUICK ACTION CARD
  // =====================================================

  Widget kartuMenu({
    required String judul,
    required String keterangan,
    required IconData icon,
    required Color warna,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: glassCard(
          tint: warna,
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: warna,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: dark,
                  size: 25,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                judul,
                style: const TextStyle(
                  color: dark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                keterangan,
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 10),

              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_outward_rounded,
                  color: blue,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // UPCOMING SESSION
  // =====================================================

  Widget kartuBimbingan() {
    final item = jadwalTerdekat;

    return GestureDetector(
      onTap: bukaDetailBimbingan,
      child: glassCard(
        tint: lime,
        child: Row(
          children: [
            Container(
              width: 49,
              height: 49,
              decoration: BoxDecoration(
                color: lime,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.event_available_rounded,
                color: dark,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item == null
                        ? 'Belum Ada Bimbingan'
                        : 'Bimbingan Terdekat',
                    style: const TextStyle(
                      color: dark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    item == null
                        ? 'Booking jadwal dengan dosenmu.'
                        : item['nama_dosen']?.toString() ?? '-',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                    ),
                  ),

                  if (item != null) ...[
                    const SizedBox(height: 8),

                    Text(
                      '${item['tanggal']} • ${item['jam']}',
                      style: const TextStyle(
                        color: blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      item['status']?.toString() ?? '',
                      style: const TextStyle(
                        color: dark,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: blue,
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // LATEST REVISION
  // =====================================================

  Widget kartuRevisi() {
    final item = revisiTerakhir;

    return GestureDetector(
      onTap: bukaRevisi,
      child: glassCard(
        tint: peach,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  color: blue,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'LATEST REVISION',
                    style: TextStyle(
                      color: blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: blue,
                ),
              ],
            ),

            const SizedBox(height: 13),

            Text(
              item?['judul']?.toString() ??
                  'Belum ada revisi',
              style: const TextStyle(
                color: dark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              item?['catatan']?.toString() ??
                  'Revisi dari dosen akan tampil di sini.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),

            if (item != null) ...[
              const SizedBox(height: 11),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: lime,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item['status']?.toString() ?? '-',
                  style: const TextStyle(
                    color: dark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 13),

              const Row(
                children: [
                  Icon(
                    Icons.attach_file_rounded,
                    color: blue,
                    size: 16,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Lihat revisi & lampiran',
                    style: TextStyle(
                      color: blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =====================================================
  // LATEST NOTES
  // =====================================================

  Widget kartuNotes() {
    final item = notesTerakhir;

    return GestureDetector(
      onTap: bukaNotes,
      child: glassCard(
        tint: lavender,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.sticky_note_2_rounded,
                  color: blue,
                ),
                SizedBox(width: 8),
                Text(
                  'MY NOTES',
                  style: TextStyle(
                    color: blue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            Text(
              item?['judul']?.toString() ??
                  'Belum ada catatan',
              style: const TextStyle(
                color: dark,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              item?['isi']?.toString().isNotEmpty == true
                  ? item!['isi'].toString()
                  : 'Simpan ide dan catatan skripsimu.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: muted,
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
  // BOTTOM NAVIGATION
  // =====================================================

  Widget bottomNav() {
    return NavigationBar(
      selectedIndex: 0,
      backgroundColor: Colors.white,
      indicatorColor: lime,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            muatDashboard();
            break;
          case 1:
            bukaJadwal();
            break;
          case 2:
            bukaNotifikasi();
            break;
          case 3:
            bukaChat();
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Jadwal',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_none_rounded),
          label: 'Notifikasi',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          label: 'Chat',
        ),
      ],
    );
  }

  // =====================================================
  // MAIN BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      bottomNavigationBar: bottomNav(),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFF),
              Color(0xFFEDF8F8),
              Color(0xFFF8F5FF),
            ],
          ),
        ),

        child: SafeArea(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: blue,
                  ),
                )
              : RefreshIndicator(
                  color: blue,
                  onRefresh: muatDashboard,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      35,
                    ),
                    children: [
                      // HEADER
                      header(),

                      const SizedBox(height: 25),

                      // HERO
                      hero(),

                      const SizedBox(height: 22),

                      // PROGRESS
                      kartuProgress(),

                      const SizedBox(height: 26),

                      // QUICK MENU
                      judulSection(
                        'Explore Your Space',
                        subtitle:
                            'Semua kebutuhan skripsimu di sini.',
                      ),

                      const SizedBox(height: 13),

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: kartuMenu(
                              judul: 'Jadwal',
                              keterangan: 'Booking bimbingan',
                              icon: Icons.calendar_month_rounded,
                              warna: lime,
                              onTap: bukaJadwal,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: kartuMenu(
                              judul: 'Revisi',
                              keterangan: 'Revisi & lampiran',
                              icon: Icons.edit_note_rounded,
                              warna: softBlue,
                              onTap: bukaRevisi,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: kartuMenu(
                              judul: 'Notes',
                              keterangan: 'Catatan & file',
                              icon: Icons.sticky_note_2_rounded,
                              warna: peach,
                              onTap: bukaNotes,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: kartuMenu(
                              judul: 'Dokumen',
                              keterangan: 'File skripsi',
                              icon: Icons.folder_copy_rounded,
                              warna: lavender,
                              onTap: bukaDokumen,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 27),

                      // UPCOMING SESSION
                      judulSection('Upcoming Session'),

                      const SizedBox(height: 12),

                      kartuBimbingan(),

                      const SizedBox(height: 26),

                      // REVISION
                      judulSection('Latest Revision'),

                      const SizedBox(height: 12),

                      kartuRevisi(),

                      const SizedBox(height: 26),

                      // NOTES
                      judulSection('Personal Notes'),

                      const SizedBox(height: 12),

                      kartuNotes(),

                      const SizedBox(height: 22),

                      // VIDEO CALL
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: bukaVideoCall,
                          icon: const Icon(
                            Icons.videocam_rounded,
                          ),
                          label: const Text('Video Call'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: blue,
                            padding: const EdgeInsets.all(15),
                            side: const BorderSide(
                              color: blue,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
