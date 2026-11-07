import 'package:flutter/material.dart';
import 'jadwal_theme.dart';

import 'checklist_page.dart';
import 'dokumen_page.dart';

class ProfileMahasiswaPage extends StatelessWidget {
  const ProfileMahasiswaPage({super.key});

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

                const Text(
                  'Syahwa',
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
                  child: const Column(
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
                        '123456789',
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
                        'Sistem Informasi',
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
                        'Pengembangan Aplikasi Bimbingan Skripsi Berbasis Mobile',
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
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fitur Edit Profil masih berupa tampilan.',
                          ),
                        ),
                      );
                    },
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