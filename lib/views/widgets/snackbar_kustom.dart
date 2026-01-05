import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class SnackbarKustom {
  static OverlayEntry? _activeEntry;
  static Timer? _activeTimer;

  static void _show({
    required String title,
    required String message,
    required Color color,
    required IconData icon,
    int durationSeconds = 3,
  }) {
    if (_activeEntry != null) {
      _activeEntry?.remove();
      _activeTimer?.cancel();
      _activeEntry = null;
    }

    final overlayState = Get.overlayContext != null
        ? Overlay.of(Get.overlayContext!)
        : null;

    if (overlayState == null) return;

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

    overlayState.insert(_activeEntry!);
  }

  static void sukses(String title, String message) {
    _show(
      title: title,
      message: message,
      color: const Color(0xFF22C55E),
      icon: Icons.check_circle,
      durationSeconds: 3,
    );
  }

  static void error(String title, String message) {
    _show(
      title: title,
      message: message,
      color: const Color(0xFFEF4444),
      icon: Icons.error_outline,
      durationSeconds: 4,
    );
  }

  static void info(String title, String message) {
    _show(
      title: title,
      message: message,
      color: const Color(0xFF3B8266),
      icon: Icons.info_outline,
      durationSeconds: 3,
    );
  }

  static void warning(String title, String message) {
    _show(
      title: title,
      message: message,
      color: const Color(0xFFE59E0B),
      icon: Icons.warning_amber_rounded,
      durationSeconds: 3,
    );
  }
}

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
    );

    _opacityAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();

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
    final double leftMargin = Get.width * 0.5;

    return Positioned(
      bottom: 20,
      right: 16,
      left: leftMargin,
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