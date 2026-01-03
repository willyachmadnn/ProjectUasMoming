import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GrafikAnalisisKeuangan extends StatelessWidget {
  final Map<String, double> data;
  final double totalIncome;
  final double totalExpense;
  final List<Map<String, dynamic>> monthlyStats;

  const GrafikAnalisisKeuangan({
    super.key,
    required this.data,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.monthlyStats = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Colors based on user request
    final List<Color> palette = [
      Color(0xFF1F77B4),
      Color(0xFFFF7F0E),
      Color(0xFF2CA02C),
      Color(0xFFD62728),
      Color(0xFF9467BD),
      Color(0xFF8C564B),
      Color(0xFFE377C2),
      Color(0xFF7F7F7F),
      Color(0xFFBCBD22),
      Color(0xFF17BECF),
    ];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analisis Keuangan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Pengeluaran per Kategori',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 16),
          // Pie Chart & Legend
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 200,
                  child: data.isEmpty
                      ? Center(child: Text("Tidak ada data"))
                      : PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(enabled: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: _generateSections(palette),
                          ),
                        ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildLegend(palette, context),
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          Text(
            'Pemasukan vs Pengeluaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 16),
          // Bar Chart (3 Months Data)
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _calculateMaxY(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= monthlyStats.length) {
                          return const Text('');
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            monthlyStats[value.toInt()]['month'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return Text('');
                        return Text(
                          _compactNumber(value),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generateSections(List<Color> palette) {
    if (data.isEmpty) return [];

    double total = data.values.fold(0, (sum, item) => sum + item);
    int index = 0;

    return data.entries.map((entry) {
      final color = palette[index % palette.length];
      index++;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${(entry.value / total * 100).toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend(List<Color> palette, BuildContext context) {
    int index = 0;
    return data.entries.map((entry) {
      final color = palette[index % palette.length];
      index++;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildBarGroups() {
    if (monthlyStats.isEmpty) return [];

    return monthlyStats.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> stat = entry.value;
      double income = (stat['income'] as num).toDouble();
      double expense = (stat['expense'] as num).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: income,
            color: Color(0xFF22C55E),
            width: 12,
            borderRadius: BorderRadius.circular(2),
          ),
          BarChartRodData(
            toY: expense,
            color: Color(0xFFEF4444),
            width: 12,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();
  }

  double _calculateMaxY() {
    double max = 0;
    for (var stat in monthlyStats) {
      double income = (stat['income'] as num).toDouble();
      double expense = (stat['expense'] as num).toDouble();
      if (income > max) max = income;
      if (expense > max) max = expense;
    }
    return max == 0 ? 1000000 : max * 1.2;
  }

  String _compactNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}jt';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}rb';
    }
    return number.toStringAsFixed(0);
  }
}
