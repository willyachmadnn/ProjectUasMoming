import 'dart:async';
import 'package:get/get.dart';
import '../services/beranda_services.dart';
import '../models/transaksi_models.dart';
import '../models/jadwal_pembayaran_models.dart';
import '../models/tabungan_models.dart';

class KontrolerBeranda extends GetxController {
  final LayananBeranda _service;

  KontrolerBeranda({LayananBeranda? service})
    : _service = service ?? LayananBeranda();

  // Reactive Variables
  final RxList<ModelTransaksi> recentTransactions = <ModelTransaksi>[].obs;
  final RxList<ModelJadwalPembayaran> upcomingSchedules =
      <ModelJadwalPembayaran>[].obs;
  final RxList<ModelTabungan> savingsGoals = <ModelTabungan>[].obs;
  final RxList<Map<String, dynamic>> monthlyStats =
      <Map<String, dynamic>>[].obs;

  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxDouble totalBalance = 0.0.obs;

  // Budget
  final RxDouble budgetLimit = 10000000.0.obs;

  // --- TAMBAHAN BARU: Variabel untuk Pie Chart ---
  // Kita simpan data kategori di sini, bukan hitung on-the-fly dari recentTransactions
  final RxMap<String, double> categoryStats = <String, double>{}.obs;

  StreamSubscription? _summarySubscription;

  @override
  void onInit() {
    super.onInit();
    bindStreams();
  }

  @override
  void onClose() {
    _summarySubscription?.cancel();
    super.onClose();
  }

  void bindStreams() {
    // 1. Bind Transaksi Terakhir (List View)
    recentTransactions.bindStream(_service.getRecentTransactions());

    // 2. Bind Jadwal & Tabungan
    upcomingSchedules.bindStream(_service.getUpcomingSchedules());
    savingsGoals.bindStream(_service.getSavingsGoals());

    // 3. Bind Summary & Hitung Ulang Kategori (Pie Chart)
    _summarySubscription?.cancel();

    // Perhatikan: Kita butuh stream yang membawa SELURUH data transaksi untuk hitung kategori
    // Jika getFinancialSummary di service hanya return angka, kita perlu ubah strategi.
    // TAPI, untuk solusi cepat tanpa ubah banyak service, kita gunakan listener ini:

    _summarySubscription = _service.getFinancialSummary().listen((summary) {
      totalIncome.value = (summary['income'] ?? 0.0).toDouble();
      totalExpense.value = (summary['expense'] ?? 0.0).toDouble();
      totalBalance.value = (summary['balance'] ?? 0.0).toDouble();

      // Update Budget: Budget = Total Pemasukan
      if (totalIncome.value > 0) {
        budgetLimit.value = totalIncome.value;
      } else {
        budgetLimit.value = 0;
      }
    });
  }

  // Derived Getters
  double get budgetUsedPercentage =>
      budgetLimit.value == 0 ? 0 : (totalExpense.value / budgetLimit.value);

  Map<String, double> get expensesByCategory {
    Map<String, double> categories = {};
    for (var tx in recentTransactions) {
      if (tx.isExpense) {
        categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
      }
    }
    return categories;
  }
}
