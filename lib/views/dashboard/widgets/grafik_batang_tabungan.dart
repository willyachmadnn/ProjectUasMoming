import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/beranda_controllers.dart';

class GrafikBatangTabungan extends StatelessWidget {
  const GrafikBatangTabungan({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KontrolerBeranda>();

    return Obx(() {
      final current = controller.totalSavingsCurrent.value;
      final target = controller.totalSavingsTarget.value;

      final double percentage = target == 0
          ? 0.0
          : (current / target * 100).clamp(0.0, 100.0);

      if (target == 0) {
        return Center(
          child: Text(
            "Belum ada target tabungan",
            style: TextStyle(
              color: Theme.of(context).disabledColor,
              fontSize: 12,
            ),
          ),
        );
      }

      return SizedBox(
        height: 65,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${percentage.toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    "Terkumpul",
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: RotatedBox(
                quarterTurns: 1,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.center,
                    maxY: 100,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        rotateAngle: -90,
                        getTooltipColor: (group) => Theme.of(context).cardColor,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            'Total Tabungan\n',
                            TextStyle(
                              color: Theme.of(context).disabledColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: NumberFormat.compactCurrency(
                                  locale: 'id_ID',
                                  symbol: 'Rp',
                                  decimalDigits: 0,
                                ).format(current),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: const FlTitlesData(show: false),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: percentage,
                            color: Theme.of(context).primaryColor,
                            width: 24,
                            borderRadius: BorderRadius.circular(12),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 100,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
