import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../models/color_palette.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryData;
  final Map<String, Color> categoryColors;
  final ColorPalette? palette;

  const CategoryPieChart({
    super.key,
    required this.categoryData,
    required this.categoryColors,
    this.palette, // Optional, for future theming
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final validData = categoryData.entries
        .where((entry) => entry.value.abs() > 0.01)
        .toList();

    if (validData.isEmpty) {
      return Card(
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: Text(
            l10n.noDataForPeriod,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    final sortedEntries = validData
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    final total = sortedEntries.fold<double>(
      0,
      (sum, e) => sum + e.value.abs(),
    );

    if (total <= 0) {
      return Card(
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: Text(
            l10n.noDataForPeriod,
            style: TextStyle(color: Colors.grey[600]),
          ),
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
              l10n.distributionByCategory,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  pieTouchData: PieTouchData(enabled: true),
                  sections: sortedEntries.map((entry) {
                    final percentage = (entry.value.abs() / total) * 100;

                    return PieChartSectionData(
                      color: AppConstants.getCategoryColor(
                        entry.key,
                        categoryColors,
                      ),
                      value: entry.value.abs(),
                      title: percentage >= 5
                          ? '${percentage.toStringAsFixed(0)}%'
                          : '',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 800),
                swapAnimationCurve: Curves.easeInOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
