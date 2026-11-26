
import 'package:flutter/material.dart';

import 'package:test/widgets/skriva_dashboard_ui.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({super.key});

  @override
  State<VideoCallPage> createState() =>
      _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  static const blue = SkrivaDashColors.blue;
  static const dark = SkrivaDashColors.dark;
  static const lime = SkrivaDashColors.lime;

  bool micAktif = false;
  bool kameraAktif = false;

  Widget tombolKontrol({
    required IconData icon,
    required VoidCallback onTap,
    required Color background,
    required Color foreground,
    required String tooltip,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        fixedSize: const Size(60, 60),
        backgroundColor: background,
        foregroundColor: foreground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      icon: Icon(icon, size: 25),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkrivaDashColors.background,
      appBar: AppBar(
        backgroundColor: SkrivaDashColors.background,
        foregroundColor: dark,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Video Call',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2463EB),
                        Color(0xFF4389F0),
                        Color(0xFF9ACFE8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: blue.withValues(alpha: 0.18),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 70,
                              backgroundColor: lime,
                              child: Icon(
                                Icons.video_camera_front_rounded,
                                color: dark,
                                size: 65,
                              ),
                            ),

                            SizedBox(height: 20),

                            Text(
                              'Skriva Meeting Room',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            SizedBox(height: 9),

                            Text(
                              'Belum terhubung ke panggilan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Positioned(
                        top: 18,
                        right: 18,
                        child: Container(
                          width: 100,
                          height: 135,
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white
                                  .withValues(alpha: 0.65),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                kameraAktif
                                    ? Icons.videocam_rounded
                                    : Icons.videocam_off_rounded,
                                color: Colors.white,
                                size: 37,
                              ),

                              const SizedBox(height: 9),

                              const Text(
                                'Kamu',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SkrivaGlassCard(
                tint: SkrivaDashColors.softBlue,
                child: Column(
                  children: [
                    const Text(
                      'MEETING CONTROLS',
                      style: TextStyle(
                        color: blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: [
                        tombolKontrol(
                          icon: micAktif
                              ? Icons.mic_rounded
                              : Icons.mic_off_rounded,
                          onTap: () {
                            setState(() {
                              micAktif = !micAktif;
                            });
                          },
                          background: SkrivaDashColors.softBlue,
                          foreground: dark,
                          tooltip: 'Ubah status mikrofon',
                        ),

                        tombolKontrol(
                          icon: Icons.call_end_rounded,
                          onTap: () => Navigator.pop(context),
                          background: const Color(0xFFEA5D6C),
                          foreground: Colors.white,
                          tooltip: 'Keluar',
                        ),

                        tombolKontrol(
                          icon: kameraAktif
                              ? Icons.videocam_rounded
                              : Icons.videocam_off_rounded,
                          onTap: () {
                            setState(() {
                              kameraAktif = !kameraAktif;
                            });
                          },
                          background: lime,
                          foreground: dark,
                          tooltip: 'Ubah status kamera',
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Mode preview UI — belum tersambung ke layanan video call.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: SkrivaDashColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
