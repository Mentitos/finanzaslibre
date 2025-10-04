import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/savings_record.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';

enum StatisticsPeriod { day, week, month }

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

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _getFilteredRecords();
    final categoryData = _calculateCategoryData(filteredRecords);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            _buildSummaryCards(filteredRecords),
            const SizedBox(height: 24),
            _buildPieChart(categoryData),
            const SizedBox(height: 24),
            _buildCategoryList(categoryData),
          ],
        ),
      ),
    );
  }

  List<SavingsRecord> _getFilteredRecords() {
    final now = DateTime.now();
    DateTime startDate;

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
    }

    return widget.allRecords.where((record) {
      return record.createdAt.isAfter(startDate) ||
          record.createdAt.isAtSameMomentAs(startDate);
    }).toList();
  }

  Map<String, double> _calculateCategoryData(List<SavingsRecord> records) {
    final Map<String, double> data = {};

    for (var record in records) {
      final amount = record.type == RecordType.deposit
          ? record.totalAmount
          : -record.totalAmount;
      data[record.category] = (data[record.category] ?? 0) + amount;
    }

    return data;
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: _buildPeriodButton(
                'Día',
                StatisticsPeriod.day,
                Icons.today,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPeriodButton(
                'Semana',
                StatisticsPeriod.week,
                Icons.date_range,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPeriodButton(
                'Mes',
                StatisticsPeriod.month,
                Icons.calendar_month,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, StatisticsPeriod period, IconData icon) {
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
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<SavingsRecord> records) {
    final deposits = records.where((r) => r.type == RecordType.deposit);
    final withdrawals = records.where((r) => r.type == RecordType.withdrawal);

    final totalDeposits = deposits.fold<double>(
      0,
      (sum, r) => sum + r.totalAmount,
    );
    final totalWithdrawals = withdrawals.fold<double>(
      0,
      (sum, r) => sum + r.totalAmount,
    );

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Ingresos',
            totalDeposits,
            Colors.green,
            Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Gastos',
            totalWithdrawals,
            Colors.red,
            Icons.arrow_downward,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              '\$${Formatters.formatCurrency(amount)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
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

  Widget _buildPieChart(Map<String, double> categoryData) {
    if (categoryData.isEmpty) {
      return Card(
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: Text(
            'No hay datos para este período',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    final sortedEntries = categoryData.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución por categoría',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: sortedEntries.map((entry) {
                    final index = sortedEntries.indexOf(entry);
                    final percentage = (entry.value.abs() /
                            sortedEntries.fold<double>(
                                0, (sum, e) => sum + e.value.abs())) *
                        100;

                    return PieChartSectionData(
                      color: AppConstants.getCategoryColor(
                          entry.key, widget.categoryColors),
                      value: entry.value.abs(),
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(Map<String, double> categoryData) {
    final sortedEntries = categoryData.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    if (sortedEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = sortedEntries.fold<double>(0, (sum, e) => sum + e.value.abs());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalle por categoría',
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
                                entry.key, widget.categoryColors),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '\$${Formatters.formatCurrency(entry.value.abs())}',
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
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(
                          AppConstants.getCategoryColor(
                              entry.key, widget.categoryColors),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}% del total',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
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
}