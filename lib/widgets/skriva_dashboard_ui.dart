import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

// =====================================================
// SKRIVA DASHBOARD COLORS
// =====================================================

class SkrivaDashColors {
  static const blue = Color(0xFF2463EB);
  static const darkBlue = Color(0xFF1647B5);
  static const lime = Color(0xFFC8F4A4);
  static const softBlue = Color(0xFFB9E8EF);
  static const peach = Color(0xFFFFDAC7);
  static const lavender = Color(0xFFDAD5FF);
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF6F8FB);
  static const dark = Color(0xFF243F53);
  static const muted = Color(0xFF74818D);
}

// =====================================================
// BACKGROUND + ANIMATION
// =====================================================

class SkrivaDashboardShell extends StatefulWidget {
  final Widget child;
  final Widget? bottomNavigationBar;

  const SkrivaDashboardShell({
    super.key,
    required this.child,
    this.bottomNavigationBar,
  });

  @override
  State<SkrivaDashboardShell> createState() =>
      _SkrivaDashboardShellState();
}

class _SkrivaDashboardShellState
    extends State<SkrivaDashboardShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(curved);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.045),
      end: Offset.zero,
    ).animate(curved);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkrivaDashColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF6F8FB),
                    Color(0xFFEDF8F8),
                    Color(0xFFF8F5FF),
                  ],
                ),
              ),
            ),
          ),

          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DashboardDots(),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}

class _DashboardDots extends CustomPainter {
  const _DashboardDots();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SkrivaDashColors.blue.withValues(alpha: 0.07);

    for (double x = 15; x < size.width; x += 30) {
      for (double y = 15; y < size.height; y += 30) {
        final edge = math.min(
          math.min(x, size.width - x),
          math.min(y, size.height - y),
        );

        if (edge < 115) {
          canvas.drawCircle(
            Offset(x, y),
            1.5,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// =====================================================
// GLASS CARD
// =====================================================

class SkrivaGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color tint;

  const SkrivaGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.tint = const Color(0xFFFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.94),
                tint.withValues(alpha: 0.80),
                Colors.white.withValues(alpha: 0.72),
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.94),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: SkrivaDashColors.dark
                    .withValues(alpha: 0.05),
                blurRadius: 25,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// =====================================================
// BANNER BLUE
// =====================================================

class SkrivaDashboardHero extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;

  const SkrivaDashboardHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 178),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(29),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2463EB),
            Color(0xFF4389F0),
            Color(0xFF9ACFE8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: SkrivaDashColors.blue
                .withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -46,
            right: -38,
            child: Container(
              height: 165,
              width: 165,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -60,
            right: 55,
            child: Container(
              height: 145,
              width: 145,
              decoration: BoxDecoration(
                color: SkrivaDashColors.lime
                    .withValues(alpha: 0.28),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        eyebrow.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    Icon(
                      icon,
                      color: SkrivaDashColors.lime,
                      size: 26,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// SECTION TITLE
// =====================================================

class SkrivaSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SkrivaSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: SkrivaDashColors.dark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              color: SkrivaDashColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

// =====================================================
// BENTO ACTION CARD
// =====================================================

class SkrivaActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const SkrivaActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                Color.lerp(color, Colors.white, 0.35)!,
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.88),
              width: 1.3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.arrow_outward_rounded,
                    color: SkrivaDashColors.dark,
                    size: 17,
                  ),
                ),

                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: SkrivaDashColors.dark,
                  ),
                ),

                const SizedBox(height: 17),

                Text(
                  title,
                  style: const TextStyle(
                    color: SkrivaDashColors.dark,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SkrivaDashColors.dark,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// ANIMATED PROGRESS DIAGRAM
// =====================================================

class SkrivaProgressDiagram extends StatelessWidget {
  final int percent;
  final int completed;
  final int total;

  const SkrivaProgressDiagram({
    super.key,
    required this.percent,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final target = (percent / 100).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: target,
      ),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 138,
          height: 138,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(138, 138),
                painter: _ProgressRingPainter(value),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(value * 100).round()}%',
                    style: const TextStyle(
                      color: SkrivaDashColors.blue,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  Text(
                    '$completed / $total',
                    style: const TextStyle(
                      color: SkrivaDashColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;

  const _ProgressRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2 - 12;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFDDE9EF)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          SkrivaDashColors.blue,
          SkrivaDashColors.softBlue,
          SkrivaDashColors.lime,
          SkrivaDashColors.blue,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      )
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        -math.pi / 2,
        progress * math.pi * 2,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _ProgressRingPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress;
  }
}

// =====================================================
// SHARED BOTTOM NAVIGATION
// =====================================================

class SkrivaDashboardNav extends StatelessWidget {
  final List<NavigationDestination> destinations;
  final ValueChanged<int> onSelected;

  const SkrivaDashboardNav({
    super.key,
    required this.destinations,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 72,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: SkrivaDashColors.lime,
      labelBehavior:
          NavigationDestinationLabelBehavior.alwaysShow,
      selectedIndex: 0,
      onDestinationSelected: onSelected,
      destinations: destinations,
    );
  }
}
