import 'package:get/get.dart';
import 'package:flutter/material.dart';

class KontrolerAplikasi extends GetxController {
  final RxInt activeMenuIndex = 0.obs;
  final RxString selectedDateFilter = 'Hari Ini'.obs;
  final RxDouble totalPayment = 0.0.obs;
  final RxBool isDarkMode = false.obs;

  void changeMenu(int index) {
    activeMenuIndex.value = index;
  }

  void updateDateFilter(String value) {
    selectedDateFilter.value = value;
  }

  void updatePayment(double amount) {
    totalPayment.value = amount;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
