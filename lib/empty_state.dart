import 'package:flutter/material.dart';

/// Tampilan kosong yang bisa dipakai di semua halaman,
/// contoh: belum ada dokumen, checklist kosong, belum ada revisi.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.folder_open_rounded,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF694A47);
    const darkPrimary = Color(0xFF523B39);
    const orange = Color(0xFF96C1C5);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 44,
                color: orange,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkPrimary,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}