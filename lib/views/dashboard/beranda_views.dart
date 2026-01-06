import 'package:financial/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/beranda_controllers.dart';
import '../widgets/drawer_kustom.dart';
import '../widgets/app_bar_kustom.dart';
import 'widgets/grafik_donat.dart';
import 'widgets/grafik_line.dart';
import 'widgets/grafik_batang_tabungan.dart';

class TampilanBeranda extends StatelessWidget {
  const TampilanBeranda({super.key});

  @override
  Widget build(BuildContext context) {
    final KontrolerBeranda controller = Get.put(KontrolerBeranda());
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                                color: Theme.of(context).hintColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                            const SizedBox(height: 12),
                            Obx(
                              () => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (controller.isTrendUp.value
                                              ? AppTheme.success
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.error)
                                          .withValues(alpha: 0.1),
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
                                          ? AppTheme.success
                                          : Theme.of(context).colorScheme.error,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${controller.trendPercentage.value.toStringAsFixed(1)}% bulan lalu",
                                      style: TextStyle(
                                        color: controller.isTrendUp.value
                                            ? AppTheme.success
                                            : Theme.of(
                                                context,
                                              ).colorScheme.error,
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
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Expanded(
                            child: _buildSmallCard(
                              context,
                              "Pemasukan",
                              controller.totalIncome,
                              AppTheme.info,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _buildSmallCard(
                              context,
                              "Pengeluaran",
                              controller.totalExpense,
                              AppTheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tabungan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Icon(
                          Icons.savings,
                          color: Theme.of(
                            context,
                          ).hintColor.withValues(alpha: 0.3),
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Obx(() {
                      if (controller.savingsGoals.isEmpty) {
                        return const Text("Belum ada target tabungan");
                      }
                      return const SizedBox(
                        height: 50,
                        child: GrafikBatangTabungan(),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(height: 200, child: const GrafikDonat()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(height: 200, child: const GrafikLine()),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Jadwal Pembayaran",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 75,
                      child: Obx(() {
                        if (controller.upcomingSchedules.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 40,
                                  color: Theme.of(context).disabledColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Tidak ada tagihan mendatang",
                                  style: TextStyle(
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.upcomingSchedules.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = controller.upcomingSchedules[index];
                            final isOverdue =
                                item.dueDate.isBefore(DateTime.now()) &&
                                !item.isPaid;

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isOverdue
                                      ? Theme.of(context).colorScheme.error
                                            .withValues(alpha: 0.1)
                                      : Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: isOverdue
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat(
                                  'EEEE, dd MMM yyyy',
                                  'id_ID',
                                ).format(item.dueDate),
                                style: TextStyle(
                                  color: isOverdue
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).hintColor,
                                  fontSize: 12,
                                  fontWeight: isOverdue
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: Text(
                                fullCurrencyFormat.format(item.amount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCard(
    BuildContext context,
    String title,
    RxDouble value,
    Color color,
  ) {
    final fullFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          const SizedBox(height: 4),
          Obx(
            () => Text(
              fullFormat.format(value.value),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
