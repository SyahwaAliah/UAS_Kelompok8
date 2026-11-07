import 'package:flutter/material.dart';
import 'jadwal_theme.dart';

class VideoCallPage extends StatelessWidget {
  const VideoCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    const olive = Color(0xFF694A47);
    const darkOlive = Color(0xFF523B39);
    const orange = Color(0xFF96C1C5);
    const lightOrange = Color(0xFFE5F0EF);

    return AnimatedPage(child: Scaffold(
      backgroundColor: darkOlive,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Video Call',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lightOrange,
                    border: Border.all(
                      color: orange,
                      width: 5,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 90,
                    color: olive,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Dr. Budi Santoso',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 20,
            top: 20,
            child: Container(
              width: 105,
              height: 145,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white30,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: lightOrange,
                    child: Icon(
                      Icons.person,
                      color: olive,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kamu',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.mic_off,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 20),

                CircleAvatar(
                  radius: 30,
                  backgroundColor: orange,
                  child: IconButton(
                    icon: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                const SizedBox(width: 20),

                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.videocam,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}