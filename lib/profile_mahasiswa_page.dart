import 'package:flutter/material.dart';
import 'jadwal_theme.dart';

import 'checklist_page.dart';
import 'dokumen_page.dart';
import 'models/mahasiswa_model.dart';
import 'repositories/mahasiswa_repository.dart';

class ProfileMahasiswaPage extends StatefulWidget {
  const ProfileMahasiswaPage({super.key});

  @override
  State<ProfileMahasiswaPage> createState() => _ProfileMahasiswaPageState();
}

class _ProfileMahasiswaPageState extends State<ProfileMahasiswaPage> {
  final _repo = MahasiswaRepository();
  MahasiswaModel? _profile;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    try {
      final rows = await _repo.semua();
      if (!mounted) return;
      setState(() => _profile = rows.isEmpty ? null : rows.first);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil: $e')),
      );
    }
  }

  Future<void> _editProfile() async {
    final name = TextEditingController(text: _profile?.nama ?? '');
    final nim = TextEditingController(text: _profile?.nim ?? '');
    final prodi = TextEditingController(text: _profile?.prodi ?? '');
    final judul = TextEditingController(text: _profile?.judulSkripsi ?? '');
    final email = TextEditingController(text: _profile?.email ?? '');
    final result = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil Mahasiswa'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: nim, decoration: const InputDecoration(labelText: 'NIM')),
            TextField(controller: prodi, decoration: const InputDecoration(labelText: 'Prodi')),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: judul, decoration: const InputDecoration(labelText: 'Judul Skripsi')),
          ],
        )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (result == true) {
      if (name.text.trim().isEmpty || nim.text.trim().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama dan NIM wajib diisi')));
      } else {
        try {
          final data = MahasiswaModel(id: _profile?.id,
            nama: name.text.trim(), nim: nim.text.trim(),
            prodi: prodi.text.trim(), email: email.text.trim(),
            judulSkripsi: judul.text.trim(), semester: _profile?.semester ?? 1);
          if (_profile == null) { await _repo.tambah(data); }
          else { await _repo.ubah(data); }
          await _refreshProfile();
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan profil: $e')));
        }
      }
    }
    name.dispose(); nim.dispose(); prodi.dispose(); judul.dispose(); email.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const olive = Color(0xFF694A47);
    const darkOlive = Color(0xFF523B39);
    const orange = Color(0xFF96C1C5);
    const lightOrange = Color(0xFFE5F0EF);
    const beige = Color(0xFFEAF3F2);

    final screenWidth =
        MediaQuery.of(context).size.width;

    return AnimatedPage(child: Scaffold(
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              screenWidth * 0.05,
            ),
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
                            color:
                                Colors.black.withOpacity(0.05),
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
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: olive,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  _profile?.nama ?? 'Belum diisi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkOlive,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Mahasiswa Sistem Informasi',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Mahasiswa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkOlive,
                        ),
                      ),

                      SizedBox(height: 20),

                      Text(
                        'NIM',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        _profile?.nim ?? '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 16),

                      Text(
                        'Program Studi',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        _profile?.prodi ?? '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 16),

                      Text(
                        'Judul Skripsi',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        _profile?.judulSkripsi ?? '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 16),

                      Text(
                        'Dosen Pembimbing',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Dr. Budi Santoso, S.Kom., M.Kom.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
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
                              builder: (context) =>
                                  const ChecklistPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: lightOrange,
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                          child: const Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.checklist_rounded,
                                color: olive,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Checklist',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
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
                              builder: (context) =>
                                  const DokumenPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: beige,
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                          child: const Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.folder_rounded,
                                color: orange,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Dokumen',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
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
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _editProfile,
                    icon: const Icon(Icons.edit),
                    label:
                        const Text('Edit Profil'),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}