import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../models/savings_record.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_translations.dart';

enum StatisticsPeriod {
  day,
  week,
  month,
  specificMonth,
  specificDay,
  specificYear,
}

class StatisticsScreen extends StatefulWidget {
  final List<SavingsRecord> allRecords;
  final Map<String, Color> categoryColors;

  const StatisticsScreen({
    super.key,
    required this.allRecords,
    required this.categoryColors,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatisticsPeriod _selectedPeriod = StatisticsPeriod.month;
  DateTime? _selectedSpecificMonth;
  DateTime? _selectedSpecificDay;
  int? _selectedSpecificYear;
  bool _showPieChart = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedSpecificMonth = now;
    _selectedSpecificDay = now;
    _selectedSpecificYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredRecords = _getFilteredRecords();
    final categoryData = _calculateCategoryData(filteredRecords);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statistics)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(l10n),
            const SizedBox(height: 24),

            _buildSummaryCards(filteredRecords, l10n),
            const SizedBox(height: 24),

            Center(
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment<bool>(
                    value: true,

                    label: const Text('Torta'),
                    icon: const Icon(Icons.pie_chart_outline),
                  ),
                  ButtonSegment<bool>(
                    value: false,

                    label: const Text('Portafolio'),
                    icon: const Icon(Icons.bar_chart),
                  ),
                ],
                selected: {_showPieChart},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _showPieChart = newSelection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },

