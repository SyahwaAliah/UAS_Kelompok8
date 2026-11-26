import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test/theme/jadwal_theme.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/checklist_model.dart';
import 'package:test/repositories/checklist_repository.dart';
import 'package:test/repositories/mahasiswa_repository.dart';
import 'package:test/database/auth_database.dart';
import 'package:test/pages/login_page.dart';
import 'package:test/pages/jadwal_bimbingan_baru_page.dart';
import 'package:test/pages/revisi_database_page.dart';
import 'package:test/database/revisi_bimbingan_service.dart';
import 'package:test/database/progress_akun_service.dart';

import 'profile_mahasiswa_page.dart';
import 'progress_skripsi_page.dart';
import 'chat_page.dart';
import 'notification_page.dart';
import 'video_call_page.dart';
import 'jadwal_page.dart';
import 'detailbimbingan_page.dart';
import 'detailrevisi_page.dart';
import 'notes_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  final _mahasiswaRepo = MahasiswaRepository();
  final _checklistRepo = ChecklistRepository();

  String _namaMahasiswa = '';
  int _avatarMahasiswa = 0;
  String? _fotoCustom;

  List<ChecklistModel> _tahapan = [];
  Map<String, Object?>? _jadwalTerdekat;
  Map<String, Object?>? _catatanTerakhir;
  Map<String, Object?>? _revisiTerakhir;

  static const Color olive = Color(0xFF694A47);
  static const Color darkOlive = Color(0xFF523B39);
  static const Color maroon = Color(0xFF694A47);
  static const Color orange = Color(0xFF96C1C5);
  static const Color cream = Color(0xFFFFF0DE);
  static const Color peach = Color(0xFFE5F0EF);
  static const Color lightPeach = Color(0xFFFFF7EC);
  static const Color lightBlue = Color(0xFFD9ECEC);
  static const Color lightPink = Color(0xFFF4E6E3);
  static const Color softYellow = Color(0xFFFFF5E5);

  int get jumlahSelesai => _tahapan.where((item) => item.selesai).length;

  int get persentaseProgress =>
      _tahapan.isEmpty ? 0 : ((jumlahSelesai / _tahapan.length) * 100).round();

  @override
  void initState() {
    super.initState();
    _muatDashboard();
  }

  Future<void> _muatDashboard() async {
    try {
      final akunAktif = await AuthDatabase.instance.sesiAktif();

      if (akunAktif == null || akunAktif['role'] != 'mahasiswa') {
        return;
      }

      final akunId = akunAktif['id'] as int;
      final namaAkun = akunAktif['nama']?.toString().trim() ?? '';

      // Data tampilan profil
      final avatar = await _mahasiswaRepo.ambilAvatar();
      final fotoCustom = await _mahasiswaRepo.ambilFotoCustom();

      final tahapan = await ProgressAkunService.instance.semua();

      final db = await DatabaseHelper.instance.database;

      // Jadwal hanya untuk mahasiswa yang login.
      final jadwal = await db.rawQuery(
        '''
      SELECT
        j.id,
        j.tanggal,
        j.jam,
        j.mode,
        j.status,
        j.dosen_id,
        d.nama AS dosen
      FROM skriva_slot_jadwal j
      JOIN skriva_akun d ON d.id = j.dosen_id
      WHERE j.mahasiswa_id = ?
        AND j.status != 'Selesai'
      ORDER BY j.tanggal ASC, j.jam ASC
    ''',
        [akunId],
      );

      // Revisi mahasiswa yang sedang login.
      final daftarRevisi = await RevisiBimbinganService.instance.semua();

      // Pastikan tabel Notes tersedia.
      await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        akun_id INTEGER NOT NULL,
        judul TEXT NOT NULL,
        isi TEXT NOT NULL,
        diperbarui TEXT NOT NULL
      )
    ''');

      // Catatan hanya milik mahasiswa yang login.
      final catatan = await db.query(
        'skriva_notes',
        where: 'akun_id = ?',
        whereArgs: [akunId],
        orderBy: 'diperbarui DESC, id DESC',
        limit: 1,
      );

      final sekarang = DateTime.now();
      final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);

      Map<String, Object?>? jadwalTerdekat;

      for (final item in jadwal) {
        final tanggal = DateTime.tryParse(item['tanggal']?.toString() ?? '');

        if (tanggal != null && !tanggal.isBefore(hariIni)) {
          jadwalTerdekat = item;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        _namaMahasiswa = namaAkun;
        _avatarMahasiswa = avatar;
        _fotoCustom = fotoCustom;

        _tahapan = tahapan;
        _jadwalTerdekat = jadwalTerdekat;

        _revisiTerakhir = daftarRevisi.isEmpty ? null : daftarRevisi.first;

        _catatanTerakhir = catatan.isEmpty ? null : catatan.first;
      });
    } catch (e, stackTrace) {
      debugPrint('Gagal memuat Dashboard: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Widget _fotoProfilDashboard() {
    if (_avatarMahasiswa == 6 &&
        _fotoCustom != null &&
        File(_fotoCustom!).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(_fotoCustom!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    }

    const images = [
      'assets/icon/icon_albert.jpeg',
      'assets/icon/icon_tracy.jpeg',
      'assets/icon/icon_syahwa.jpeg',
    ];

    const icons = [Icons.person, Icons.face, Icons.school];

    if (_avatarMahasiswa >= 0 && _avatarMahasiswa < images.length) {
      return ClipOval(
        child: Image.asset(
          images[_avatarMahasiswa],
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, color: Colors.white, size: 27);
          },
        ),
      );
    }

    final iconIndex = _avatarMahasiswa - images.length;

    return Icon(
      iconIndex >= 0 && iconIndex < icons.length
          ? icons[iconIndex]
          : Icons.person,
      color: Colors.white,
      size: 27,
    );
  }

  Future<void> bukaProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileMahasiswaPage()),
    );

    if (mounted) await _muatDashboard();
  }

  Future<void> bukaProgressSkripsi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProgressSkripsiPage()),
    );

    if (mounted) await _muatDashboard();
  }

  void bukaDetailBimbingan() {
    DetailBimbinganPage.open(context);
  }

  Future<void> bukaDetailRevisi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RevisiDatabasePage()),
    );

    if (mounted) {
      await _muatDashboard();
    }
  }

  Future<void> bukaNotes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotesPage()),
    );

    if (mounted) await _muatDashboard();
  }

  void bukaChat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          decoration: const BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Konsultasi',
                  style: TextStyle(
                    color: darkOlive,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatPage()),
                  );
                },
                child: _menuKonsultasi(
                  icon: Icons.chat_rounded,
                  judul: 'Chat',
                  deskripsi: 'Konsultasi melalui pesan',
                  warna: peach,
                  warnaIkon: olive,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VideoCallPage()),
                  );
                },
                child: _menuKonsultasi(
                  icon: Icons.videocam_rounded,
                  judul: 'Video Call',
                  deskripsi: 'Konsultasi secara langsung',
                  warna: lightPeach,
                  warnaIkon: orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _menuKonsultasi({
    required IconData icon,
    required String judul,
    required String deskripsi,
    required Color warna,
    required Color warnaIkon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: warna,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: warnaIkon, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    color: darkOlive,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  deskripsi,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: warnaIkon),
        ],
      ),
    );
  }

  void pilihBottomNav(int index) {
    if (index == 0) {
      setState(() {
        selectedIndex = 0;
      });
      return;
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const JadwalBimbinganBaruPage()),
      ).then((_) => _muatDashboard());
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationPage()),
      );
      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatPage()),
      );
      return;
    }
  }

  Widget _judulBagian(String judul) {
    return Text(
      judul,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkOlive,
      ),
    );
  }

  Widget _kartuProgress() {
    return GestureDetector(
      onTap: bukaProgressSkripsi,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: olive,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Skripsi',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              '$persentaseProgress%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: persentaseProgress / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$jumlahSelesai dari '
              '${_tahapan.length} tahapan selesai',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartuBimbingan() {
    final jadwal = _jadwalTerdekat;

    return GestureDetector(
      onTap: bukaDetailBimbingan,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: jadwal == null
            ? const Row(
                children: [
                  Icon(Icons.event_busy, color: orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Belum ada bimbingan mendatang.',
                      style: TextStyle(color: darkOlive),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          jadwal['status']?.toString().toUpperCase() ??
                              'MENUNGGU',
                          style: const TextStyle(
                            color: olive,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${jadwal['jam']} WIB',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'Bimbingan Skripsi',
                    style: TextStyle(
                      color: darkOlive,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    jadwal['dosen']?.toString() ?? '-',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 17,
                        color: orange,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        jadwal['tanggal']?.toString() ?? '-',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  
Widget _kartuRevisi() {
  final revisi = _revisiTerakhir;

  final judul = revisi?['judul']?.toString() ??
      'Belum ada revisi';

  final instruksi = revisi?['catatan']?.toString() ??
      'Belum ada revisi dari dosen pembimbing.';

  final status = revisi?['status']?.toString() ?? '';

  final namaDosen =
      revisi?['nama_dosen']?.toString() ?? '';

  return GestureDetector(
    onTap: bukaDetailRevisi,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lightPink,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFF4E6E3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: maroon,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    color: darkOlive,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  instruksi,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (namaDosen.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Dosen: $namaDosen',
                    style: const TextStyle(
                      fontSize: 11,
                      color: olive,
                    ),
                  ),
                ],
                if (status.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Status: $status',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: olive,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: olive,
          ),
        ],
      ),
    ),
  );
}

  Widget _kartuCatatan() {
    final judul = _catatanTerakhir?['judul']?.toString() ?? '';

    final isi = _catatanTerakhir?['isi']?.toString() ?? '';

    return GestureDetector(
      onTap: bukaNotes,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: softYellow,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: orange),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.sticky_note_2_rounded, color: orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Catatan Pribadi',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: orange),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              judul.isEmpty ? 'Belum ada catatan' : judul,
              style: const TextStyle(
                color: darkOlive,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isi.isEmpty ? 'Ketuk untuk menulis catatan pribadi.' : isi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun Skriva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF694A47)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF694A47),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    try {
      await AuthDatabase.instance.logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedPage(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [cream, Color(0xFFEAF3F2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.055,
                    20,
                    screenWidth * 0.055,
                    100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _namaMahasiswa.isEmpty
                                      ? 'Halo! 👋'
                                      : 'Halo, $_namaMahasiswa 👋',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: darkOlive,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Yuk lanjutkan bimbinganmu hari ini.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tombol Logout
                              IconButton(
                                onPressed: logout,
                                tooltip: 'Logout',
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  color: olive,
                                  size: 25,
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Foto profil mahasiswa (tetap seperti sebelumnya)
                              GestureDetector(
                                onTap: bukaProfile,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: _fotoProfilDashboard(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      _kartuProgress(),
                      const SizedBox(height: 25),
                      _judulBagian('Bimbingan Terdekat'),
                      const SizedBox(height: 12),
                      _kartuBimbingan(),
                      const SizedBox(height: 28),
                      _judulBagian('Revisi Terakhir'),
                      const SizedBox(height: 12),
                      _kartuRevisi(),
                      const SizedBox(height: 28),
                      _judulBagian('Catatan Pribadi'),
                      const SizedBox(height: 12),
                      _kartuCatatan(),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 18,
                  child: GestureDetector(
                    onTap: bukaChat,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: pilihBottomNav,
          type: BottomNavigationBarType.fixed,
          backgroundColor: lightPeach,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedItemColor: olive,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_rounded),
              activeIcon: Icon(Icons.notifications_rounded),
              label: 'Notifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}
