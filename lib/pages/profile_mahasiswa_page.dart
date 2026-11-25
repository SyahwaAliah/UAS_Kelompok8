import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:test/theme/jadwal_theme.dart';
import 'package:test/pages/checklist_page.dart';
import 'package:test/pages/dokumen_page.dart';
import 'package:test/models/mahasiswa_model.dart';
import 'package:test/repositories/mahasiswa_repository.dart';

class ProfileMahasiswaPage extends StatefulWidget {
  const ProfileMahasiswaPage({super.key});

  @override
  State<ProfileMahasiswaPage> createState() => _ProfileMahasiswaPageState();
}

class _ProfileMahasiswaPageState extends State<ProfileMahasiswaPage> {
  final _repo = MahasiswaRepository();

  MahasiswaModel? _profile;
  int _avatarIndex = 0;
  String? _fotoCustom;
  bool _menyimpan = false;

  static const olive = Color(0xFF694A47);
  static const darkOlive = Color(0xFF523B39);
  static const orange = Color(0xFF96C1C5);
  static const lightOrange = Color(0xFFE5F0EF);
  static const beige = Color(0xFFEAF3F2);

  static const List<String> avatarImages = [
    'assets/icon/icon_albert.jpeg',
    'assets/icon/icon_tracy.jpeg',
    'assets/icon/icon_syahwa.jpeg',
  ];

  static const List<IconData> avatarIcons = [
    Icons.person,
    Icons.face,
    Icons.school,
  ];

