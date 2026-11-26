import 'package:flutter/material.dart';
import 'package:test/database/auth_database.dart';
import 'package:test/pages/dashboard_page.dart';
import 'package:test/pages/dashboard_dosen_page.dart';
import 'package:test/pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const olive = Color(0xFF694A47);
  static const darkOlive = Color(0xFF523B39);
  static const blue = Color(0xFF96C1C5);
  static const cream = Color(0xFFFFF0DE);

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
      tampilkanPesan('Email dan password wajib diisi.');
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
        tampilkanPesan('Email atau password salah, atau akun belum aktif.');
        return;
      }

      final Widget tujuan = akun['role'] == 'dosen'
          ? const DashboardDosenPage()
          : const DashboardPage();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => tujuan),
        (route) => false,
      );
    } catch (e) {
      tampilkanPesan('Gagal login: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void tampilkanPesan(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [cream, Color(0xFFE5F0EF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  Container(
                    width: 95,
                    height: 95,
                    decoration: const BoxDecoration(
                      color: olive,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Skriva',
                    style: TextStyle(
                      color: darkOlive,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Your Thesis Companion',
                    style: TextStyle(color: olive, fontSize: 13),
                  ),
                  const SizedBox(height: 35),
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 23,
                            color: darkOlive,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Masuk menggunakan akun Skriva kamu.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 25),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: olive,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: passwordController,
                          obscureText: sembunyikanPassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: olive,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                sembunyikanPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  sembunyikanPassword = !sembunyikanPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: loading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: olive,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Belum aktivasi akun? Sign Up',
                              style: TextStyle(color: olive),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Skripsi lebih terarah bersama Skriva.',
                    style: TextStyle(color: blue, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
