
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/pages/dashboard_page.dart';
import 'package:test/pages/dashboard_dosen_page.dart';
import 'package:test/pages/login_page.dart';
import 'package:test/service/notification_service.dart';

import 'package:test/widgets/skriva_dashboard_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.init();
  await NotificationService.instance.requestPermission();

  runApp(const MyApp());
}

// =====================================================
// MAIN APPLICATION
// =====================================================

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

        scaffoldBackgroundColor:
            SkrivaDashColors.background,

        colorScheme: ColorScheme.fromSeed(
          seedColor: SkrivaDashColors.blue,
          primary: SkrivaDashColors.blue,
          onPrimary: Colors.white,
          secondary: SkrivaDashColors.lime,
          onSecondary: SkrivaDashColors.dark,
          surface: SkrivaDashColors.background,
          onSurface: SkrivaDashColors.dark,
        ),

        pageTransitionsTheme:
            const PageTransitionsTheme(
          builders: {
            TargetPlatform.android:
                FadeUpwardsPageTransitionsBuilder(),
          },
        ),

        appBarTheme: AppBarTheme(
          backgroundColor:
              SkrivaDashColors.background,
          foregroundColor: SkrivaDashColors.dark,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontFamily: kroneOne,
            color: SkrivaDashColors.dark,
            fontSize: 17,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFDCE8F2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: SkrivaDashColors.blue,
              width: 1.8,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: SkrivaDashColors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor: SkrivaDashColors.blue,
          foregroundColor: Colors.white,
        ),

        progressIndicatorTheme:
            const ProgressIndicatorThemeData(
          color: SkrivaDashColors.blue,
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: SkrivaDashColors.lime,
          surfaceTintColor: Colors.transparent,
        ),
      ),

      home: const AuthGate(),
    );
  }
}

// =====================================================
// AUTH GATE
// =====================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, Object?>?> cekSesi() {
    return AuthDatabase.instance.sesiAktif();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Object?>?>(
      future: cekSesi(),
      builder: (context, snapshot) {
        if (snapshot.connectionState !=
            ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal membuka database:\n'
                  '${snapshot.error}',
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