              child: _showPieChart
                  ? _buildPieChart(categoryData, l10n)
                  : _buildPortfolioBarChart(categoryData, l10n),
            ),

            const SizedBox(height: 24),
            _buildCategoryList(categoryData, l10n),
          ],
        ),
      ),
    );
  }

  List<SavingsRecord> _getFilteredRecords() {
    final now = DateTime.now();
    DateTime startDate;
    DateTime? endDate;

    switch (_selectedPeriod) {
      case StatisticsPeriod.day:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case StatisticsPeriod.week:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case StatisticsPeriod.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case StatisticsPeriod.specificMonth:
        final monthToUse = _selectedSpecificMonth ?? now;
        startDate = DateTime(monthToUse.year, monthToUse.month, 1);
        endDate = DateTime(
          monthToUse.year,
          monthToUse.month + 1,
          0,
          23,
          59,
          59,
        );
        break;
      case StatisticsPeriod.specificDay:
        final dayToUse = _selectedSpecificDay ?? now;
        startDate = DateTime(dayToUse.year, dayToUse.month, dayToUse.day);
        endDate = DateTime(
          dayToUse.year,
          dayToUse.month,
          dayToUse.day,
          23,
          59,
          59,
        );
        break;

      case StatisticsPeriod.specificYear:
        final yearToUse = _selectedSpecificYear ?? now.year;
        startDate = DateTime(yearToUse, 1, 1);
        endDate = DateTime(yearToUse, 12, 31, 23, 59, 59);
        break;
    }

    return widget.allRecords.where((record) {
      final isAfterStart =
          record.createdAt.isAfter(startDate) ||
          record.createdAt.isAtSameMomentAs(startDate);

      if (endDate != null) {
        return isAfterStart && record.createdAt.isBefore(endDate);
      }

      return isAfterStart;
    }).toList();
  }

  Map<String, double> _calculateCategoryData(List<SavingsRecord> records) {
    final Map<String, double> data = {};

    for (var record in records) {
      double amount;
      if (record.type == RecordType.adjustment) {
        amount = record.totalAmount;
      } else if (record.type == RecordType.deposit) {
        amount = record.totalAmount;
      } else {
        amount = -record.totalAmount;
      }
      data[record.category] = (data[record.category] ?? 0) + amount;
    }

    return data;
  }

  Widget _buildPeriodSelector(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildPeriodButton(
                    l10n.day,
                    StatisticsPeriod.day,
                    Icons.today,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPeriodButton(
                    l10n.week,
                    StatisticsPeriod.week,
                    Icons.date_range,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPeriodButton(
                    l10n.month,
                    StatisticsPeriod.month,
                    Icons.calendar_month,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPeriodButton(
                    l10n.year,
                    StatisticsPeriod.specificYear,
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPeriodButton(
                    l10n.specificMonth,
                    StatisticsPeriod.specificMonth,
                    Icons.event_note,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPeriodButton(
                    l10n.specificDay,
                    StatisticsPeriod.specificDay,
                    Icons.event,
                  ),
                ),
              ],
            ),
            if (_selectedPeriod == StatisticsPeriod.specificMonth) ...[
              const SizedBox(height: 12),
              _buildMonthSelector(l10n),
            ],
            if (_selectedPeriod == StatisticsPeriod.specificDay) ...[
              const SizedBox(height: 12),
              _buildDaySelector(l10n),
            ],
            if (_selectedPeriod == StatisticsPeriod.specificYear) ...[
              const SizedBox(height: 12),
              _buildYearSelector(l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(
    String label,
    StatisticsPeriod period,
    IconData icon,
  ) {
    final isSelected = _selectedPeriod == period;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectedPeriod = period),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).iconTheme.color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    List<SavingsRecord> records,
    AppLocalizations l10n,
  ) {
    double totalDeposits = 0;
    double totalWithdrawals = 0;

    for (var record in records) {
      if (record.type == RecordType.adjustment) {
        if (record.totalAmount >= 0) {
          totalDeposits += record.totalAmount;
        } else {
          totalWithdrawals += record.totalAmount.abs();
        }
      } else if (record.type == RecordType.deposit) {
        totalDeposits += record.totalAmount;
      } else {
        totalWithdrawals += record.totalAmount;
      }
    }

    final balance = totalDeposits - totalWithdrawals;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            l10n.income,
            totalDeposits,
            Colors.green,
            Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            l10n.expenses,
            totalWithdrawals,
            Colors.red,
            Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            l10n.balance,
            balance,
            balance >= 0 ? Colors.blue : Colors.orange,
            balance >= 0 ? Icons.trending_up : Icons.trending_down,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${amount < 0 ? '-' : ''}${AppConstants.currencySymbol}${Formatters.formatCurrency(amount.abs())}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(
    Map<String, double> categoryData,
    AppLocalizations l10n,
  ) {
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
                        widget.categoryColors,
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
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    Map<String, double> categoryData,
    AppLocalizations l10n,
  ) {
    final validData = categoryData.entries
        .where((entry) => entry.value.abs() > 0.01)
        .toList();

    if (validData.isEmpty) return const SizedBox.shrink();

    final sortedEntries = validData
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    final total = sortedEntries.fold<double>(
      0,
      (sum, e) => sum + e.value.abs(),
    );

    if (total <= 0) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.categoryDetails,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...sortedEntries.map((entry) {
              final percentage = (entry.value.abs() / total) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppConstants.getCategoryColor(
                              entry.key,
                              widget.categoryColors,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.translateCategory(entry.key),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          Formatters.formatCurrencyWithSign(
                            entry.value.abs(),
                            showPositiveSign: false,
                            useScientificNotation: true,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: entry.value >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage > 0
                            ? (percentage / 100).clamp(0.0, 1.0)
                            : 0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(
                          AppConstants.getCategoryColor(
                            entry.key,
                            widget.categoryColors,
                          ),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}% ${l10n.ofTotal}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  //==============================================================
  //           GRÁFICO DE BARRAS PORTAFOLIO
  //==============================================================

  Widget _buildPortfolioBarChart(
    Map<String, double> categoryData,
    AppLocalizations l10n,
  ) {
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
                        color: Colors.grey.withValues(alpha: 0.3),
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
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
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
    if (range == 0) {
      return (maxVal.abs() / 2).clamp(1.0, double.infinity);
    }

    // Target about 4-6 intervals
    final rawInterval = range / 5;

    // Calculate magnitude of the interval
    final magnitude = pow(10, (log(rawInterval) / ln10).floor()).toDouble();
    final residual = rawInterval / magnitude;

    double interval;
    if (residual > 5) {
      interval = 10 * magnitude;
    } else if (residual > 2) {
      interval = 5 * magnitude;
    } else if (residual > 1) {
      interval = 2 * magnitude;
    } else {
      interval = magnitude;
    }

    return interval == 0 ? 100.0 : interval;
  }

  Widget _buildMonthSelector(AppLocalizations l10n) {
    final now = DateTime.now();
    final selectedMonth = _selectedSpecificMonth ?? now;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _selectMonth(context, l10n),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: Theme.of(context).colorScheme.primary,
              size: 40,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formatMonthYear(selectedMonth),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector(AppLocalizations l10n) {
    final now = DateTime.now();
    final selectedDay = _selectedSpecificDay ?? now;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _selectDay(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event,
              color: Theme.of(context).colorScheme.primary,
              size: 40,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formatDate(selectedDay),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSelector(AppLocalizations l10n) {
    final now = DateTime.now();
    final selectedYear = _selectedSpecificYear ?? now.year;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _selectYear(context, l10n),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
              size: 40,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedYear.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    return '${Formatters.getMonthName(date.month, l10n)} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectMonth(BuildContext context, AppLocalizations l10n) async {
    final now = DateTime.now();
    final initialDate = _selectedSpecificMonth ?? now;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.selectMonth),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearMonthPicker(
              initialDate: initialDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedSpecificMonth = date;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDay(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _selectedSpecificDay ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedSpecificDay = picked;
      });
    }
  }

  Future<void> _selectYear(BuildContext context, AppLocalizations l10n) async {
    final now = DateTime.now();
    final currentYear = now.year;
    final selectedYear = _selectedSpecificYear ?? currentYear;

    // Generate years from current down to 1600
    final years = List.generate(
      currentYear - 1600 + 1,
      (index) => currentYear - index,
    );

    final scrollController = FixedExtentScrollController(
      initialItem: years.indexOf(selectedYear),
    );

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 350,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.year,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    ListWheelScrollView.useDelegate(
                      controller: scrollController,
                      itemExtent: 50,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        // Optional: Haptic feedback
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: years.length,
                        builder: (context, index) {
                          final year = years[index];
                          return Center(
                            child: Text(
                              year.toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Center(
                      child: IgnorePointer(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_right,
                              size: 30,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 80), // Space for text
                            Icon(
                              Icons.arrow_left,
                              size: 30,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final selectedIndex = scrollController.selectedItem;
                      setState(() {
                        _selectedSpecificYear = years[selectedIndex];
                      });
                      Navigator.pop(context);
                    },
                    child: Text(l10n.save),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class YearMonthPicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const YearMonthPicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<YearMonthPicker> createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<YearMonthPicker> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final years = List.generate(now.year - 2019, (index) => 2020 + index);

    final months = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];

    return Column(
      children: [
        DropdownButtonFormField<int>(
          initialValue: _selectedYear,
          decoration: InputDecoration(
            labelText: l10n.year,
            border: const OutlineInputBorder(),
          ),
          items: years.map((year) {
            return DropdownMenuItem(value: year, child: Text(year.toString()));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedYear = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = month == _selectedMonth;
              final isFuture = _selectedYear == now.year && month > now.month;

              return InkWell(
                onTap: isFuture
                    ? null
                    : () {
                        setState(() {
                          _selectedMonth = month;
                        });
                        widget.onDateSelected(DateTime(_selectedYear, month));
                      },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (isFuture ? Colors.grey[300] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    months[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isFuture ? Colors.grey : Colors.black87),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
