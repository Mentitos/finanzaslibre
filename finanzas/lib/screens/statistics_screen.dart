import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/savings_record.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';
import '../../l10n/app_localizations.dart'; 
import '../../l10n/category_translations.dart';

enum StatisticsPeriod { day, week, month, specificMonth, specificDay }

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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedSpecificMonth = now;
    _selectedSpecificDay = now;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredRecords = _getFilteredRecords();
    final categoryData = _calculateCategoryData(filteredRecords);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(l10n),
            const SizedBox(height: 24),
            _buildSummaryCards(filteredRecords, l10n),
            const SizedBox(height: 24),
            _buildPieChart(categoryData, l10n),
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
        endDate = DateTime(monthToUse.year, monthToUse.month + 1, 0, 23, 59, 59);
        break;
      case StatisticsPeriod.specificDay:
        final dayToUse = _selectedSpecificDay ?? now;
        startDate = DateTime(dayToUse.year, dayToUse.month, dayToUse.day);
        endDate = DateTime(dayToUse.year, dayToUse.month, dayToUse.day, 23, 59, 59);
        break;
    }

    return widget.allRecords.where((record) {
      final isAfterStart = record.createdAt.isAfter(startDate) ||
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
      final amount = record.type == RecordType.deposit
          ? record.totalAmount
          : -record.totalAmount;
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

  Widget _buildSummaryCards(List<SavingsRecord> records, AppLocalizations l10n) {
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
            balance.abs(),
            balance >= 0 ? Colors.blue : Colors.orange,
            balance >= 0 ? Icons.trending_up : Icons.trending_down,
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
              '${AppConstants.currencySymbol}${Formatters.formatCurrency(amount)}',
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

  Widget _buildPieChart(Map<String, double> categoryData, AppLocalizations l10n) {
    if (categoryData.isEmpty) {
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

    final sortedEntries = categoryData.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

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
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  pieTouchData: PieTouchData(enabled: true),
                  sections: sortedEntries.map((entry) {
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
                swapAnimationDuration: const Duration(milliseconds: 800),
                swapAnimationCurve: Curves.easeInOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(Map<String, double> categoryData, AppLocalizations l10n) {
    final sortedEntries = categoryData.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    if (sortedEntries.isEmpty) return const SizedBox.shrink();

    final total = sortedEntries.fold<double>(0, (sum, e) => sum + e.value.abs());

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
                            color: AppConstants.getCategoryColor(entry.key, widget.categoryColors),
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
                          '${AppConstants.currencySymbol}${Formatters.formatCurrency(entry.value.abs())}',
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
                          AppConstants.getCategoryColor(entry.key, widget.categoryColors),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}% ${l10n.ofTotal}',
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
    final years = List.generate(
      now.year - 2019,
      (index) => 2020 + index,
    );

    final months = [
      l10n.january, l10n.february, l10n.march, l10n.april,
      l10n.may, l10n.june, l10n.july, l10n.august,
      l10n.september, l10n.october, l10n.november, l10n.december
    ];

    return Column(
      children: [
        DropdownButtonFormField<int>(
          value: _selectedYear,
          decoration: InputDecoration(
            labelText: l10n.year,
            border: const OutlineInputBorder(),
          ),
          items: years.map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text(year.toString()),
            );
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
                onTap: isFuture ? null : () {
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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