  Widget tampilkanAvatar(int index, {double size = 60}) {
    if (index == 6) {
      final filePath = _fotoCustom;
      if (filePath != null && File(filePath).existsSync()) {
        return ClipOval(child: Image.file(File(filePath), width: size,
          height: size, fit: BoxFit.cover));
      }
      return Icon(Icons.add_a_photo, color: olive, size: size * 0.6);
    }
    if (index >= 0 && index < avatarImages.length) {
      return ClipOval(
        child: Image.asset(
          avatarImages[index],
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person, color: olive, size: size * 0.6);
          },
        ),
      );
    }

    final iconIndex = index - avatarImages.length;

    return Icon(
      iconIndex >= 0 && iconIndex < avatarIcons.length
          ? avatarIcons[iconIndex]
          : Icons.person,
      color: olive,
      size: size * 0.6,
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    try {
      final rows = await _repo.semua();
      final avatar = await _repo.ambilAvatar();
      final fotoCustom = await _repo.ambilFotoCustom();

      if (!mounted) return;

      setState(() {
        _profile = rows.isEmpty ? null : rows.first;
        _avatarIndex = avatar;
        _fotoCustom = fotoCustom;
      });
    } catch (e) {
      _tampilkanPesan('Gagal memuat profil: $e');
    }
  }

  void _tampilkanPesan(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _editProfile() async {
    if (_menyimpan) return;
    var nama = _profile?.nama ?? '';
    var nim = _profile?.nim ?? '';
    var prodi = _profile?.prodi ?? '';
    var email = _profile?.email ?? '';
    var judul = _profile?.judulSkripsi ?? '';
    var avatarDipilih = _avatarIndex;
    String? fotoDipilih = _fotoCustom;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Profil Mahasiswa'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Pilih Foto Profil',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(spacing: 10, runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ...List.generate(6, (index) => GestureDetector(
                    onTap: () => setDialogState(() => avatarDipilih = index),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(
                          color: avatarDipilih == index
                              ? olive : Colors.transparent, width: 3)),
                      child: CircleAvatar(radius: 26,
                        backgroundColor: lightOrange,
                        child: tampilkanAvatar(index, size: 52)),
                    ),
                  )),
                  GestureDetector(
                    onTap: () async {
                      final chosen = await FilePicker.platform.pickFiles(
                        type: FileType.image, allowMultiple: false);
                      final chosenPath = chosen?.files.single.path;
                      if (chosenPath == null || !ctx.mounted) return;
                      setDialogState(() {
                        fotoDipilih = chosenPath;
                        avatarDipilih = 6;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(color: avatarDipilih == 6
                            ? olive : Colors.transparent, width: 3)),
                      child: CircleAvatar(radius: 26,
                        backgroundColor: lightOrange,
                        child: fotoDipilih != null && File(fotoDipilih!).existsSync()
                            ? ClipOval(child: Image.file(File(fotoDipilih!),
                                width: 52, height: 52, fit: BoxFit.cover))
                            : const Icon(Icons.add_a_photo, color: olive)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Text('Tambah foto dari galeri',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 14),
              TextFormField(initialValue: nama,
                  onChanged: (v) => nama = v,
                  decoration: const InputDecoration(labelText: 'Nama')),
              TextFormField(initialValue: nim,
                  onChanged: (v) => nim = v,
                  decoration: const InputDecoration(labelText: 'NIM')),
              TextFormField(initialValue: prodi,
                  onChanged: (v) => prodi = v,
                  decoration: const InputDecoration(labelText: 'Prodi')),
              TextFormField(initialValue: email,
                  onChanged: (v) => email = v,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email')),
              TextFormField(initialValue: judul,
                  onChanged: (v) => judul = v, maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Judul Skripsi')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            FilledButton(onPressed: () {
              if (nama.trim().isEmpty || nim.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Nama dan NIM wajib diisi')));
                return;
              }
              if (email.trim().isNotEmpty &&
                  !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(email.trim())) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Format email tidak valid')));
                return;
              }
              if (avatarDipilih == 6 && fotoDipilih == null) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Pilih foto dari galeri dahulu')));
                return;
              }
              Navigator.pop(ctx, true);
            }, child: const Text('Simpan')),
          ],
        ),
      ),
    );

    // Batal: jangan ada perubahan database ataupun file.
    if (result != true || !mounted) return;
    setState(() => _menyimpan = true);
    try {
      final item = MahasiswaModel(
        id: _profile?.id, nama: nama.trim(), nim: nim.trim(),
        prodi: prodi.trim(), email: email.trim(),
        judulSkripsi: judul.trim(), semester: _profile?.semester ?? 1);
      if (_profile == null) {
        await _repo.tambah(item);
      } else {
        final changed = await _repo.ubah(item);
        if (changed == 0) throw StateError('Data profil tidak ditemukan');
      }
      if (avatarDipilih == 6 && fotoDipilih != null &&
          fotoDipilih != _fotoCustom) {
        final dir = await getApplicationDocumentsDirectory();
        final ext = path.extension(fotoDipilih!).toLowerCase();
        final safeExt = ['.jpg', '.jpeg', '.png', '.webp'].contains(ext)
            ? ext : '.jpg';
        // Unique name avoids image cache retaining old pictures.
        final unique = path.join(dir.path,
            'skriva_avatar_${DateTime.now().microsecondsSinceEpoch}$safeExt');
        await File(fotoDipilih!).copy(unique);
        await _repo.simpanFotoCustom(unique);
      }
      await _repo.simpanAvatar(avatarDipilih);
      await _refreshProfile();
      _tampilkanPesan('Profil berhasil disimpan.');
    } catch (e) {
      _tampilkanPesan('Gagal menyimpan profil: $e');
    } finally {
      if (mounted) setState(() => _menyimpan = false);
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
              colors: [Color(0xFFFFF0DE), Color(0xFFE5F0EF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                children: [
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
                              color: Colors.black.withOpacity(0.05),
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
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightOrange,
                    ),
                    child: tampilkanAvatar(_avatarIndex, size: 110),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _profile?.nama.isNotEmpty == true
                        ? _profile!.nama
                        : 'Belum diisi',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkOlive,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Mahasiswa Sistem Informasi',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Text(
                          'NIM',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _profile?.nim ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Program Studi',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _profile?.prodi ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Judul Skripsi',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _profile?.judulSkripsi ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Dosen Pembimbing',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Dr. Budi Santoso, S.Kom., M.Kom.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChecklistPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: lightOrange,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.checklist_rounded, color: olive),
                                SizedBox(height: 8),
                                Text(
                                  'Checklist',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Progress skripsi',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DokumenPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: beige,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.folder_rounded, color: orange),
                                SizedBox(height: 8),
                                Text(
                                  'Dokumen',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'File skripsi',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: olive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _menyimpan ? null : _editProfile,
                      icon: const Icon(Icons.edit),
                      label: Text(_menyimpan ? 'Menyimpan...' : 'Edit Profil'),
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
