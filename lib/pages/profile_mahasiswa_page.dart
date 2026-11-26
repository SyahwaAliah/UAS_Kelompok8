
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/models/mahasiswa_model.dart';
import 'package:test/repositories/mahasiswa_repository.dart';
import 'package:test/widgets/skriva_dashboard_ui.dart';

import 'package:test/pages/checklist_page.dart';
import 'package:test/pages/dokumen_page.dart';
import 'package:test/pages/chat_detail_page.dart';

class ProfileMahasiswaPage extends StatefulWidget {
  const ProfileMahasiswaPage({super.key});

  @override
  State<ProfileMahasiswaPage> createState() =>
      _ProfileMahasiswaPageState();
}

class _ProfileMahasiswaPageState
    extends State<ProfileMahasiswaPage> {
  static const blue = SkrivaDashColors.blue;
  static const dark = SkrivaDashColors.dark;
  static const lime = SkrivaDashColors.lime;
  static const softBlue = SkrivaDashColors.softBlue;

  static const avatarAssets = [
    'assets/icon/icon_albert.jpeg',
    'assets/icon/icon_tracy.jpeg',
    'assets/icon/icon_syahwa.jpeg',
  ];

  static const avatarIcons = [
    Icons.person_rounded,
    Icons.face_rounded,
    Icons.school_rounded,
  ];

  final repo = MahasiswaRepository();

  Map<String, Object?>? akun;
  MahasiswaModel? profile;
  List<Map<String, Object?>> pembimbing = [];

  int avatarIndex = 3;
  String? fotoCustom;

  bool loading = true;
  bool menyimpan = false;

  @override
  void initState() {
    super.initState();
    muatProfile();
  }

  Future<Database> get database async {
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS skriva_profile_visual (
        akun_id INTEGER PRIMARY KEY,
        avatar_index INTEGER NOT NULL DEFAULT 0,
        foto_custom TEXT
      )
    ''');

    return db;
  }

  String get namaMahasiswa {
    final nama = profile?.nama.trim() ?? '';
    return nama.isNotEmpty
        ? nama
        : akun?['nama']?.toString() ?? 'Mahasiswa';
  }

  String get nimMahasiswa =>
      akun?['nomor_induk']?.toString() ?? '-';

  String get emailMahasiswa =>
      akun?['email']?.toString() ?? '-';

  String get prodiMahasiswa {
    final prodi = profile?.prodi.trim() ?? '';
    return prodi.isEmpty ? '-' : prodi;
  }

  String get judulSkripsi {
    final judul = profile?.judulSkripsi.trim() ?? '';
    return judul.isEmpty ? '-' : judul;
  }

  void pesan(String isi) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isi),
        behavior: SnackBarBehavior.floating,
        backgroundColor: blue,
      ),
    );
  }

  // =====================================================
  // LOAD PROFIL BERDASARKAN AKUN LOGIN
  // =====================================================

  Future<void> muatProfile() async {
    try {
      final user = await AuthDatabase.instance.sesiAktif();

      if (user == null || user['role'] != 'mahasiswa') {
        throw StateError('Silakan login sebagai mahasiswa.');
      }

      final id = user['id'] as int;
      final nim = user['nomor_induk']?.toString() ?? '';

      final db = await database;
      final semuaMahasiswa = await repo.semua();

      MahasiswaModel? dataMahasiswa;

      for (final item in semuaMahasiswa) {
        if (item.nim == nim) {
          dataMahasiswa = item;
          break;
        }
      }

      final daftarPembimbing =
          await AuthDatabase.instance.pembimbing(id);

      final visual = await db.query(
        'skriva_profile_visual',
        where: 'akun_id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (!mounted) return;

      setState(() {
        akun = user;
        profile = dataMahasiswa;
        pembimbing = daftarPembimbing;

        avatarIndex = visual.isEmpty
            ? 3
            : visual.first['avatar_index'] as int? ?? 3;

        fotoCustom = visual.isEmpty
            ? null
            : visual.first['foto_custom']?.toString();

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      pesan('Gagal memuat profil: $e');
    }
  }

  // =====================================================
  // AVATAR
  // =====================================================

  Widget tampilAvatar({double ukuran = 110}) {
    if (avatarIndex == 6 &&
        fotoCustom != null &&
        File(fotoCustom!).existsSync()) {
      return Image.file(
        File(fotoCustom!),
        width: ukuran,
        height: ukuran,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.person_rounded,
          color: blue,
          size: ukuran * 0.5,
        ),
      );
    }

    if (avatarIndex >= 0 &&
        avatarIndex < avatarAssets.length) {
      return Image.asset(
        avatarAssets[avatarIndex],
        width: ukuran,
        height: ukuran,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.person_rounded,
          color: blue,
          size: ukuran * 0.5,
        ),
      );
    }

    final index = avatarIndex - 3;

    return Icon(
      index >= 0 && index < avatarIcons.length
          ? avatarIcons[index]
          : Icons.person_rounded,
      color: blue,
      size: ukuran * 0.5,
    );
  }

  Future<void> simpanAvatar(
    int index, {
    String? path,
  }) async {
    if (akun == null || menyimpan) return;

    setState(() => menyimpan = true);

    try {
      final db = await database;

      await db.insert(
        'skriva_profile_visual',
        {
          'akun_id': akun!['id'],
          'avatar_index': index,
          'foto_custom': path ?? fotoCustom,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await muatProfile();
      pesan('Avatar berhasil diperbarui!');
    } catch (e) {
      pesan('Gagal menyimpan avatar: $e');
    } finally {
      if (mounted) {
        setState(() => menyimpan = false);
      }
    }
  }

  Future<void> pilihFotoGaleri() async {
    if (akun == null || menyimpan) return;

    try {
      final hasil = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (hasil == null) return;

      final sourcePath = hasil.files.single.path;

      if (sourcePath == null) {
        throw StateError('Foto tidak ditemukan.');
      }

      final sumber = File(sourcePath);

      if (!await sumber.exists()) {
        throw StateError('Foto tidak dapat dibaca.');
      }

      final root = await getApplicationDocumentsDirectory();

      final folder = Directory(
        p.join(
          root.path,
          'skriva_avatar_mahasiswa',
          '${akun!['id']}',
        ),
      );

      await folder.create(recursive: true);

      final extension =
          hasil.files.single.extension?.toLowerCase() ?? 'jpg';

      final tujuan = File(
        p.join(
          folder.path,
          '${DateTime.now().microsecondsSinceEpoch}.$extension',
        ),
      );

      await sumber.copy(tujuan.path);

      await simpanAvatar(6, path: tujuan.path);
    } catch (e) {
      pesan('Gagal memilih foto: $e');
    }
  }

  Future<void> gantiAvatar() async {
    if (menyimpan) return;

    final pilihan = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: SkrivaDashColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Your Avatar',
                  style: TextStyle(
                    color: dark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(6, (index) {
                    return InkWell(
                      onTap: () =>
                          Navigator.pop(sheetContext, index),
                      child: Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          color: softBlue,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: avatarIndex == index
                                ? blue
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: index < 3
                            ? Image.asset(
                                avatarAssets[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.person),
                              )
                            : Icon(
                                avatarIcons[index - 3],
                                color: blue,
                                size: 30,
                              ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        Navigator.pop(sheetContext, 6),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Pilih Foto dari Galeri'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || pilihan == null) return;

    if (pilihan == 6) {
      await pilihFotoGaleri();
    } else {
      await simpanAvatar(pilihan);
    }
  }

  // =====================================================
  // EDIT PROFIL — TANPA CONTROLLER MANUAL DI DIALOG
  // =====================================================

  Future<void> editProfile() async {
    if (akun == null || menyimpan) return;

    String namaBaru = namaMahasiswa;
    String prodiBaru = profile?.prodi ?? '';
    String judulBaru = profile?.judulSkripsi ?? '';

    final hasil = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: SkrivaDashColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        title: const Text(
          'Edit Profil Mahasiswa',
          style: TextStyle(
            color: dark,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: namaBaru,
                textCapitalization: TextCapitalization.words,
                onChanged: (v) => namaBaru = v,
                decoration: const InputDecoration(
                  labelText: 'Nama Mahasiswa',
                ),
              ),
              const SizedBox(height: 13),
              TextFormField(
                initialValue: prodiBaru,
                onChanged: (v) => prodiBaru = v,
                decoration: const InputDecoration(
                  labelText: 'Program Studi',
                ),
              ),
              const SizedBox(height: 13),
              TextFormField(
                initialValue: judulBaru,
                maxLines: 3,
                onChanged: (v) => judulBaru = v,
                decoration: const InputDecoration(
                  labelText: 'Judul Skripsi',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'NIM dan email login tidak dapat diubah.',
                style: TextStyle(
                  color: SkrivaDashColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (namaBaru.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Nama wajib diisi.'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext, {
                'nama': namaBaru.trim(),
                'prodi': prodiBaru.trim(),
                'judul': judulBaru.trim(),
              });
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (!mounted || hasil == null) return;

    setState(() => menyimpan = true);

    try {
      final db = await database;

      final data = MahasiswaModel(
        id: profile?.id,
        nama: hasil['nama']!,
        nim: nimMahasiswa,
        email: emailMahasiswa,
        prodi: hasil['prodi']!,
        semester: profile?.semester ?? 1,
        judulSkripsi: hasil['judul']!,
      );

      await db.transaction((txn) async {
        if (profile == null) {
          await txn.insert(
            'mahasiswa',
            data.toMap(),
          );
        } else {
          final count = await txn.update(
            'mahasiswa',
            data.toMap(),
            where: 'id = ? AND nim = ?',
            whereArgs: [
              profile!.id,
              nimMahasiswa,
            ],
          );

          if (count != 1) {
            throw StateError(
              'Data mahasiswa tidak ditemukan.',
            );
          }
        }

        final updated = await txn.update(
          'skriva_akun',
          {'nama': hasil['nama']!},
          where: 'id = ? AND role = ?',
          whereArgs: [akun!['id'], 'mahasiswa'],
        );

        if (updated != 1) {
          throw StateError('Akun mahasiswa tidak ditemukan.');
        }
      });

      await muatProfile();
      if (!mounted) return;

      pesan('Profil mahasiswa berhasil disimpan!');
    } catch (e) {
      pesan('Gagal menyimpan profil: $e');
    } finally {
      if (mounted) {
        setState(() => menyimpan = false);
      }
    }
  }

  // =====================================================
  // WIDGET INFORMASI
  // =====================================================

  Widget informasi(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: blue, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: SkrivaDashColors.muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: dark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget kartuPembimbing(Map<String, Object?> item) {
    final dosenId = item['id'] as int;
    final nama = item['nama']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: softBlue.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: lime,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.school_rounded, color: dark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembimbing ${item['urutan']}',
                  style: const TextStyle(
                    color: blue,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nama,
                  style: const TextStyle(
                    color: dark,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Chat Dosen',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailPage(
                  dosenId: dosenId,
                  namaDosen: nama,
                ),
              ),
            ),
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget kartuProfil() {
    return SkrivaGlassCard(
      tint: lime,
      child: Column(
        children: [
          InkWell(
            onTap: gantiAvatar,
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: softBlue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(child: tampilAvatar()),
                ),
                Positioned(
                  right: -5,
                  bottom: -5,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: blue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          Text(
            namaMahasiswa,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: dark,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prodiMahasiswa == '-'
                ? 'Mahasiswa Skriva'
                : prodiMahasiswa,
            style: const TextStyle(
              color: SkrivaDashColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: menyimpan ? null : gantiAvatar,
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Ganti Avatar'),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // MAIN PAGE
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkrivaDashColors.background,
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: muatProfile,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: blue),
            )
          : RefreshIndicator(
              color: blue,
              onRefresh: muatProfile,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20, 18, 20, 35,
                ),
                children: [
                  const SkrivaDashboardHero(
                    eyebrow: 'SKRIVA / STUDENT PROFILE',
                    title: 'This Is\nYour Space.',
                    subtitle:
                        'Your academic journey, your identity.',
                    icon: Icons.auto_awesome_rounded,
                  ),
                  const SizedBox(height: 20),
                  kartuProfil(),
                  const SizedBox(height: 24),
                  const SkrivaSectionTitle(
                    title: 'Academic Information',
                    subtitle:
                        'Identitas dan informasi skripsimu.',
                  ),
                  const SizedBox(height: 13),
                  SkrivaGlassCard(
                    child: Column(
                      children: [
                        informasi(
                          Icons.badge_outlined,
                          'NIM',
                          nimMahasiswa,
                        ),
                        informasi(
                          Icons.email_outlined,
                          'Email',
                          emailMahasiswa,
                        ),
                        informasi(
                          Icons.school_outlined,
                          'Program Studi',
                          prodiMahasiswa,
                        ),
                        informasi(
                          Icons.calendar_month_outlined,
                          'Semester',
                          profile?.semester.toString() ?? '-',
                        ),
                        informasi(
                          Icons.menu_book_rounded,
                          'Judul Skripsi',
                          judulSkripsi,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SkrivaSectionTitle(
                    title: 'Your Supervisors',
                    subtitle: 'Dosen pembimbing yang ditetapkan.',
                  ),
                  const SizedBox(height: 13),
                  SkrivaGlassCard(
                    tint: softBlue,
                    child: Column(
                      children: [
                        if (pembimbing.isEmpty)
                          const Text(
                            'Belum ada dosen pembimbing.',
                          ),
                        ...pembimbing.map(kartuPembimbing),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SkrivaSectionTitle(
                    title: 'Quick Access',
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      Expanded(
                        child: SkrivaActionCard(
                          title: 'Checklist',
                          subtitle: 'Progress skripsi',
                          icon: Icons.checklist_rounded,
                          color: lime,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChecklistPage(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SkrivaActionCard(
                          title: 'Dokumen',
                          subtitle: 'File skripsi',
                          icon: Icons.folder_copy_rounded,
                          color: softBlue,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DokumenPage(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: menyimpan ? null : editProfile,
                    style: FilledButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit Profil'),
                  ),
                ],
              ),
            ),
    );
  }
}
