
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/database/database_helper.dart';
import 'package:test/widgets/skriva_dashboard_ui.dart';

import 'package:test/pages/chat_detail_page.dart';
import 'package:test/pages/jadwal_bimbingan_baru_page.dart';

const _blue = SkrivaDashColors.blue;
const _dark = SkrivaDashColors.dark;
const _lime = SkrivaDashColors.lime;
const _softBlue = SkrivaDashColors.softBlue;

// =====================================================
// PROFIL DOSEN — DILIHAT MAHASISWA
// =====================================================

class ProfilDosenPage extends StatefulWidget {
  final int? dosenId;

  const ProfilDosenPage({
    super.key,
    this.dosenId,
  });

  @override
  State<ProfilDosenPage> createState() =>
      _ProfilDosenPageState();
}

class _ProfilDosenPageState extends State<ProfilDosenPage> {
  List<Map<String, Object?>> dosenList = [];
  Map<String, Object?>? dosen;
  int? idTerpilih;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    idTerpilih = widget.dosenId;
    muat();
  }

  Future<void> muat() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final akun = await AuthDatabase.instance.sesiAktif();

      if (akun == null) {
        throw StateError('Silakan login.');
      }

      List<Map<String, Object?>> daftar;

      if (akun['role'] == 'mahasiswa') {
        daftar = await AuthDatabase.instance.pembimbing(
          akun['id'] as int,
        );
      } else {
        daftar = await db.query(
          'skriva_akun',
          columns: ['id', 'nama', 'email', 'nomor_induk'],
          where: 'role = ?',
          whereArgs: ['dosen'],
          orderBy: 'nama ASC',
        );
      }

      final selected = idTerpilih != null &&
              daftar.any((item) => item['id'] == idTerpilih)
          ? idTerpilih
          : daftar.isNotEmpty
              ? daftar.first['id'] as int
              : null;

      Map<String, Object?>? detail;

      if (selected != null) {
        final akunRows = await db.query(
          'skriva_akun',
          where: 'id = ? AND role = ?',
          whereArgs: [selected, 'dosen'],
          limit: 1,
        );

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
          whereArgs: [selected],
          limit: 1,
        );

        if (akunRows.isNotEmpty) {
          detail = {
            ...akunRows.first,
            if (profil.isNotEmpty) ...profil.first,
          };
        }
      }

      if (!mounted) return;

      setState(() {
        dosenList = daftar;
        idTerpilih = selected;
        dosen = detail;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat dosen: $e')),
      );
    }
  }

  String nilai(String key) {
    final isi = dosen?[key]?.toString().trim() ?? '';
    return isi.isEmpty ? '-' : isi;
  }

  Future<void> bukaChat() async {
    final akun = await AuthDatabase.instance.sesiAktif();

    if (!mounted) return;

    if (akun == null || akun['role'] != 'mahasiswa') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat ini khusus mahasiswa.'),
        ),
      );
      return;
    }

    if (idTerpilih == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          dosenId: idTerpilih,
          namaDosen: nilai('nama'),
        ),
      ),
    );
  }

  Widget info(String judul, String isi, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: _blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    color: SkrivaDashColors.muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isi,
                  style: const TextStyle(
                    color: _dark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkrivaDashColors.background,
      appBar: AppBar(
        title: const Text('Profil Dosen'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: _blue),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                20, 18, 20, 35,
              ),
              children: [
                const SkrivaDashboardHero(
                  eyebrow: 'SKRIVA / SUPERVISORS',
                  title: 'Meet Your\nSupervisor.',
                  subtitle:
                      'Get to know your academic mentor.',
                  icon: Icons.school_rounded,
                ),
                const SizedBox(height: 20),
                SkrivaGlassCard(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: idTerpilih,
                      hint: const Text('Pilih Dosen'),
                      items: dosenList.map((item) {
                        return DropdownMenuItem(
                          value: item['id'] as int,
                          child: Text(
                            item['nama']?.toString() ?? '-',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value == null) return;
                        setState(() {
                          idTerpilih = value;
                          loading = true;
                        });
                        await muat();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SkrivaGlassCard(
                  tint: _lime,
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: _softBlue,
                          borderRadius: BorderRadius.circular(23),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: _blue,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        nilai('nama'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _dark,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Dosen Pembimbing Skripsi',
                        style: TextStyle(
                          color: SkrivaDashColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 17),
                SkrivaGlassCard(
                  child: Column(
                    children: [
                      info(
                        'NIDN / ID',
                        nilai('nomor_induk'),
                        Icons.badge_outlined,
                      ),
                      info(
                        'Email',
                        nilai('email'),
                        Icons.email_outlined,
                      ),
                      info(
                        'Fakultas',
                        nilai('fakultas'),
                        Icons.account_balance_outlined,
                      ),
                      info(
                        'Program Studi',
                        nilai('prodi'),
                        Icons.school_outlined,
                      ),
                      info(
                        'Telepon',
                        nilai('telepon'),
                        Icons.phone_outlined,
                      ),
                      info(
                        'Ruangan',
                        nilai('ruangan'),
                        Icons.room_outlined,
                      ),
                      info(
                        'Bidang Keahlian',
                        nilai('keahlian'),
                        Icons.auto_awesome_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                FilledButton.icon(
                  onPressed: idTerpilih == null ? null : bukaChat,
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text('Chat Dosen'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const JadwalBimbinganBaruPage(),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text('Jadwal Bimbingan'),
                ),
              ],
            ),
    );
  }
}

// =====================================================
// PROFIL SAYA — DOSEN YANG SEDANG LOGIN
// =====================================================

class ProfilDosenSayaPage extends StatefulWidget {
  const ProfilDosenSayaPage({super.key});

  @override
  State<ProfilDosenSayaPage> createState() =>
      _ProfilDosenSayaPageState();
}

class _ProfilDosenSayaPageState
    extends State<ProfilDosenSayaPage> {
  static const assets = [
    'assets/icon/icon_albert.jpeg',
    'assets/icon/icon_tracy.jpeg',
    'assets/icon/icon_syahwa.jpeg',
  ];

  static const avatarIcons = [
    Icons.person_rounded,
    Icons.face_rounded,
    Icons.school_rounded,
  ];

  Map<String, Object?>? akun;
  Map<String, Object?> profil = {};

  int avatarIndex = 3;
  String? fotoCustom;

  bool loading = true;
  bool menyimpan = false;

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<Database> get database async {
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

    return db;
  }

  void pesan(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _blue,
      ),
    );
  }

  String nilai(String key) {
    final isi = profil[key]?.toString().trim() ?? '';
    return isi.isEmpty ? '-' : isi;
  }

  Future<void> muat() async {
    try {
      final user = await AuthDatabase.instance.sesiAktif();

      if (user == null || user['role'] != 'dosen') {
        throw StateError('Silakan login sebagai dosen.');
      }

      final db = await database;

      final rows = await db.query(
        'skriva_profil_dosen',
        where: 'akun_id = ?',
        whereArgs: [user['id']],
        limit: 1,
      );

      if (!mounted) return;

      setState(() {
        akun = user;
        profil = rows.isEmpty ? {} : rows.first;

        avatarIndex = profil['avatar_index'] as int? ?? 3;
        fotoCustom = profil['foto_custom']?.toString();

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      pesan('Gagal memuat profil: $e');
    }
  }

  Widget avatar({double ukuran = 110}) {
    if (avatarIndex == 6 &&
        fotoCustom != null &&
        File(fotoCustom!).existsSync()) {
      return Image.file(
        File(fotoCustom!),
        width: ukuran,
        height: ukuran,
        fit: BoxFit.cover,
      );
    }

    if (avatarIndex >= 0 && avatarIndex < 3) {
      return Image.asset(
        assets[avatarIndex],
        width: ukuran,
        height: ukuran,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.school_rounded),
      );
    }

    final index = avatarIndex - 3;

    return Icon(
      index >= 0 && index < 3
          ? avatarIcons[index]
          : Icons.school_rounded,
      color: _blue,
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
        'skriva_profil_dosen',
        {
          'akun_id': akun!['id'],
          'fakultas': profil['fakultas'] ?? '',
          'prodi': profil['prodi'] ?? '',
          'telepon': profil['telepon'] ?? '',
          'ruangan': profil['ruangan'] ?? '',
          'keahlian': profil['keahlian'] ?? '',
          'avatar_index': index,
          'foto_custom': path ?? fotoCustom,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await muat();
      pesan('Avatar dosen berhasil diperbarui.');
    } catch (e) {
      pesan('Gagal menyimpan avatar: $e');
    } finally {
      if (mounted) {
        setState(() => menyimpan = false);
      }
    }
  }

  Future<void> pilihFoto() async {
    if (akun == null || menyimpan) return;

    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (picked == null) return;

      final sourcePath = picked.files.single.path;

      if (sourcePath == null) {
        throw StateError('Foto tidak ditemukan.');
      }

      final source = File(sourcePath);
      if (!await source.exists()) {
        throw StateError('Foto tidak dapat dibaca.');
      }

      final root = await getApplicationDocumentsDirectory();

      final dir = Directory(
        p.join(
          root.path,
          'skriva_avatar_dosen',
          '${akun!['id']}',
        ),
      );

      await dir.create(recursive: true);

      final ext =
          picked.files.single.extension?.toLowerCase() ?? 'jpg';

      final target = File(
        p.join(
          dir.path,
          '${DateTime.now().microsecondsSinceEpoch}.$ext',
        ),
      );

      await source.copy(target.path);
      await simpanAvatar(6, path: target.path);
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
          top: Radius.circular(27),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Your Avatar',
                style: TextStyle(
                  color: _dark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(6, (i) {
                  return InkWell(
                    onTap: () => Navigator.pop(ctx, i),
                    child: Container(
                      width: 73,
                      height: 73,
                      decoration: BoxDecoration(
                        color: _softBlue,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: avatarIndex == i
                              ? _blue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: i < 3
                          ? Image.asset(
                              assets[i],
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.person),
                            )
                          : Icon(
                              avatarIcons[i - 3],
                              color: _blue,
                              size: 29,
                            ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => Navigator.pop(ctx, 6),
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('Pilih Foto dari Galeri'),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || pilihan == null) return;

    if (pilihan == 6) {
      await pilihFoto();
    } else {
      await simpanAvatar(pilihan);
    }
  }

  // =====================================================
  // EDIT PROFIL — PERBAIKAN LIFECYCLE DIALOG
  // =====================================================

  Future<void> editProfile() async {
    if (akun == null || menyimpan) return;

    String namaBaru =
        akun!['nama']?.toString() ?? '';
    String fakultasBaru =
        profil['fakultas']?.toString() ?? '';
    String prodiBaru =
        profil['prodi']?.toString() ?? '';
    String teleponBaru =
        profil['telepon']?.toString() ?? '';
    String ruanganBaru =
        profil['ruangan']?.toString() ?? '';
    String keahlianBaru =
        profil['keahlian']?.toString() ?? '';

    final hasil = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        Widget field(
          String label,
          String initialValue,
          ValueChanged<String> onChanged, {
          int maxLines = 1,
        }) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              initialValue: initialValue,
              maxLines: maxLines,
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          );
        }

        return AlertDialog(
          backgroundColor: SkrivaDashColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Text(
            'Edit Profil Dosen',
            style: TextStyle(
              color: _dark,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                field(
                  'Nama Dosen',
                  namaBaru,
                  (v) => namaBaru = v,
                ),
                field(
                  'Fakultas',
                  fakultasBaru,
                  (v) => fakultasBaru = v,
                ),
                field(
                  'Program Studi',
                  prodiBaru,
                  (v) => prodiBaru = v,
                ),
                field(
                  'Telepon',
                  teleponBaru,
                  (v) => teleponBaru = v,
                ),
                field(
                  'Ruangan',
                  ruanganBaru,
                  (v) => ruanganBaru = v,
                ),
                field(
                  'Bidang Keahlian',
                  keahlianBaru,
                  (v) => keahlianBaru = v,
                  maxLines: 3,
                ),
                const Text(
                  'Email login dan ID dosen tidak dapat diubah.',
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (namaBaru.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Nama dosen wajib diisi.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx, {
                  'nama': namaBaru.trim(),
                  'fakultas': fakultasBaru.trim(),
                  'prodi': prodiBaru.trim(),
                  'telepon': teleponBaru.trim(),
                  'ruangan': ruanganBaru.trim(),
                  'keahlian': keahlianBaru.trim(),
                });
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (!mounted || hasil == null) return;

    setState(() => menyimpan = true);

    try {
      final db = await database;

      await db.transaction((txn) async {
        final updated = await txn.update(
          'skriva_akun',
          {'nama': hasil['nama']!},
          where: 'id = ? AND role = ?',
          whereArgs: [akun!['id'], 'dosen'],
        );

        if (updated != 1) {
          throw StateError('Akun dosen tidak ditemukan.');
        }

        await txn.insert(
          'skriva_profil_dosen',
          {
            'akun_id': akun!['id'],
            'fakultas': hasil['fakultas']!,
            'prodi': hasil['prodi']!,
            'telepon': hasil['telepon']!,
            'ruangan': hasil['ruangan']!,
            'keahlian': hasil['keahlian']!,
            'avatar_index': avatarIndex,
            'foto_custom': fotoCustom,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });

      await muat();
      if (!mounted) return;

      pesan('Profil dosen berhasil diperbarui!');
    } catch (e) {
      pesan('Gagal menyimpan profil: $e');
    } finally {
      if (mounted) {
        setState(() => menyimpan = false);
      }
    }
  }

  Widget info(
    IconData icon,
    String label,
    String isi,
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
              color: _softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _blue),
          ),
          const SizedBox(width: 12),
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
                  isi,
                  style: const TextStyle(
                    color: _dark,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkrivaDashColors.background,
      appBar: AppBar(
        title: const Text('Profil Dosen'),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: muat,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: _blue),
            )
          : RefreshIndicator(
              color: _blue,
              onRefresh: muat,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20, 18, 20, 35,
                ),
                children: [
                  const SkrivaDashboardHero(
                    eyebrow: 'SKRIVA / LECTURER PROFILE',
                    title: 'My Academic\nIdentity.',
                    subtitle:
                        'Personalize your lecturer profile.',
                    icon: Icons.school_rounded,
                  ),
                  const SizedBox(height: 20),
                  SkrivaGlassCard(
                    tint: _lime,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: gantiAvatar,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: _softBlue,
                              borderRadius:
                                  BorderRadius.circular(24),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Center(child: avatar()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          akun?['nama']?.toString() ?? '-',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _dark,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Dosen Pembimbing Skripsi',
                          style: TextStyle(
                            color: SkrivaDashColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed:
                              menyimpan ? null : gantiAvatar,
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                          ),
                          label: const Text('Ganti Avatar'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SkrivaSectionTitle(
                    title: 'Academic Information',
                    subtitle: 'Data dosen yang sedang login.',
                  ),
                  const SizedBox(height: 13),
                  SkrivaGlassCard(
                    child: Column(
                      children: [
                        info(
                          Icons.badge_outlined,
                          'NIDN / ID Dosen',
                          akun?['nomor_induk']?.toString() ?? '-',
                        ),
                        info(
                          Icons.email_outlined,
                          'Email',
                          akun?['email']?.toString() ?? '-',
                        ),
                        info(
                          Icons.account_balance_outlined,
                          'Fakultas',
                          nilai('fakultas'),
                        ),
                        info(
                          Icons.school_outlined,
                          'Program Studi',
                          nilai('prodi'),
                        ),
                        info(
                          Icons.phone_outlined,
                          'Telepon',
                          nilai('telepon'),
                        ),
                        info(
                          Icons.room_outlined,
                          'Ruangan',
                          nilai('ruangan'),
                        ),
                        info(
                          Icons.auto_awesome_rounded,
                          'Bidang Keahlian',
                          nilai('keahlian'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: menyimpan ? null : editProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit Profil'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
