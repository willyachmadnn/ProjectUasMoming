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
  }) : _scheduleService = scheduleService ?? LayananJadwalPembayaran(),
       _transactionService = transactionService ?? LayananTransaksi();

  // Reactive State
  final RxList<ModelJadwalPembayaran> allSchedules =
      <ModelJadwalPembayaran>[].obs;
  final RxList<ModelJadwalPembayaran> filteredSchedules =
      <ModelJadwalPembayaran>[].obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'Semua'.obs; // 'Semua', 'Lunas', 'Belum Lunas'
  final Rx<DateTime> monthFilter = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _bindSchedules();

    // Listen to filter changes
    everAll([
      allSchedules,
      searchQuery,
      statusFilter,
      monthFilter,
    ], (_) => _applyFilters());
  }

  void _bindSchedules() {
    allSchedules.bindStream(_scheduleService.getSchedules());
  }

  void _applyFilters() {
    List<ModelJadwalPembayaran> temp = allSchedules.toList();

    // 1. Month Filter
    temp = temp.where((s) {
      return s.dueDate.year == monthFilter.value.year &&
          s.dueDate.month == monthFilter.value.month;
    }).toList();

    // 2. Status Filter
    if (statusFilter.value == 'Lunas') {
      temp = temp.where((s) => s.isPaid).toList();
    } else if (statusFilter.value == 'Belum Lunas') {
      temp = temp.where((s) => !s.isPaid).toList();
    }

    // 3. Search Filter
    if (searchQuery.value.isNotEmpty) {
      temp = temp
          .where(
            (s) =>
                s.name.toLowerCase().contains(searchQuery.value.toLowerCase()),
          )
          .toList();
    }

    filteredSchedules.assignAll(temp);
  }

  // CRUD Actions
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
      // 1. Update Schedule Status
      await _scheduleService.markAsPaid(schedule.id, true);

      // 2. Add to Transactions
      final transaction = ModelTransaksi(
        id: '', // Auto-generated
        uid: FirebaseAuth.instance.currentUser?.uid ?? '',
        description: 'Pembayaran Tagihan: ${schedule.name}',
        amount: schedule.amount,
        category: schedule.category ?? 'Tagihan',
        type: 'expense',
        date: DateTime.now(),
        isExpense: true,
      );
      await _transactionService.addTransaction(transaction);

      SnackbarKustom.sukses(
        'Lunas',
        'Tagihan ditandai lunas & tercatat di transaksi',
      );
    } catch (e) {
      SnackbarKustom.error('Error', 'Gagal memproses pembayaran: $e');
    }
  }
}
