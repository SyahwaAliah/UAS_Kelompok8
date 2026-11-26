import 'package:flutter/material.dart';
import 'package:test/database/auth_database.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  static const olive = Color(0xFF694A47);
  static const cream = Color(0xFFFFF0DE);

  final emailController = TextEditingController();
  final nomorController = TextEditingController();
  final passwordController = TextEditingController();
  final konfirmasiController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    nomorController.dispose();
    passwordController.dispose();
    konfirmasiController.dispose();
    super.dispose();
  }

  Future<void> aktivasi() async {
    if (loading) return;

    if (passwordController.text != konfirmasiController.text) {
      pesan('Konfirmasi password tidak sama.');
      return;
    }

    setState(() => loading = true);

    try {
      final error = await AuthDatabase.instance.aktivasi(
        email: emailController.text,
        nomorInduk: nomorController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      if (error != null) {
        pesan(error);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil diaktivasi. Silakan login.'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      pesan('Gagal mengaktivasi akun: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void pesan(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Widget input(
    String label,
    TextEditingController controller, {
    bool password = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: password && hidePassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          suffixIcon: password
              ? IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => hidePassword = !hidePassword);
                  },
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: const Text('Aktivasi Akun'),
        backgroundColor: cream,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.person_add_alt_1_rounded, color: olive, size: 60),
            const SizedBox(height: 15),
            const Text(
              'Join Skriva!',
              style: TextStyle(
                color: olive,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aktivasi menggunakan email dan nomor induk '
              'yang sudah didaftarkan oleh kampus.',
            ),
            const SizedBox(height: 25),
            input('Email terdaftar', emailController),
            input('NIM / NIDN / ID Dosen', nomorController),
            input('Buat Password', passwordController, password: true),
            input('Konfirmasi Password', konfirmasiController, password: true),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : aktivasi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: olive,
                  foregroundColor: Colors.white,
                ),
                child: Text(loading ? 'Memproses...' : 'Aktivasi Akun'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
