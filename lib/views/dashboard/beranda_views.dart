import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/beranda_controllers.dart';
import '../widgets/drawer_kustom.dart';
import '../widgets/app_bar_kustom.dart';
import 'widgets/grafik_donat.dart';
import 'widgets/grafik_line.dart';

class TampilanBeranda extends StatelessWidget {
  const TampilanBeranda({super.key});

  @override
  Widget build(BuildContext context) {
    final KontrolerBeranda controller = Get.put(KontrolerBeranda());

    // 1. Definisikan Format Rupiah Penuh
    final fullCurrencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarKustom(),
      drawer: DrawerKustom(),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.bindStreams();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. BAGIAN HEADER (SPLIT LAYOUT) ---
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // KIRI: TOTAL SALDO
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Total Saldo',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 8),
                            Obx(
                              () => Text(
                                fullCurrencyFormat.format(
                                  controller.totalBalance.value,
                                ),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Obx(
                              () => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (controller.isTrendUp.value
                                              ? Colors.green
                                              : Colors.red)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      controller.isTrendUp.value
                                          ? Icons.arrow_outward
                                          : Icons.arrow_downward,
                                      color: controller.isTrendUp.value
                                          ? Colors.green
                                          : Colors.red,
                                      size: 12,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "${controller.trendPercentage.value.toStringAsFixed(1)}% bulan lalu",
                                      style: TextStyle(
                                        color: controller.isTrendUp.value
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    // KANAN: INCOME & EXPENSE
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Expanded(
                            child: _buildSmallCard(
                              context,
                              "Pemasukan",
                              controller.totalIncome,
                              Colors.blue,
                            ),
                          ),
                          SizedBox(height: 12),
                          Expanded(
                            child: _buildSmallCard(
                              context,
                              "Pengeluaran",
                              controller.totalExpense,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // --- 2. STATUS ANGGARAN (Full Width) ---
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Status Anggaran",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 15),
                    Obx(() {
                      double limit = controller.budgetLimit.value;
                      double used = controller.totalExpense.value;
                      double percentage = limit == 0
                          ? 0
                          : (used / limit).clamp(0.0, 1.0);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: percentage,
                              minHeight: 12,
                              backgroundColor: Colors.grey.withOpacity(0.1),
                              color: percentage > 0.9
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          SizedBox(height: 8),
                          // --- PERBAIKAN DI SINI (Status Anggaran Full Format) ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${fullCurrencyFormat.format(used)} terpakai',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'dari ${fullCurrencyFormat.format(limit)}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // --- 3. GRAFIK SEJAJAR ---
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: Obx(
                        () => GrafikDonat(
                          data: controller.categoryStats,
                          total: controller.totalExpense.value,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: Obx(
                        () => GrafikLine(
                          incomeSpots: controller.incomeSpots,
                          expenseSpots: controller.expenseSpots,
                          maxY: controller.maxChartY.value,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- PERBAIKAN DI SINI (Kartu Kecil Full Format) ---
  Widget _buildSmallCard(
    BuildContext context,
    String title,
    RxDouble value,
    Color color,
  ) {
    // Gunakan format currency penuh
    final fullFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 10,
            ),
          ),
          SizedBox(height: 4),
          Obx(
            () => Text(
              fullFormat.format(value.value),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ), // Font sedikit dikecilkan agar muat
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
