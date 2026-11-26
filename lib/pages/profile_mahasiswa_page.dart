import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:test/theme/jadwal_theme.dart';
import 'package:test/database/auth_database.dart';
import 'package:test/models/mahasiswa_model.dart';
import 'package:test/repositories/mahasiswa_repository.dart';

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
  static const olive = Color(0xFF694A47);
  static const darkOlive = Color(0xFF523B39);
  static const orange = Color(0xFF96C1C5);
  static const lightOrange = Color(0xFFE5F0EF);
  static const beige = Color(0xFFEAF3F2);
  static const cream = Color(0xFFFFF0DE);

  static const List<String> _gambarBawaan = [
    'assets/icon/icon_albert.jpeg',
    'assets/icon/icon_tracy.jpeg',
    'assets/icon/icon_syahwa.jpeg',
  ];

  static const List<String> _namaAvatar = [
    'Albert',
    'Tracy',
    'Syahwa',
  ];

  static const List<IconData> _ikonBawaan = [
    Icons.person,
    Icons.face,
    Icons.school,
  ];

  final MahasiswaRepository _repo = MahasiswaRepository();

  MahasiswaModel? _profile;
  Map<String, Object?>? _akun;
  List<Map<String, Object?>> _pembimbing = [];

  int _avatarIndex = 0;
  String? _fotoCustom;

  bool _loading = true;
  bool _mengubahAvatar = false;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  // =====================================================
  // DATA PROFIL
  // =====================================================

  Future<void> _refreshProfile() async {
    try {
      final akun = await AuthDatabase.instance.sesiAktif();

      if (akun == null || akun['role'] != 'mahasiswa') {
        throw StateError(
          'Silakan login menggunakan akun mahasiswa.',
        );
      }

      final nimLogin =
          akun['nomor_induk']?.toString() ?? '';

      final daftar = await _repo.semua();

      MahasiswaModel? profil;

      for (final item in daftar) {
        if (item.nim == nimLogin) {
          profil = item;
          break;
        }
      }

      final pembimbing =
          await AuthDatabase.instance.pembimbing(
        akun['id'] as int,
      );

      final avatarIndex = await _repo.ambilAvatar();
      final fotoCustom = await _repo.ambilFotoCustom();

      if (!mounted) return;

      setState(() {
        _akun = akun;
        _profile = profil;
        _pembimbing = pembimbing;
        _avatarIndex = avatarIndex;
        _fotoCustom = fotoCustom;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);
      _tampilkanPesan('Gagal memuat profil: $e');
    }
  }

  String get namaMahasiswa {
    final namaProfil = _profile?.nama.trim() ?? '';

    if (namaProfil.isNotEmpty) {
      return namaProfil;
    }

    return _akun?['nama']?.toString() ?? 'Mahasiswa';
  }

  String get nimMahasiswa {
    return _akun?['nomor_induk']?.toString() ?? '-';
  }

  String get emailMahasiswa {
    return _akun?['email']?.toString() ?? '-';
  }

  void _tampilkanPesan(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  // =====================================================
  // GAMBAR AVATAR
  // =====================================================

  Widget _gambarAvatar({
    double ukuran = 110,
  }) {
    // Foto pilihan dari galeri
    if (_avatarIndex == 6 && _fotoCustom != null) {
      final foto = File(_fotoCustom!);

      if (foto.existsSync()) {
        return ClipOval(
          child: Image.file(
            foto,
            width: ukuran,
            height: ukuran,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person,
                size: ukuran * 0.55,
                color: olive,
              );
            },
          ),
        );
      }
    }

    // Foto Albert, Tracy, Syahwa
    if (_avatarIndex >= 0 &&
        _avatarIndex < _gambarBawaan.length) {
      return ClipOval(
        child: Image.asset(
          _gambarBawaan[_avatarIndex],
          width: ukuran,
          height: ukuran,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: ukuran * 0.55,
              color: olive,
            );
          },
        ),
      );
    }

    // Ikon default
    final index = _avatarIndex - 3;

    final icon = index >= 0 && index < _ikonBawaan.length
        ? _ikonBawaan[index]
        : Icons.person;

    return Center(
      child: Icon(
        icon,
        size: ukuran * 0.55,
        color: olive,
      ),
    );
  }

  // =====================================================
  // SIMPAN PILIHAN AVATAR
  // =====================================================

  Future<void> _pilihAvatar(int index) async {
    if (_mengubahAvatar) return;

    setState(() => _mengubahAvatar = true);

    try {
      await _repo.simpanAvatar(index);

      if (!mounted) return;

      setState(() {
        _avatarIndex = index;
      });

      _tampilkanPesan('Avatar berhasil diperbarui!');
    } catch (e) {
      _tampilkanPesan('Gagal menyimpan avatar: $e');
    } finally {
      if (mounted) {
        setState(() => _mengubahAvatar = false);
      }
    }
  }

  Future<void> _pilihFotoGaleri() async {
    if (_mengubahAvatar) return;

    setState(() => _mengubahAvatar = true);

    try {
      final hasil = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (hasil == null) return;

      final path = hasil.files.single.path;

      if (path == null || path.isEmpty) {
        throw StateError(
          'Foto tidak ditemukan di perangkat.',
        );
      }

      // Simpan file foto pada folder mahasiswa aktif
      await _repo.simpanFotoCustom(path);

      // Index 6 digunakan untuk avatar custom
      await _repo.simpanAvatar(6);

      final fotoTersimpan = await _repo.ambilFotoCustom();

      if (!mounted) return;

      setState(() {
        _avatarIndex = 6;
        _fotoCustom = fotoTersimpan;
      });

      _tampilkanPesan(
        'Foto profil berhasil diperbarui!',
      );
    } catch (e) {
      _tampilkanPesan('Gagal mengganti foto: $e');
    } finally {
      if (mounted) {
        setState(() => _mengubahAvatar = false);
      }
    }
  }

  // =====================================================
  // MENU GANTI AVATAR
  // =====================================================

  Future<void> _bukaMenuAvatar() async {
    if (_mengubahAvatar) return;

    final pilihan = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Ganti Avatar',
                  style: TextStyle(
                    color: darkOlive,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Pilih avatar favoritmu atau gunakan '
                  'foto sendiri dari galeri.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 25),

                // FOTO DARI ASSETS
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    _gambarBawaan.length,
                    (index) {
                      final terpilih =
                          _avatarIndex == index;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            sheetContext,
                            index,
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: terpilih
                                      ? olive
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor: lightOrange,
                                backgroundImage: AssetImage(
                                  _gambarBawaan[index],
                                ),
                              ),
                            ),

                            const SizedBox(height: 7),

                            Text(
                              _namaAvatar[index],
                              style: TextStyle(
                                fontSize: 12,
                                color: darkOlive,
                                fontWeight: terpilih
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Atau pilih ikon',
                  style: TextStyle(
                    color: darkOlive,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 13),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    _ikonBawaan.length,
                    (index) {
                      final avatarId = index + 3;
                      final terpilih =
                          _avatarIndex == avatarId;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            sheetContext,
                            avatarId,
                          );
                        },
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: terpilih
                                ? orange
                                : lightOrange,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: terpilih
                                  ? olive
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _ikonBawaan[index],
                            size: 30,
                            color: olive,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext, 6);
                    },
                    icon: const Icon(
                      Icons.photo_library_outlined,
                    ),
                    label: const Text(
                      'Pilih Foto dari Galeri',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: olive,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || pilihan == null) return;

    if (pilihan == 6) {
      await _pilihFotoGaleri();
    } else {
      await _pilihAvatar(pilihan);
    }
  }

  // =====================================================
  // EDIT PROFIL MAHASISWA
  // =====================================================

  Future<void> _editProfile() async {
    if (_akun == null) return;

    final name = TextEditingController(
      text: namaMahasiswa,
    );

    final prodi = TextEditingController(
      text: _profile?.prodi ?? '',
    );

    final judul = TextEditingController(
      text: _profile?.judulSkripsi ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profil Mahasiswa'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: prodi,
                  decoration: const InputDecoration(
                    labelText: 'Program Studi',
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: judul,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Judul Skripsi',
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'NIM, email login, dan dosen pembimbing '
                  'mengikuti data akun yang terdaftar.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    final namaBaru = name.text.trim();
    final prodiBaru = prodi.text.trim();
    final judulBaru = judul.text.trim();

    name.dispose();
    prodi.dispose();
    judul.dispose();

    if (result != true) return;

    if (namaBaru.isEmpty) {
      _tampilkanPesan('Nama wajib diisi.');
      return;
    }

    try {
      final data = MahasiswaModel(
        id: _profile?.id,
        nama: namaBaru,
        nim: nimMahasiswa,
        email: emailMahasiswa,
        prodi: prodiBaru,
        semester: _profile?.semester ?? 1,
        judulSkripsi: judulBaru,
      );

      if (_profile == null) {
        await _repo.tambah(data);
      } else {
        await _repo.ubah(data);
      }

      await _refreshProfile();

      _tampilkanPesan('Profil berhasil disimpan!');
    } catch (e) {
      _tampilkanPesan('Gagal menyimpan profil: $e');
    }
  }

  // =====================================================
  // WIDGET INFORMASI MAHASISWA
  // =====================================================

  Widget _labelInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value.trim().isEmpty ? '-' : value,
            style: const TextStyle(
              color: darkOlive,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // KARTU DOSEN PEMBIMBING
  // =====================================================

  Widget _kartuPembimbing() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.school_rounded,
                color: orange,
              ),
              SizedBox(width: 10),
              Text(
                'Dosen Pembimbing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkOlive,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (_pembimbing.isEmpty)
            const Text(
              'Belum ada dosen pembimbing.',
              style: TextStyle(color: Colors.grey),
            ),

          ..._pembimbing.map((dosen) {
            final id = dosen['id'] as int;
            final nama =
                dosen['nama']?.toString() ?? '-';

            final urutan = dosen['urutan'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: beige,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 23,
                    backgroundColor: lightOrange,
                    child: Icon(
                      Icons.person,
                      color: olive,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pembimbing $urutan',
                          style: const TextStyle(
                            color: olive,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          nama,
                          style: const TextStyle(
                            color: darkOlive,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    tooltip: 'Chat Dosen',
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: olive,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailPage(
                            dosenId: id,
                            namaDosen: nama,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // =====================================================
  // MENU CHECKLIST DAN DOKUMEN
  // =====================================================

  Widget _menuFitur({
    required String judul,
    required String subtitle,
    required IconData icon,
    required Color background,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: iconColor,
              ),

              const SizedBox(height: 8),

              Text(
                judul,
                style: const TextStyle(
                  color: darkOlive,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // HALAMAN PROFIL MAHASISWA
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width;

    return AnimatedPage(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFF0DE),
                Color(0xFFE5F0EF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: olive,
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(
                      screenWidth * 0.05,
                    ),
                    child: Column(
                      children: [
                        // HEADER
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.05,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                  color: orange,
                                ),
                              ),
                            ),

                            const Expanded(
                              child: Center(
                                child: Text(
                                  'Profil Mahasiswa',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: darkOlive,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 42),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // AVATAR YANG BISA DIKLIK
                        GestureDetector(
                          onTap: _bukaMenuAvatar,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: lightOrange,
                                ),
                                child: _gambarAvatar(),
                              ),

                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: olive,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 9),

                        TextButton.icon(
                          onPressed: _bukaMenuAvatar,
                          icon: const Icon(
                            Icons.edit,
                            size: 15,
                          ),
                          label: const Text('Ganti Avatar'),
                          style: TextButton.styleFrom(
                            foregroundColor: olive,
                          ),
                        ),

                        const SizedBox(height: 7),

                        // NAMA MAHASISWA
                        Text(
                          namaMahasiswa,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: darkOlive,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          _profile?.prodi.isNotEmpty == true
                              ? _profile!.prodi
                              : 'Mahasiswa Skriva',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // INFORMASI MAHASISWA
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.05,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informasi Mahasiswa',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: darkOlive,
                                ),
                              ),

                              const SizedBox(height: 20),

                              _labelInfo(
                                'NIM',
                                nimMahasiswa,
                              ),

                              _labelInfo(
                                'Email',
                                emailMahasiswa,
                              ),

                              _labelInfo(
                                'Program Studi',
                                _profile?.prodi ?? '-',
                              ),

                              _labelInfo(
                                'Semester',
                                _profile?.semester.toString() ?? '-',
                              ),

                              _labelInfo(
                                'Judul Skripsi',
                                _profile?.judulSkripsi ?? '-',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // DUA DOSEN PEMBIMBING
                        _kartuPembimbing(),

                        const SizedBox(height: 25),

                        // CHECKLIST DAN DOKUMEN
                        Row(
                          children: [
                            _menuFitur(
                              judul: 'Checklist',
                              subtitle: 'Progress skripsi',
                              icon: Icons.checklist_rounded,
                              background: lightOrange,
                              iconColor: olive,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ChecklistPage(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(width: 12),

                            _menuFitur(
                              judul: 'Dokumen',
                              subtitle: 'File skripsi',
                              icon: Icons.folder_rounded,
                              background: beige,
                              iconColor: orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const DokumenPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // TOMBOL EDIT PROFIL
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _editProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: olive,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profil'),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
