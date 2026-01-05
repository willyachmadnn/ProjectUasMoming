import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../models/tabungan_models.dart';

class GrafikBatangTabungan extends StatelessWidget {
  final List<ModelTabungan> savings;

  const GrafikBatangTabungan({super.key, required this.savings});

  @override
  Widget build(BuildContext context) {
    if (savings.isEmpty) {
      return Center(
        child: Text(
          "Belum ada target tabungan",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }

    // Ambil 5 tabungan terakhir/terpenting untuk ditampilkan agar tidak sesak
    final displaySavings = savings.take(5).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxY(displaySavings),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Theme.of(context).cardColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final saving = displaySavings[groupIndex];
              return BarTooltipItem(
                '${saving.title}\n',
                const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: NumberFormat.compactCurrency(
                      locale: 'id_ID',
                      symbol: 'Rp',
                      decimalDigits: 0,
                    ).format(rod.toY),
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
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= displaySavings.length)
                  return const SizedBox();
                // Tampilkan inisial nama tabungan
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    displaySavings[value.toInt()].title
                        .substring(0, 1)
                        .toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: displaySavings.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.currentAmount,
                color: Theme.of(context).primaryColor,
                width: 12,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: data.targetAmount, // Target sebagai background bar
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  double _calculateMaxY(List<ModelTabungan> data) {
    if (data.isEmpty) return 1000;
    double maxVal = 0;
    for (var item in data) {
      if (item.targetAmount > maxVal) maxVal = item.targetAmount;
    }
    return maxVal * 1.1; // Tambah buffer 10%
  }
}
