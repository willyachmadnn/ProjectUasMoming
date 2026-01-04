import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class SnackbarKustom {
  // Variabel untuk menyimpan notifikasi yang sedang aktif
  // agar bisa ditutup otomatis jika ada notifikasi baru masuk (mencegah tumpuk)
  static OverlayEntry? _activeEntry;
  static Timer? _activeTimer;

  static void _show({
    required String title,
    required String message,
    required Color color,
    required IconData icon,
    int durationSeconds = 3,
  }) {
    // 1. Tutup notifikasi sebelumnya jika masih ada
    if (_activeEntry != null) {
      _activeEntry?.remove();
      _activeTimer?.cancel();
      _activeEntry = null;
    }

    // 2. Ambil Overlay State dari GetX context
    final overlayState = Get.overlayContext != null
        ? Overlay.of(Get.overlayContext!)
        : null;

    if (overlayState == null) return;

    // 3. Buat Overlay Entry baru
    _activeEntry = OverlayEntry(
      builder: (context) => _FadeSnackbarWidget(
        title: title,
        message: message,
        backgroundColor: color,
        iconData: icon,
        duration: Duration(seconds: durationSeconds),
        onDismiss: () {
          _activeEntry?.remove();
          _activeEntry = null;
        },
      ),
    );

    // 4. Tampilkan ke layar
    overlayState.insert(_activeEntry!);
  }

  // --- PUBLIC METHODS (Cara Panggil Tetap Sama) ---

  static void sukses(String title, String message) {
    _show(
      title: title,
      message: message,
      color: const Color(0xFF22C55E), // Hijau
      icon: Icons.check_circle,
      durationSeconds: 3,
    );
  }

  static void error(String title, String message) {
    _show(
      title: title,
      message: message,
      color: const Color(0xFFEF4444), // Merah
      icon: Icons.error_outline,
      durationSeconds: 4,
    );
  }

  static void info(String title, String message) {
    _show(
      title: title,
      message: message,
      color: const Color(0xFF3B8266), // Teal/Hijau Tua
      icon: Icons.info_outline,
      durationSeconds: 3,
    );
  }

  static void warning(String title, String message) {
    _show(
      title: title,
      message: message,
      color: const Color(0xFFE59E0B), // Kuning/Oranye
      icon: Icons.warning_amber_rounded,
      durationSeconds: 3,
    );
  }
}

// --- WIDGET INTERNAL (Menangani Animasi Fade) ---
class _FadeSnackbarWidget extends StatefulWidget {
  final String title;
  final String message;
  final Color backgroundColor;
  final IconData iconData;
  final Duration duration;
  final VoidCallback onDismiss;

  const _FadeSnackbarWidget({
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.iconData,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_FadeSnackbarWidget> createState() => _FadeSnackbarWidgetState();
}

class _FadeSnackbarWidgetState extends State<_FadeSnackbarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    // Konfigurasi Animasi Fade In
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Kecepatan muncul
      reverseDuration: const Duration(milliseconds: 400), // Kecepatan hilang
    );

    _opacityAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // Jalankan animasi muncul (Fade In)
    _controller.forward();

    // Timer untuk otomatis menutup (Fade Out) setelah sekian detik
    _dismissTimer = Timer(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hitung margin kiri 50%
    final double leftMargin = Get.width * 0.5;

    return Positioned(
      bottom: 20,
      right: 16,
      left: leftMargin, // Ini memaksa ukuran 50% di kanan
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _opacityAnim,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.backgroundColor.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                // Shadow agar terlihat melayang & elegan
                BoxShadow(
                  color: widget.backgroundColor.withValues(alpha: 0.4),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.iconData, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      if (widget.title.isNotEmpty)
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      if (widget.title.isNotEmpty)
                        const SizedBox(height: 2),
                      // Pesan
                      Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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