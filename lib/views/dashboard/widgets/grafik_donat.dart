import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/beranda_controllers.dart';

class GrafikDonat extends StatelessWidget {
  final Map<String, double> data;
  final double total;

  const GrafikDonat({super.key, required this.data, required this.total});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KontrolerBeranda>();
    final fullCurrencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    var sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    var top5Entries = sortedEntries.take(5).toList();
    List<Color> colors = [
      Colors.blue,
      Colors.amber,
      Colors.green,
      Colors.red,
      Colors.purple,
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Obx(() {
                  return PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // LOGIKA LEPAS: Jika jari diangkat (TapUp/PanEnd), sembunyikan info
                          if (event is FlTapUpEvent ||
                              event is FlPanEndEvent ||
                              event is FlPanCancelEvent ||
                              event is FlLongPressEnd) {
                            controller.touchedIndexDonut.value = -1;
                            return;
                          }

                          // LOGIKA SENTUH: Update info jika sedang menyentuh
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
                        final isTouched =
                            i == controller.touchedIndexDonut.value;
                        final radius = isTouched ? 25.0 : 18.0;
                        return PieChartSectionData(
                          color: colors[i % colors.length],
                          value: top5Entries[i].value,
                          title: '',
                          radius: radius,
                        );
                      }),
                    ),
                  );
                }),
                Obx(() {
                  final index = controller.touchedIndexDonut.value;
                  if (index != -1 && index < top5Entries.length) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            top5Entries[index].key,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            child: Text(
                              fullCurrencyFormat.format(
                                top5Entries[index].value,
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Icon(
                      Icons.touch_app,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                      size: 24,
                    );
                  }
                }),
              ],
            ),
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
                Text(
                  fullCurrencyFormat.format(total),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
