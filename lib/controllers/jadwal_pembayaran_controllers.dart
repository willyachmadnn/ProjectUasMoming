import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/jadwal_pembayaran_models.dart';
import '../models/transaksi_models.dart';
import '../services/jadwal_pembayaran_services.dart';
import '../services/transaksi_services.dart';
import '../views/widgets/snackbar_kustom.dart';

class KontrolerJadwalPembayaran extends GetxController {
  final LayananJadwalPembayaran _scheduleService;
  final LayananTransaksi _transactionService;

  KontrolerJadwalPembayaran({
    LayananJadwalPembayaran? scheduleService,
    LayananTransaksi? transactionService,
  })  : _scheduleService = scheduleService ?? LayananJadwalPembayaran(),
        _transactionService = transactionService ?? LayananTransaksi();

  final RxList<ModelJadwalPembayaran> allSchedules = <ModelJadwalPembayaran>[].obs;
  final RxList<ModelJadwalPembayaran> filteredSchedules = <ModelJadwalPembayaran>[].obs;

  final RxBool isSearchOpen = false.obs;
  final RxString searchQuery = ''.obs;

  final Rx<DateTimeRange> selectedDateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
  ).obs;

  @override
  void onInit() {
    super.onInit();
    _bindSchedules();

    everAll([
      allSchedules,
      searchQuery,
      selectedDateRange,
    ], (_) => _applyFilters());
  }

  void _bindSchedules() {
    allSchedules.bindStream(_scheduleService.getSchedules());
  }

  void toggleSearch() {
    isSearchOpen.value = !isSearchOpen.value;
    if (!isSearchOpen.value) {
      searchQuery.value = '';
    }
  }

  void _applyFilters() {
    List<ModelJadwalPembayaran> temp = allSchedules.toList();

    temp = temp.where((s) {
      final start = DateTime(
        selectedDateRange.value.start.year,
        selectedDateRange.value.start.month,
        selectedDateRange.value.start.day,
      );
      final end = DateTime(
        selectedDateRange.value.end.year,
        selectedDateRange.value.end.month,
        selectedDateRange.value.end.day,
        23, 59, 59,
      );
      return s.dueDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
          s.dueDate.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();

    if (searchQuery.value.isNotEmpty) {
      temp = temp
          .where((s) => s.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    temp.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    filteredSchedules.assignAll(temp);
  }

  Future<void> addSchedule(ModelJadwalPembayaran schedule) async {
    try {
      await _scheduleService.addSchedule(schedule);
      SnackbarKustom.sukses('Sukses', 'Jadwal berhasil ditambahkan');
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal menambahkan jadwal: $e');
    }
  }

  Future<void> updateSchedule(ModelJadwalPembayaran schedule) async {
    try {
      await _scheduleService.updateSchedule(schedule);
      SnackbarKustom.sukses('Sukses', 'Jadwal berhasil diperbarui');
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal memperbarui jadwal: $e');
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      await _scheduleService.deleteSchedule(id);
      SnackbarKustom.sukses('Sukses', 'Jadwal berhasil dihapus');
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal menghapus jadwal: $e');
    }
  }

  Future<void> markAsPaid(ModelJadwalPembayaran schedule) async {
    if (schedule.isPaid) return;

    try {
      await _scheduleService.markAsPaid(schedule.id, true);

      final transaction = ModelTransaksi(
        id: '',
        uid: FirebaseAuth.instance.currentUser?.uid ?? '',
        description: 'Pembayaran Tagihan: ${schedule.name}',
        amount: schedule.amount,
        category: schedule.category ?? 'Tagihan',
        type: 'expense',
        date: DateTime.now(),
        isExpense: true,
      );
      await _transactionService.addTransaction(transaction);

      SnackbarKustom.sukses('Lunas', 'Tagihan ditandai lunas & tercatat di transaksi');
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal memproses pembayaran: $e');
    }
  }
}