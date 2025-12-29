import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/beranda_controllers.dart';
import '../widgets/drawer_kustom.dart';
import '../widgets/app_bar_kustom.dart';
import 'widgets/grafik_analisis_keuangan.dart';
import 'widgets/kartu_jadwal_pembayaran.dart';
import 'widgets/kartu_target_tabungan.dart';
import 'widgets/tabel_transaksi_terbaru.dart';

class TampilanBeranda extends StatelessWidget {
  const TampilanBeranda({super.key});

  @override
  Widget build(BuildContext context) {
    final KontrolerBeranda controller = Get.isRegistered<KontrolerBeranda>()
        ? Get.find<KontrolerBeranda>()
        : Get.put(KontrolerBeranda());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarKustom(title: 'Beranda'),
      drawer: DrawerKustom(),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.bindStreams();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0), // Generous padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Section: Financial Overview & Budget Status (Unified Card)
              _buildTopSection(context, controller),

              SizedBox(height: 20),

              // 2. Bottom Section: Split View
              LayoutBuilder(
                builder: (context, constraints) {
                  // Desktop / Tablet Landscape
                  if (constraints.maxWidth > 900) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Column: Financial Analysis (35%)
                          Expanded(
                            flex: 35,
                            child: Obx(
                              () => GrafikAnalisisKeuangan(
                                data: controller.expensesByCategory,
                                totalIncome: controller.totalIncome.value,
                                totalExpense: controller.totalExpense.value,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          // Right Column: Bills, Savings, Transactions (65%)
                          Expanded(
                            flex: 65,
                            child: Column(
                              children: [
                                // Bills and Savings Row
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Obx(
                                          () => KartuJadwalPembayaran(
                                            schedules: controller
                                                .upcomingSchedules
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: Obx(
                                          () => KartuTargetTabungan(
                                            goals: controller.savingsGoals
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Recent Transactions
                                Obx(
                                  () => TabelTransaksiTerbaru(
                                    transactions: controller.recentTransactions
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  // Tablet Portrait / Mobile
                  else {
                    return Column(
                      children: [
                        Obx(
                          () => GrafikAnalisisKeuangan(
                            data: controller.expensesByCategory,
                            totalIncome: controller.totalIncome.value,
                            totalExpense: controller.totalExpense.value,
                          ),
                        ),
                        SizedBox(height: 20),
                        Obx(
                          () => KartuJadwalPembayaran(
                            schedules: controller.upcomingSchedules.toList(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Obx(
                          () => KartuTargetTabungan(
                            goals: controller.savingsGoals.toList(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Obx(
                          () => TabelTransaksiTerbaru(
                            transactions: controller.recentTransactions
                                .toList(),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context, KontrolerBeranda controller) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Keuangan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              // Menu: Akun placeholder if needed, usually in AppBar
            ],
          ),
          SizedBox(height: 24),

          // Stats Row
          LayoutBuilder(
            builder: (context, constraints) {
              bool isSmall = constraints.maxWidth < 600;

              if (isSmall) {
                return Column(
                  children: [
                    Obx(
                      () => _buildStatItem(
                        context,
                        'Total Saldo',
                        controller.totalBalance.value,
                        isBig: true,
                      ),
                    ),
                    SizedBox(height: 16),
                    Obx(
                      () => _buildStatItem(
                        context,
                        'Pemasukan',
                        controller.totalIncome.value,
                      ),
                    ),
                    SizedBox(height: 16),
                    Obx(
                      () => _buildStatItem(
                        context,
                        'Pengeluaran',
                        controller.totalExpense.value,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(
                      () => _buildStatItem(
                        context,
                        'Total Saldo',
                        controller.totalBalance.value,
                        isBig: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Obx(
                      () => _buildStatItem(
                        context,
                        'Pemasukan',
                        controller.totalIncome.value,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Obx(
                      () => _buildStatItem(
                        context,
                        'Pengeluaran',
                        controller.totalExpense.value,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 32),

          // Budget Status Section
          Text(
            'Status Anggaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 12),
          Obx(() {
            double limit = controller.budgetLimit.value;
            double used = controller.totalExpense.value;
            double percentage = limit == 0 ? 0 : (used / limit).clamp(0.0, 1.0);
            double remaining = limit - used;

            final currencyFormat = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 12,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4CAF50),
                    ), // Green
                  ),
                ),
                SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: currencyFormat.format(remaining),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      TextSpan(
                        text: ' tersisa dari ${currencyFormat.format(limit)}',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    double amount, {
    bool isBig = false,
  }) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              currencyFormat.format(amount),
              style: TextStyle(
                fontSize: isBig ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: isBig
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
