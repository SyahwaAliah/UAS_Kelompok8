import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/pages/dashboard_page.dart';
import 'package:test/pages/dashboard_dosen_page.dart';
import 'package:test/pages/login_page.dart';
import 'package:test/service/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.init();
  await NotificationService.instance.requestPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final poppins = GoogleFonts.poppins().fontFamily;
    final kroneOne = GoogleFonts.kronaOne().fontFamily;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skriva',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: poppins,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF0DE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF694A47),
          primary: const Color(0xFF694A47),
          secondary: const Color(0xFF96C1C5),
          surface: const Color(0xFFFFF0DE),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF694A47),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontFamily: kroneOne,
            color: const Color(0xFF523B39),
            fontSize: 18,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, Object?>?> _cekSesi() {
    return AuthDatabase.instance.sesiAktif();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Object?>?>(
      future: _cekSesi(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF694A47)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal membuka database:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final akun = snapshot.data;

        if (akun == null) {
          return const LoginPage();
        }

        if (akun['role'] == 'dosen') {
          return const DashboardDosenPage();
        }

        return const DashboardPage();
      },
    );
  }
}
