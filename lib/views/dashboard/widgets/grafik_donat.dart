import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/beranda_controllers.dart';
import '../../../theme/app_theme.dart';

class GrafikDonat extends StatelessWidget {
  // Constructor jadi kosong (const)
  const GrafikDonat({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KontrolerBeranda>();
    final fullCurrencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    List<Color> colors = [
      Theme.of(context).primaryColor,
      AppTheme.warning,
      AppTheme.success,
      Theme.of(context).colorScheme.error,
      AppTheme.chartPurple,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengeluaran Per Kategori',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            // OBX DISINI MENANGANI DATA & SENTUHAN
            child: Obx(() {
              // 1. Ambil data REAKTIF di dalam Obx
              final data = controller.categoryStats; // RxMap
              final touchedIndex = controller.touchedIndexDonut.value; // RxInt

              // 2. Olah data
              var sortedEntries = data.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              var top5Entries = sortedEntries.take(5).toList();

              return Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          if (event is FlTapUpEvent ||
                              event is FlPanEndEvent ||
                              event is FlPanCancelEvent ||
                              event is FlLongPressEnd) {
                            controller.touchedIndexDonut.value = -1;
                            return;
                          }
                          if (event is FlTapDownEvent ||
                              event is FlPanDownEvent ||
                              event is FlPanUpdateEvent) {
                            if (pieTouchResponse != null &&
                                pieTouchResponse.touchedSection != null) {
                              controller.touchedIndexDonut.value =
                                  pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                            }
                          }
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: List.generate(top5Entries.length, (i) {
                        final isTouched = i == touchedIndex;
                        final radius = isTouched ? 25.0 : 18.0;
                        return PieChartSectionData(
                          color: colors[i % colors.length],
                          value: top5Entries[i].value,
                          title: '',
                          radius: radius,
                        );
                      }),
                    ),
                  ),
                  if (touchedIndex != -1 && touchedIndex < top5Entries.length)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            top5Entries[touchedIndex].key,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            child: Text(
                              fullCurrencyFormat.format(
                                top5Entries[touchedIndex].value,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Icon(
                      Icons.touch_app,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                      size: 24,
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Total Pengeluaran",
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                Obx(
                  () => Text(
                    fullCurrencyFormat.format(controller.totalExpense.value),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
