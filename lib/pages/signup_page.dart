import 'package:flutter/material.dart';

import 'package:test/database/auth_database.dart';
import 'package:test/widgets/skriva_auth_ui.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final nomorController = TextEditingController();
  final passwordController = TextEditingController();
  final konfirmasiController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;
  bool hideConfirmation = true;

  @override
  void dispose() {
    emailController.dispose();
    nomorController.dispose();
    passwordController.dispose();
    konfirmasiController.dispose();
    super.dispose();
  }

  // =====================================================
  // AKTIVASI AKUN
  // =====================================================

  Future<void> aktivasi() async {
    if (loading) return;

    final email = emailController.text.trim();
    final nomorInduk = nomorController.text.trim();
    final password = passwordController.text;
    final konfirmasi = konfirmasiController.text;

    // Validasi input kosong
    if (email.isEmpty ||
        nomorInduk.isEmpty ||
        password.isEmpty ||
        konfirmasi.isEmpty) {
      pesan('Semua kolom wajib diisi.');
      return;
    }

    // Validasi konfirmasi password
    if (password != konfirmasi) {
      pesan('Konfirmasi password tidak sama.');
      return;
    }

    // Validasi panjang password
    if (password.length < 8) {
      pesan('Password minimal 8 karakter.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final error = await AuthDatabase.instance.aktivasi(
        email: email,
        nomorInduk: nomorInduk,
        password: password,
      );

      if (!mounted) return;

      // Gagal aktivasi
      if (error != null) {
        pesan(error);
        return;
      }

      // Berhasil aktivasi.
      // Ambil ScaffoldMessenger sebelum halaman ditutup.
      final messenger = ScaffoldMessenger.of(context);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil diaktivasi. Silakan login.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: SkrivaAuthColors.brown,
        ),
      );

      // Kembali ke halaman Login
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      pesan('Gagal mengaktivasi akun: $e');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // =====================================================
  // SNACKBAR
  // =====================================================

  void pesan(String value) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        backgroundColor: SkrivaAuthColors.brown,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =====================================================
  // HALAMAN SIGN UP / AKTIVASI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return SkrivaAuthShell(
      heading: "Let's get started!",
      description: 'Activate your account, start your journey.',
      heroIcon: Icons.school_rounded,
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Join Skriva!',
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

          const SizedBox(height: 6),

          const Text(
            'Aktivasi menggunakan email dan nomor induk '
            'yang telah didaftarkan oleh kampus.',
            style: TextStyle(
              color: Color(0xFF8C8582),
              fontSize: 12,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          // EMAIL
          SkrivaAuthField(
            label: 'Email Terdaftar',
            hint: 'Masukkan email kampus',
            icon: Icons.alternate_email_rounded,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 17),

          // NOMOR INDUK
          SkrivaAuthField(
            label: 'Nomor Induk',
            hint: 'NIM / NIDN / ID Dosen',
            icon: Icons.badge_outlined,
            controller: nomorController,
          ),

          const SizedBox(height: 17),

          // PASSWORD
          SkrivaAuthField(
            label: 'Buat Password',
            hint: 'Minimal 8 karakter',
            icon: Icons.lock_outline_rounded,
            controller: passwordController,
            obscureText: hidePassword,
            suffixIcon: IconButton(
              tooltip: hidePassword
                  ? 'Tampilkan password'
                  : 'Sembunyikan password',
              onPressed: () {
                setState(() {
                  hidePassword = !hidePassword;
                });
              },
              icon: Icon(
                hidePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: SkrivaAuthColors.brown,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 17),

          // KONFIRMASI PASSWORD
          SkrivaAuthField(
            label: 'Konfirmasi Password',
            hint: 'Ulangi password',
            icon: Icons.verified_user_outlined,
            controller: konfirmasiController,
            obscureText: hideConfirmation,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => aktivasi(),
            suffixIcon: IconButton(
              tooltip: hideConfirmation
                  ? 'Tampilkan password'
                  : 'Sembunyikan password',
              onPressed: () {
                setState(() {
                  hideConfirmation = !hideConfirmation;
                });
              },
              icon: Icon(
                hideConfirmation
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: SkrivaAuthColors.brown,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 25),

          // TOMBOL AKTIVASI
          SkrivaAuthButton(
            label: 'Activate Account',
            icon: Icons.check_circle_outline_rounded,
            loading: loading,
            onPressed: aktivasi,
          ),

          const SizedBox(height: 17),

          // KEMBALI KE LOGIN
          Center(
            child: TextButton.icon(
              onPressed: loading ? null : () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 17),
              label: const Text('Sudah punya akun? Sign In'),
              style: TextButton.styleFrom(
                foregroundColor: SkrivaAuthColors.brown,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
