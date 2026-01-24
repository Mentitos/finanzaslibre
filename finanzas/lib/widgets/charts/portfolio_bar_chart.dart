import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/formatters.dart';
import '../../l10n/category_translations.dart';

class PortfolioBarChart extends StatelessWidget {
  final Map<String, double> categoryData;

  const PortfolioBarChart({super.key, required this.categoryData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final validData = categoryData.entries
        .where((entry) => entry.value.abs() > 0.01)
        .toList();

    if (validData.isEmpty) {
      return Card(
        child: Container(
          height: 350,
          alignment: Alignment.center,
          child: Text(
            l10n.noDataForPeriod,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    validData.sort((a, b) => b.value.compareTo(a.value));

    final List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < validData.length; i++) {
      final entry = validData[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              color: entry.value >= 0 ? Colors.green : Colors.red,
              width: 16,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Portafolio por Categoría",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 350,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= validData.length) {
                            return Container();
                          }
                          final categoryName = l10n.translateCategory(
                            validData[index].key,
                          );
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4.0,
                            child: Text(
                              categoryName.length > 3
                                  ? categoryName.substring(0, 3)
                                  : categoryName,
                              style: const TextStyle(fontSize: 10),
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
                          return Text(
                            _formatCurrencySimple(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateHorizontalInterval(validData),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (BarChartGroupData group) {
                        return Colors.blueGrey.shade800;
                      },
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final categoryName = l10n.translateCategory(
                          validData[group.x].key,
                        );
                        final amount = rod.toY;
                        return BarTooltipItem(
                          '$categoryName\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: Formatters.formatCurrency(amount),
                              style: TextStyle(
                                color: amount >= 0
                                    ? Colors.lightGreenAccent
                                    : Colors.redAccent,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                swapAnimationDuration: const Duration(milliseconds: 600),
                swapAnimationCurve: Curves.easeInOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrencySimple(double value) {
    if (value == 0) return '0';
    if (value.abs() >= 1e12) {
      return '${(value / 1e12).toStringAsFixed(1)}T';
    }
    if (value.abs() >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(1)}B';
    }
    if (value.abs() >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(1)}M';
    }
    if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  double _calculateHorizontalInterval(List<MapEntry<String, double>> data) {
    if (data.isEmpty) return 100;
    double maxVal = 0;
    double minVal = 0;
    for (var entry in data) {
      if (entry.value > maxVal) maxVal = entry.value;
      if (entry.value < minVal) minVal = entry.value;
    }
    final range = maxVal - minVal;
    if (range == 0) return 100;
    return range / 5;
  }
}
