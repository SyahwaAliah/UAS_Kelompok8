
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/database/jadwal_bimbingan_service.dart';
import 'package:test/database/revisi_bimbingan_service.dart';
import 'package:test/widgets/skriva_dashboard_ui.dart';

import 'package:test/pages/login_page.dart';
import 'package:test/pages/profil_dosen_page.dart';
import 'package:test/pages/jadwal_bimbingan_baru_page.dart';
import 'package:test/pages/revisi_database_page.dart';
import 'package:test/pages/chat_detail_page.dart';
import 'package:test/pages/notification_page.dart';

class DashboardDosenPage extends StatefulWidget {
  const DashboardDosenPage({super.key});

  @override
  State<DashboardDosenPage> createState() =>
      _DashboardDosenPageState();
}

class _DashboardDosenPageState
    extends State<DashboardDosenPage> {
  static const blue = SkrivaDashColors.blue;
  static const dark = SkrivaDashColors.dark;
  static const lime = SkrivaDashColors.lime;

  Map<String, Object?>? akun;

  List<Map<String, Object?>> mahasiswa = [];
  List<Map<String, Object?>> jadwal = [];
  List<Map<String, Object?>> revisi = [];

  int avatarIndex = 3;
  String? fotoCustom;

  bool loading = true;

  int get totalMahasiswa => mahasiswa.length;

  int get menungguBooking => jadwal
      .where((item) => item['status'] == 'Menunggu')
      .length;

  int get menungguReview => revisi
      .where((item) => item['status'] == 'Menunggu Review')
      .length;

  int get revisiSelesai => revisi
      .where((item) => item['status'] == 'Selesai')
      .length;

  int get persenRevisi => revisi.isEmpty
      ? 0
      : ((revisiSelesai / revisi.length) * 100).round();

  @override
  void initState() {
    super.initState();
    muatData();
  }

  // =====================================================
  // LOAD DATA DOSEN
  // =====================================================

  Future<void> muatData() async {
    try {
      final user = await AuthDatabase.instance.sesiAktif();

      if (user == null || user['role'] != 'dosen') {
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

      final db = await DatabaseHelper.instance.database;

      await db.execute('''
        CREATE TABLE IF NOT EXISTS skriva_profil_dosen (
          akun_id INTEGER PRIMARY KEY,
          fakultas TEXT NOT NULL DEFAULT '',
          prodi TEXT NOT NULL DEFAULT '',
          telepon TEXT NOT NULL DEFAULT '',
          ruangan TEXT NOT NULL DEFAULT '',
          keahlian TEXT NOT NULL DEFAULT '',
          avatar_index INTEGER NOT NULL DEFAULT 3,
          foto_custom TEXT
        )
      ''');

      final profil = await db.query(
        'skriva_profil_dosen',
        where: 'akun_id = ?',
        whereArgs: [user['id']],
        limit: 1,
      );

      final daftarMahasiswa =
          await AuthDatabase.instance.mahasiswaBimbingan(
        user['id'] as int,
      );

      final daftarJadwal =
          await JadwalBimbinganService.instance.slotDosen();

      final daftarRevisi =
          await RevisiBimbinganService.instance.semua();

      if (!mounted) return;

      setState(() {
        akun = user;
        mahasiswa = daftarMahasiswa;
        jadwal = daftarJadwal;
        revisi = daftarRevisi;

        avatarIndex = profil.isEmpty
            ? 3
            : profil.first['avatar_index'] as int? ?? 3;

        fotoCustom = profil.isEmpty
            ? null
            : profil.first['foto_custom']?.toString();

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat Dashboard Dosen: $e')),
      );
    }
  }

  // =====================================================
  // AVATAR DOSEN
  // =====================================================

  Widget avatarDosen() {
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
      );
    }

    if (avatarIndex >= 0 && avatarIndex < 3) {
      return Image.asset(
        gambar[avatarIndex],
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.school_rounded, color: blue),
      );
    }

    const icons = [
      Icons.person_rounded,
      Icons.face_rounded,
      Icons.school_rounded,
    ];

    final index = avatarIndex - 3;

    return Icon(
      index >= 0 && index < 3
          ? icons[index]
          : Icons.school_rounded,
      color: blue,
      size: 25,
    );
  }

  // =====================================================
  // NAVIGATION
  // =====================================================

  Future<void> bukaHalaman(Widget halaman) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => halaman),
    );

    if (mounted) {
      await muatData();
    }
  }

  Future<void> bukaProfilDosen() async {
    await bukaHalaman(const ProfilDosenSayaPage());
  }

  void bukaJadwal() {
    bukaHalaman(const JadwalBimbinganBaruPage());
  }

  void bukaRevisi() {
    bukaHalaman(const RevisiDatabasePage());
  }

  void bukaNotifikasi() {
    bukaHalaman(const NotificationPage());
  }

  void bukaChatMahasiswa(
    Map<String, Object?> item,
  ) {
    bukaHalaman(
      ChatDetailPage(
        mahasiswaId: item['id'] as int,
        namaDosen: akun?['nama']?.toString() ?? '',
      ),
    );
  }

  void bukaDaftarChat() {
    if (mahasiswa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada mahasiswa bimbingan.'),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SkrivaDashColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Mahasiswa',
                style: TextStyle(
                  color: dark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 15),
              ...mahasiswa.map((item) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: lime,
                    child: Icon(
                      Icons.person_rounded,
                      color: dark,
                    ),
                  ),
                  title: Text(
                    item['nama']?.toString() ?? '-',
                  ),
                  subtitle: Text(
                    'NIM: ${item['nomor_induk']}',
                  ),
                  trailing: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: blue,
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    bukaChatMahasiswa(item);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void pilihBottomNav(int index) {
    switch (index) {
      case 0:
        muatData();
        break;
      case 1:
        bukaJadwal();
        break;
      case 2:
        bukaRevisi();
        break;
      case 3:
        bukaNotifikasi();
        break;
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> logout() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Yakin ingin keluar dari akun dosen?',
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
      ),
    );

    if (yes != true || !mounted) return;

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
  // HEADER + PROFILE BUTTON
  // =====================================================

  Widget header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SKRIVA / LECTURER SPACE',
                style: TextStyle(
                  color: blue,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Hello, ${akun?['nama'] ?? 'Dosen'}!',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: dark,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Guide every student forward.',
                style: TextStyle(
                  color: SkrivaDashColors.muted,
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

        const SizedBox(width: 4),

        // INI SEKARANG BENAR-BENAR BISA DIKLIK.
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: bukaProfilDosen,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: SkrivaDashColors.softBlue,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: avatarDosen(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // OVERVIEW
  // =====================================================

  Widget kartuOverview() {
    return SkrivaGlassCard(
      tint: SkrivaDashColors.softBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUPERVISION OVERVIEW',
            style: TextStyle(
              color: blue,
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalMahasiswa',
                      style: const TextStyle(
                        color: blue,
                        fontSize: 43,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Mahasiswa\nBimbingan',
                      style: TextStyle(
                        color: dark,
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${jadwal.length} slot jadwal tercatat',
                      style: const TextStyle(
                        color: SkrivaDashColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              SkrivaProgressDiagram(
                percent: persenRevisi,
                completed: revisiSelesai,
                total: revisi.length,
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            'Diagram menunjukkan revisi selesai.',
            style: TextStyle(
              color: SkrivaDashColors.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget kartuAngka({
    required String judul,
    required int angka,
    required Color warna,
    required IconData icon,
  }) {
    return SkrivaGlassCard(
      tint: warna,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: blue),
          const SizedBox(height: 10),
          Text(
            '$angka',
            style: const TextStyle(
              color: dark,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            judul,
            style: const TextStyle(
              color: SkrivaDashColors.muted,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // REVISION SUMMARY
  // =====================================================

  Widget kartuRevisi() {
    final item = revisi.isEmpty ? null : revisi.first;

    return InkWell(
      onTap: bukaRevisi,
      borderRadius: BorderRadius.circular(24),
      child: SkrivaGlassCard(
        tint: SkrivaDashColors.peach,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.rate_review_rounded, color: blue),
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
                Icon(Icons.arrow_outward_rounded, color: blue),
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
              item == null
                  ? 'Belum ada revisi mahasiswa bimbingan.'
                  : item['nama_mahasiswa']?.toString() ?? '-',
              style: const TextStyle(
                color: SkrivaDashColors.muted,
                fontSize: 12,
              ),
            ),
            if (item != null) ...[
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              const Text(
                'Ketuk untuk melihat revisi & dokumen.',
                style: TextStyle(
                  color: blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =====================================================
  // STUDENT CARD
  // =====================================================

  Widget kartuMahasiswa(Map<String, Object?> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => bukaChatMahasiswa(item),
        borderRadius: BorderRadius.circular(24),
        child: SkrivaGlassCard(
          tint: SkrivaDashColors.white,
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: lime,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.person_rounded,
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
                      item['nama']?.toString() ?? '-',
                      style: const TextStyle(
                        color: dark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'NIM: ${item['nomor_induk']}',
                      style: const TextStyle(
                        color: SkrivaDashColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pembimbing ${item['urutan']}',
                      style: const TextStyle(
                        color: blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chat_bubble_outline_rounded,
                color: blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // MAIN DASHBOARD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return SkrivaDashboardShell(
      bottomNavigationBar: SkrivaDashboardNav(
        onSelected: pilihBottomNav,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Jadwal',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            label: 'Revisi',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            label: 'Notifikasi',
          ),
        ],
      ),

      child: loading
          ? const Center(
              child: CircularProgressIndicator(color: blue),
            )
          : RefreshIndicator(
              color: blue,
              onRefresh: muatData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  35,
                ),
                children: [
                  header(),

                  const SizedBox(height: 24),

                  const SkrivaDashboardHero(
                    eyebrow: 'LECTURER / OVERVIEW',
                    title: 'Guide.\nReview. Inspire.',
                    subtitle:
                        'Help your students reach their next milestone.',
                    icon: Icons.auto_awesome_rounded,
                  ),

                  const SizedBox(height: 21),

                  kartuOverview(),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: kartuAngka(
                          judul: 'Booking menunggu persetujuan',
                          angka: menungguBooking,
                          warna: lime,
                          icon: Icons.pending_actions_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: kartuAngka(
                          judul: 'Revisi menunggu review',
                          angka: menungguReview,
                          warna: SkrivaDashColors.softBlue,
                          icon: Icons.rate_review_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  const SkrivaSectionTitle(
                    title: 'Manage Your Space',
                    subtitle:
                        'Kelola seluruh aktivitas bimbingan.',
                  ),

                  const SizedBox(height: 13),

                  Row(
                    children: [
                      Expanded(
                        child: SkrivaActionCard(
                          title: 'Jadwal',
                          subtitle: 'Atur jadwal',
                          icon: Icons.calendar_month_rounded,
                          color: lime,
                          onTap: bukaJadwal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SkrivaActionCard(
                          title: 'Revisi',
                          subtitle: 'Review dokumen',
                          icon: Icons.edit_note_rounded,
                          color: SkrivaDashColors.softBlue,
                          onTap: bukaRevisi,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: SkrivaActionCard(
                          title: 'Chat',
                          subtitle: 'Konsultasi',
                          icon: Icons.chat_bubble_rounded,
                          color: SkrivaDashColors.peach,
                          onTap: bukaDaftarChat,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SkrivaActionCard(
                          title: 'Profil',
                          subtitle: 'Edit profil dosen',
                          icon: Icons.account_circle_rounded,
                          color: SkrivaDashColors.lavender,
                          onTap: bukaProfilDosen,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  const SkrivaSectionTitle(
                    title: 'Latest Revision',
                  ),
                  const SizedBox(height: 12),
                  kartuRevisi(),

                  const SizedBox(height: 26),

                  const SkrivaSectionTitle(
                    title: 'Your Students',
                    subtitle:
                        'Pilih mahasiswa untuk membuka chat.',
                  ),
                  const SizedBox(height: 13),

                  if (mahasiswa.isEmpty)
                    const SkrivaGlassCard(
                      child: Text(
                        'Belum ada mahasiswa bimbingan.',
                      ),
                    )
                  else
                    ...mahasiswa.map(kartuMahasiswa),
                ],
              ),
            ),
    );
  }
}
