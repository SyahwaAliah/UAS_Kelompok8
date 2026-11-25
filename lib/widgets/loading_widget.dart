import 'package:flutter/material.dart';

/// Loading di tengah halaman, dipakai saat mengambil data
/// (contoh: membaca daftar dokumen atau data sqflite).
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF694A47);
    const darkPrimary = Color(0xFF523B39);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(20),
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
            child: const CircularProgressIndicator(
              color: primary,
              strokeWidth: 3,
            ),
          ),

          if (message != null) ...[
            const SizedBox(height: 16),

            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Loading yang menutupi layar, dipakai saat menyimpan data
/// (contoh: menyimpan dokumen atau profil).
///
/// Pemakaian:
///   LoadingOverlay.show(context, message: 'Menyimpan...');
///   await proses();
///   LoadingOverlay.hide(context);
class LoadingOverlay {
  LoadingOverlay._();

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
        return PopScope(canPop: false, child: LoadingWidget(message: message));
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
