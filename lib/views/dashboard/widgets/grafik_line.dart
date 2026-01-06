import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/beranda_controllers.dart';
import 'dart:math' as math;
import 'package:financial/theme/app_theme.dart';

class GrafikLine extends StatelessWidget {
  const GrafikLine({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KontrolerBeranda>();
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pemasukan vs Pengeluaran',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              final incomeSpots = controller.incomeSpots;
              final expenseSpots = controller.expenseSpots;
              final maxY = controller.maxChartY.value;
              final double bottomBuffer = maxY > 0 ? maxY * 0.15 : 100;
              double actualMinX = 1;
              double actualMaxX = 5;

              final allSpots = [...incomeSpots, ...expenseSpots];

              if (allSpots.isNotEmpty) {
                actualMinX = allSpots.map((e) => e.x).reduce(math.min);
                actualMaxX = allSpots.map((e) => e.x).reduce(math.max);

                if (actualMinX == actualMaxX) {
                  actualMaxX = actualMinX + 1;
                }
              } else {
                final today = DateTime.now().day.toDouble();
                actualMaxX = today;
                actualMinX = (today - 4).clamp(1.0, today);
              }

              final incomeBarData = LineChartBarData(
                spots: incomeSpots.isEmpty
                    ? [FlSpot(actualMinX, 0)]
                    : incomeSpots,
                isCurved: true,
                color: Theme.of(context).primaryColor,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      Theme.of(context).primaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              );
              final expenseBarData = LineChartBarData(
                spots: expenseSpots.isEmpty
                    ? [FlSpot(actualMinX, 0)]
                    : expenseSpots,
                isCurved: true,
                color: Theme.of(context).colorScheme.error,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.2),
                      Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              );

              return LineChart(
                LineChartData(
                  showingTooltipIndicators:
                      controller.touchedIndexLine.value != -1
                      ? [
                          ShowingTooltipIndicators([
                            if (controller.touchedIndexLine.value <
                                incomeSpots.length)
                              LineBarSpot(
                                incomeBarData,
                                0,
                                incomeSpots[controller.touchedIndexLine.value],
                              ),
                            if (controller.touchedIndexLine.value <
                                expenseSpots.length)
                              LineBarSpot(
                                expenseBarData,
                                1,
                                expenseSpots[controller.touchedIndexLine.value],
                              ),
                          ]),
                        ]
                      : [],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: false,
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? response) {
                          if (event is FlTapDownEvent ||
                              event is FlPanDownEvent ||
                              event is FlPanUpdateEvent) {
                            if (response != null &&
                                response.lineBarSpots != null &&
                                response.lineBarSpots!.isNotEmpty) {
                              controller.touchedIndexLine.value =
                                  response.lineBarSpots!.first.spotIndex;
                            }
                          } else if (event is FlTapUpEvent ||
                              event is FlPanEndEvent ||
                              event is FlPanCancelEvent ||
                              event is FlLongPressEnd) {
                            controller.touchedIndexLine.value = -1;
                          }
                        },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppTheme.backgroundDark,
                      fitInsideHorizontally: true,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          final bool isIncome = barSpot.barIndex == 0;
                          return LineTooltipItem(
                            'Tgl ${flSpot.x.toInt()} \n${currencyFormat.format(flSpot.y)}',
                            TextStyle(
                              color: isIncome
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: isIncome ? '\n(Masuk)' : '\n(Keluar)',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: actualMinX,
                  maxX: actualMaxX,
                  minY: -bottomBuffer,
                  maxY: maxY > 0 ? maxY * 1.2 : 1000,
                  lineBarsData: [incomeBarData, expenseBarData],
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "Pemasukan",
                  style: TextStyle(
                    fontSize: 8,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "Pengeluaran",
                  style: TextStyle(
                    fontSize: 8,
                    color: Theme.of(context).hintColor,
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
