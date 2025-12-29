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
    // Bind Transactions
    recentTransactions.bindStream(_service.getRecentTransactions());

    // Bind Payment Schedules
    upcomingSchedules.bindStream(_service.getUpcomingSchedules());

    // Bind Savings
    savingsGoals.bindStream(_service.getSavingsGoals());

    // Bind Summary
    _summarySubscription?.cancel();
    _summarySubscription = _service.getFinancialSummary().listen((summary) {
      totalIncome.value = summary['income'] ?? 0.0;
      totalExpense.value = summary['expense'] ?? 0.0;
      totalBalance.value = summary['balance'] ?? 0.0;
      
      // Update Budget Limit to match Total Income
      // As per user requirement: "status anggaran totalnya menyesuaikan dengan input pemasukan"
      if (totalIncome.value > 0) {
        budgetLimit.value = totalIncome.value;
      } else {
         // Default fallback if no income, or keep it 0
         budgetLimit.value = 0; 
      }
    });

    // Bind Monthly Stats
    monthlyStats.bindStream(_service.getThreeMonthsStats());

    // Bind Budget Limit
    budgetLimit.bindStream(_service.getBudgetLimit());
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
