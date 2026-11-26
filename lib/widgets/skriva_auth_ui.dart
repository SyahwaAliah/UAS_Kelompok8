import 'dart:ui';

import 'package:flutter/material.dart';

// =====================================================
// SKRIVA AUTH COLORS
// =====================================================

class SkrivaAuthColors {
  static const blue = Color(0xFF2463EB);
  static const darkBlue = Color(0xFF1647B5);
  static const lime = Color(0xFFC8F4A4);
  static const softBlue = Color(0xFFB9E8EF);
  static const peach = Color(0xFFFFDAC7);
  static const lavender = Color(0xFFDAD5FF);

  static const background = Color(0xFFF6F8FB);
  static const dark = Color(0xFF243F53);
  static const muted = Color(0xFF74818D);
  static const white = Colors.white;

  // Alias supaya login_page.dart dan signup_page.dart
  // yang lama tetap kompatibel.
  static const brown = blue;
  static const darkBrown = dark;
  static const cream = background;
  static const softPink = peach;
}

// =====================================================
// SKRIVA AUTH ASSETS
// =====================================================

class SkrivaAuthAssets {
  static const logo = 'assets/icon/icon.jpeg';

  // Background kartu Login
  static const welcome = 'assets/icon/welcome.jpeg';

  // Background kartu Sign Up
  static const started = 'assets/icon/started.jpeg';
}

// =====================================================
// AUTH SHELL
// Dipakai oleh Login dan Sign Up
// =====================================================

class SkrivaAuthShell extends StatefulWidget {
  final String heading;
  final String description;
  final IconData heroIcon;
  final Widget child;
  final bool showBackButton;

  const SkrivaAuthShell({
    super.key,
    required this.heading,
    required this.description,
    required this.heroIcon,
    required this.child,
    this.showBackButton = false,
  });

  @override
  State<SkrivaAuthShell> createState() =>
      _SkrivaAuthShellState();
}

class _SkrivaAuthShellState extends State<SkrivaAuthShell>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _ambient;

  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  String get _heroBackground {
    return widget.showBackButton
        ? SkrivaAuthAssets.started
        : SkrivaAuthAssets.welcome;
  }

  @override
  void initState() {
    super.initState();

    // Animasi saat halaman dibuka.
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    // Gerakan cahaya glossy secara perlahan.
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    final curved = CurvedAnimation(
      parent: _entrance,
      curve: Curves.easeOutCubic,
    );

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(curved);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(curved);

    _entrance.forward();
    _ambient.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  // =====================================================
  // AMBIENT GLOW
  // =====================================================

  Widget _glow({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // LOGO SKRIVA
  // Kotak rounded, tanpa outline.
  // =====================================================

  Widget _logo() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: SkrivaAuthColors.blue.withValues(
              alpha: 0.15,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        SkrivaAuthAssets.logo,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: SkrivaAuthColors.white,
            alignment: Alignment.center,
            child: Icon(
              widget.heroIcon,
              color: SkrivaAuthColors.blue,
              size: 29,
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // HERO CARD
  // Background berbeda, logo tetap sama.
  // =====================================================

  Widget _hero() {
    return Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: SkrivaAuthColors.blue.withValues(
              alpha: 0.14,
            ),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Gradient cadangan jika gambar belum tersedia.
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFB9E8EF),
                    Color(0xFFEAF5FA),
                    Color(0xFFDAD5FF),
                  ],
                ),
              ),
            ),
          ),

          // Gambar background buatanmu.
          Positioned.fill(
            child: Image.asset(
              _heroBackground,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),

          // Lapisan kaca tipis.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.58),
                    Colors.white.withValues(alpha: 0.24),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),

          // Glossy highlight bagian atas.
          Positioned(
            top: -55,
            right: -25,
            child: Container(
              width: 175,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.19,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              18,
              20,
              18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _logo(),

                const SizedBox(height: 17),

                Text(
                  widget.heading,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SkrivaAuthColors.dark,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  widget.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SkrivaAuthColors.dark,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // GLASS FORM CARD
  // =====================================================

  Widget _glassForm() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: SkrivaAuthColors.blue.withValues(
              alpha: 0.08,
            ),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.82),
                  SkrivaAuthColors.softBlue.withValues(
                    alpha: 0.35,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.95,
                ),
                width: 1.6,
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  // =====================================================
  // MAIN PAGE
  // Tidak memakai polkadot.
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkrivaAuthColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background utama.
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8FAFF),
                    Color(0xFFEAF5FA),
                    Color(0xFFF5F3FF),
                  ],
                ),
              ),
            ),
          ),

          // Ambient glow.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ambient,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: -100 + (_ambient.value * 35),
                        right: -120,
                        child: _glow(
                          size: 285,
                          color: SkrivaAuthColors.softBlue
                              .withValues(alpha: 0.54),
                        ),
                      ),

                      Positioned(
                        bottom: -130 - (_ambient.value * 25),
                        left: -115,
                        child: _glow(
                          size: 310,
                          color: SkrivaAuthColors.lavender
                              .withValues(alpha: 0.40),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 440,
                  ),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          // Tombol kembali pada Sign Up.
                          if (widget.showBackButton)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton.filledTonal(
                                onPressed: () {
                                  Navigator.maybePop(context);
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(
                                    alpha: 0.85,
                                  ),
                                  foregroundColor:
                                      SkrivaAuthColors.blue,
                                ),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 17,
                                ),
                              ),
                            ),

                          if (widget.showBackButton)
                            const SizedBox(height: 10),

                          _hero(),

                          const SizedBox(height: 22),

                          _glassForm(),

                          const SizedBox(height: 20),

                          const Center(
                            child: Text(
                              'Skripsi lebih terarah bersama Skriva.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: SkrivaAuthColors.muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// REUSABLE INPUT FIELD
// =====================================================

class SkrivaAuthField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  const SkrivaAuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: SkrivaAuthColors.dark,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          onSubmitted: onSubmitted,
          style: const TextStyle(
            color: SkrivaAuthColors.dark,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: SkrivaAuthColors.muted,
              fontSize: 12,
            ),
            filled: true,
            fillColor: Colors.white.withValues(
              alpha: 0.88,
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: SkrivaAuthColors.blue,
            ),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 17,
              horizontal: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: Color(0xFFDCE8F2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: SkrivaAuthColors.blue,
                width: 1.8,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// REUSABLE GLOSSY BUTTON
// =====================================================

class SkrivaAuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onPressed;

  const SkrivaAuthButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4389F0),
              Color(0xFF2463EB),
              Color(0xFF1647B5),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: SkrivaAuthColors.blue.withValues(
                alpha: 0.24,
              ),
              blurRadius: 17,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor:
                Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  icon,
                  size: 19,
                ),
          label: Text(
            loading ? 'Memproses...' : label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
