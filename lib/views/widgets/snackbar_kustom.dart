import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarKustom {
  static void sukses(String title, String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      maxWidth: 400,
      backgroundColor: Color(0xFF22C55E).withValues(alpha: 0.95),
      colorText: Colors.white,
      icon: Icon(Icons.check_circle, color: Colors.white),
      margin: EdgeInsets.only(
        bottom: 20,
        right: 20,
        left: Get.width > 440 ? Get.width - 420 : 20,
      ),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      animationDuration: Duration(milliseconds: 500),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  static void error(String title, String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      maxWidth: 400,
      backgroundColor: Color(0xFFEF4444).withValues(alpha: 0.95),
      colorText: Colors.white,
      icon: Icon(Icons.error_outline, color: Colors.white),
      margin: EdgeInsets.only(
        bottom: 20,
        right: 20,
        left: Get.width > 440 ? Get.width - 420 : 20,
      ),
      borderRadius: 8,
      duration: Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 500),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  static void info(String title, String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      maxWidth: 400,
      backgroundColor: Color(0xFF3B8266).withValues(alpha: 0.95),
      colorText: Colors.white,
      icon: Icon(Icons.info_outline, color: Colors.white),
      margin: EdgeInsets.only(
        bottom: 20,
        right: 20,
        left: Get.width > 440 ? Get.width - 420 : 20,
      ),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      animationDuration: Duration(milliseconds: 500),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  static void warning(String title, String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      maxWidth: 400,
      backgroundColor: Color(0xFFE59E0B).withValues(alpha: 0.95),
      colorText: Colors.white,
      icon: Icon(Icons.warning_amber_rounded, color: Colors.white),
      margin: EdgeInsets.only(
        bottom: 20,
        right: 20,
        left: Get.width > 440 ? Get.width - 420 : 20,
      ),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      animationDuration: Duration(milliseconds: 500),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }
}
