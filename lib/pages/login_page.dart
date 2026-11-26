import 'package:flutter/material.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/pages/dashboard_page.dart';
import 'package:test/pages/dashboard_dosen_page.dart';
import 'package:test/pages/signup_page.dart';
import 'package:test/widgets/skriva_auth_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool sembunyikanPassword = true;
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (loading) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      tampilkanPesan(
        'Email dan password wajib diisi.',
      );
      return;
    }

    setState(() => loading = true);

    try {
      final akun = await AuthDatabase.instance.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (akun == null) {
        setState(() => loading = false);
        tampilkanPesan(
          'Email atau password salah, '
          'atau akun belum aktif.',
        );
        return;
      }

      final Widget tujuan = akun['role'] == 'dosen'
          ? const DashboardDosenPage()
          : const DashboardPage();

      // Mengganti route login supaya tombol Back
      // tidak kembali ke halaman autentikasi.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => tujuan,
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      tampilkanPesan('Gagal login: $e');
    }
  }

  void tampilkanPesan(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
        backgroundColor: SkrivaAuthColors.brown,
      ),
    );
  }

  Future<void> bukaAktivasi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignupPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SkrivaAuthShell(
      heading: 'Hello, welcome back!',
      description:
          'Your thesis journey continues here.',
      heroIcon: Icons.auto_stories_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: SkrivaAuthColors.darkBrown,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.auto_awesome_rounded,
                color: SkrivaAuthColors.blue,
                size: 23,
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Text(
            'Masuk ke akun Skriva untuk melanjutkan '
            'bimbingan skripsimu.',
            style: TextStyle(
              color: Color(0xFF8C8582),
              fontSize: 12,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 25),

          SkrivaAuthField(
            label: 'Email Address',
            hint: 'Masukkan email terdaftar',
            icon: Icons.alternate_email_rounded,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 18),

          SkrivaAuthField(
            label: 'Password',
            hint: 'Masukkan password',
            icon: Icons.lock_outline_rounded,
            controller: passwordController,
            obscureText: sembunyikanPassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => login(),
            suffixIcon: IconButton(
              tooltip: sembunyikanPassword
                  ? 'Tampilkan password'
                  : 'Sembunyikan password',
              onPressed: () {
                setState(() {
                  sembunyikanPassword =
                      !sembunyikanPassword;
                });
              },
              icon: Icon(
                sembunyikanPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: SkrivaAuthColors.brown,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 28),

          SkrivaAuthButton(
            label: 'Sign In',
            icon: Icons.arrow_forward_rounded,
            loading: loading,
            onPressed: login,
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(
                child: Text(
                  'Belum aktivasi akun?',
                  style: TextStyle(
                    color: Color(0xFF857D79),
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton(
                onPressed: loading ? null : bukaAktivasi,
                style: TextButton.styleFrom(
                  foregroundColor:
                      SkrivaAuthColors.brown,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
