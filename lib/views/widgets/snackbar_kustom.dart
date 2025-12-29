import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarKustom {
  static void sukses(String judul, String pesan) {
    _tampilkan(judul, pesan, Colors.green[600]!, Icons.check_circle_outline);
  }

  static void error(String judul, String pesan) {
    _tampilkan(judul, pesan, Colors.red[600]!, Icons.error_outline);
  }

  static void info(String judul, String pesan) {
    _tampilkan(judul, pesan, Colors.blue[600]!, Icons.info_outline);
  }

  static void _tampilkan(
    String judul,
    String pesan,
    Color warna,
    IconData icon,
  ) {
    // Custom Overlay for Fade Effect (No Slide)
    final overlayState = Overlay.of(Get.overlayContext!);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: _FadeSnackbar(
            judul: judul,
            pesan: pesan,
            warna: warna,
            icon: icon,
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    // Remove after duration
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _FadeSnackbar extends StatefulWidget {
  final String judul;
  final String pesan;
  final Color warna;
  final IconData icon;

  const _FadeSnackbar({
    required this.judul,
    required this.pesan,
    required this.warna,
    required this.icon,
  });

  @override
  _FadeSnackbarState createState() => _FadeSnackbarState();
}

class _FadeSnackbarState extends State<_FadeSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Fade In duration
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    // Start fade out before disposal
    Future.delayed(const Duration(seconds: 3, milliseconds: 500), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.warna,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.judul,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.pesan,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
