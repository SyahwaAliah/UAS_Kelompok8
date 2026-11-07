import 'package:flutter/material.dart';
import 'dashboard_page.dart';

/*
Kalau mau run code jalankan di emulator Android, pastikan sudah install SQLite lokal untuk data mahasiswa.

dan jalankan ini, 

cd /d "D:\Semester 5\Moprog\UAS" (lokasi folder project)
flutter emulators --launch Medium_Phone
flutter run -d emulator-5554
*/
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bimbingan Skripsi',
      theme: ThemeData(
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()
          },
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF0DE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF694A47),
          primary: const Color(0xFF694A47),
          secondary: const Color(0xFF96C1C5),
          surface: const Color(0xFFFFF0DE),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF694A47),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}