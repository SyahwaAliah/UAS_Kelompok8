import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/service/notification_service.dart';
import 'package:test/pages/dashboard_page.dart';

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
      title: 'Bimbingan Skripsi',
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
      home: const DashboardPage(),
    );
  }
}
