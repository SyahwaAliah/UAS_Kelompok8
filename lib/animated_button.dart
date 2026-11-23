import 'package:flutter/material.dart';
import 'jadwal_theme.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color color;

  const AnimatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color = JadwalColors.olive,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool sedangDitekan = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => sedangDitekan = true),
      onTapCancel: () => setState(() => sedangDitekan = false),
      onTapUp: (_) => setState(() => sedangDitekan = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: sedangDitekan ? 13 : 16),
        decoration: BoxDecoration(
          color: sedangDitekan ? widget.color.withOpacity(0.82) : widget.color,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.18),
              blurRadius: sedangDitekan ? 3 : 9,
              offset: Offset(0, sedangDitekan ? 1 : 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              widget.text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
