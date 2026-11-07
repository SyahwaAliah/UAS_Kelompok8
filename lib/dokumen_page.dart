import 'package:flutter/material.dart';
import 'jadwal_theme.dart';

class DokumenPage extends StatelessWidget {
  const DokumenPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF694A47);
    const darkPrimary = Color(0xFF523B39);
    const orange = Color(0xFF96C1C5);

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
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
                          color: primary,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Text(
                      'Dokumen Skripsi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      documentCard(
                        'Proposal Skripsi',
                        'PDF • 2.4 MB',
                      ),
                      documentCard(
                        'Bab 1 - Pendahuluan',
                        'PDF • 1.8 MB',
                      ),
                      documentCard(
                        'Bab 2 - Landasan Teori',
                        'PDF • 2.1 MB',
                      ),
                      documentCard(
                        'Bab 3 - Metodologi',
                        'PDF • 1.9 MB',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Fitur tambah dokumen masih berupa tampilan.',
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    ));
  }

  Widget documentCard(
    String title,
    String subtitle,
  ) {
    const orange = Color(0xFF96C1C5);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: orange,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
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

          const Icon(
            Icons.download_rounded,
            color: orange,
          ),
        ],
      ),
    );
  }
}