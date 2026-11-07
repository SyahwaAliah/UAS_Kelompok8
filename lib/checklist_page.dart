import 'package:flutter/material.dart';
import 'jadwal_theme.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() =>
      _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  bool tahap1 = true;
  bool tahap2 = true;
  bool tahap3 = false;
  bool tahap4 = false;
  bool tahap5 = false;

  Widget itemChecklist({
    required String title,
    required bool selesai,
    required VoidCallback onTap,
  }) {
    const primary = Color(0xFF694A47);
    const darkPrimary = Color(0xFF523B39);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: selesai
                    ? primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: selesai
                      ? primary
                      : Colors.grey,
                  width: 2,
                ),
              ),
              child: selesai
                  ? const Icon(
                      Icons.check,
                      size: 17,
                      color: Colors.white,
                    )
                  : null,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: selesai
                      ? TextDecoration.lineThrough
                      : null,
                  color: selesai
                      ? Colors.grey
                      : darkPrimary,
                ),
              ),
            ),

            Icon(
              selesai
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: selesai
                  ? primary
                  : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF694A47);
    const darkPrimary = Color(0xFF523B39);

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
                          size: 17,
                          color: primary,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Text(
                      'Progress Skripsi',
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
                      itemChecklist(
                        title: 'Penentuan Topik',
                        selesai: tahap1,
                        onTap: () {
                          setState(() {
                            tahap1 = !tahap1;
                          });
                        },
                      ),
                      itemChecklist(
                        title: 'Bab 1',
                        selesai: tahap2,
                        onTap: () {
                          setState(() {
                            tahap2 = !tahap2;
                          });
                        },
                      ),
                      itemChecklist(
                        title: 'Bab 2',
                        selesai: tahap3,
                        onTap: () {
                          setState(() {
                            tahap3 = !tahap3;
                          });
                        },
                      ),
                      itemChecklist(
                        title: 'Bab 3',
                        selesai: tahap4,
                        onTap: () {
                          setState(() {
                            tahap4 = !tahap4;
                          });
                        },
                      ),
                      itemChecklist(
                        title: 'Seminar Proposal',
                        selesai: tahap5,
                        onTap: () {
                          setState(() {
                            tahap5 = !tahap5;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}