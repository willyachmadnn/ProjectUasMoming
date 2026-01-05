import 'dart:async';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/beranda_services.dart';
import '../models/transaksi_models.dart';
import '../models/jadwal_pembayaran_models.dart';
import '../models/tabungan_models.dart';

class KontrolerBeranda extends GetxController {
  final LayananBeranda _service;

  KontrolerBeranda({LayananBeranda? service})
      : _service = service ?? LayananBeranda();
  final RxList<ModelTransaksi> allTransactions = <ModelTransaksi>[].obs;
  final RxList<ModelTransaksi> recentTransactions = <ModelTransaksi>[].obs;
  final RxList<ModelJadwalPembayaran> upcomingSchedules = <ModelJadwalPembayaran>[].obs;
  final RxList<ModelTabungan> savingsGoals = <ModelTabungan>[].obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;
  final RxDouble totalBalance = 0.0.obs;
  final RxDouble totalSavingsCurrent = 0.0.obs;
  final RxDouble totalSavingsTarget = 0.0.obs;
  final RxDouble trendPercentage = 0.0.obs;
  final RxBool isTrendUp = true.obs;
  final RxDouble budgetLimit = 10000000.0.obs;

  final RxMap<String, double> categoryStats = <String, double>{}.obs;
  final RxList<FlSpot> incomeSpots = <FlSpot>[].obs;
  final RxList<FlSpot> expenseSpots = <FlSpot>[].obs;
  final RxDouble maxChartY = 1000.0.obs;
  var touchedIndexLine = (-1).obs;
  var touchedIndexDonut = (-1).obs;

  StreamSubscription? _transactionSubscription;

  @override
  void onInit() {
    super.onInit();
    bindStreams();
  }

  @override
  void onClose() {
    _transactionSubscription?.cancel();
    super.onClose();
  }

  void bindStreams() {
    upcomingSchedules.bindStream(_service.getUpcomingSchedules());
    savingsGoals.bindStream(_service.getSavingsGoals());

    ever(savingsGoals, (List<ModelTabungan> goals) {
      double current = 0;
      double target = 0;
      for (var item in goals) {
        current += item.currentAmount;
        target += item.targetAmount;
      }
      totalSavingsCurrent.value = current;
      totalSavingsTarget.value = target;
    });

    _transactionSubscription?.cancel();
    _transactionSubscription = _service.getAllTransactions().listen((transactions) {
      transactions.sort((a, b) => b.date.compareTo(a.date));
      allTransactions.value = transactions;
      recentTransactions.value = transactions.take(5).toList();
      _calculateFinancials(transactions);
      _calculateCharts(transactions);
    });
  }

  void _calculateFinancials(List<ModelTransaksi> transactions) {
    final now = DateTime.now();
    final startOfThisMonth = DateTime(now.year, now.month, 1);

    final thisMonthTransactions = transactions
        .where((tx) => tx.date.isAfter(startOfThisMonth.subtract(const Duration(seconds: 1))))
        .toList();

    final previousTransactions = transactions
        .where((tx) => tx.date.isBefore(startOfThisMonth))
        .toList();

    double currentMonthIncome = 0;
    double currentMonthExpense = 0;
    for (var tx in thisMonthTransactions) {
      if (tx.isExpense) {
        currentMonthExpense += tx.amount;
      } else {
        currentMonthIncome += tx.amount;
      }
    }

    totalIncome.value = currentMonthIncome;
    totalExpense.value = currentMonthExpense;
    totalBalance.value = currentMonthIncome - currentMonthExpense;

    double prevIncome = 0;
    double prevExpense = 0;
    for (var tx in previousTransactions) {
      if (tx.isExpense) {
        prevExpense += tx.amount;
      } else {
        prevIncome += tx.amount;
      }
    }
    double prevBalance = prevIncome - prevExpense;

    if (prevBalance == 0) {
      trendPercentage.value = totalBalance.value > 0 ? 100.0 : 0.0;
    } else {
      trendPercentage.value = ((totalBalance.value - prevBalance) / prevBalance.abs()) * 100;
    }
    isTrendUp.value = trendPercentage.value >= 0;
    if (currentMonthIncome > 0) {
      budgetLimit.value = currentMonthIncome;
    } else {
      budgetLimit.value = 1000000.0;
    }
  }

  void _calculateCharts(List<ModelTransaksi> transactions) {
    final now = DateTime.now();
    final thisMonthTransactions = transactions
        .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
        .toList();

    Map<String, double> catStats = {};
    for (var tx in thisMonthTransactions) {
      if (tx.isExpense) {
        catStats[tx.category] = (catStats[tx.category] ?? 0) + tx.amount;
      }
    }
    categoryStats.value = catStats;

    Map<int, double> dailyIncome = {};
    Map<int, double> dailyExpense = {};
    int limitDay = now.day;

    for (int i = 1; i <= limitDay; i++) {
      dailyIncome[i] = 0.0;
      dailyExpense[i] = 0.0;
    }

    for (var tx in thisMonthTransactions) {
      int day = tx.date.day;
      if (day <= limitDay) {
        if (tx.isExpense) {
          dailyExpense[day] = (dailyExpense[day] ?? 0) + tx.amount;
        } else {
          dailyIncome[day] = (dailyIncome[day] ?? 0) + tx.amount;
        }
      }
    }

    List<FlSpot> incSpots = [];
    List<FlSpot> expSpots = [];
    double maxY = 0;

    for (int i = 1; i <= limitDay; i++) {
      double inc = dailyIncome[i] ?? 0;
      double exp = dailyExpense[i] ?? 0;

      if (inc > maxY) maxY = inc;
      if (exp > maxY) maxY = exp;

      incSpots.add(FlSpot(i.toDouble(), inc));
      expSpots.add(FlSpot(i.toDouble(), exp));
    }

    incomeSpots.value = incSpots;
    expenseSpots.value = expSpots;
    maxChartY.value = maxY == 0 ? 1000 : maxY * 1.2;
  }
}