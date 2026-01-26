import 'package:flutter/material.dart';
import '../../models/savings_record.dart';
import '../../models/color_palette.dart';
import '../../widgets/record_item.dart';
import '../../utils/formatters.dart';
import '../../constants/app_constants.dart';
import '../statistics_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/charts/category_pie_chart.dart';
import '../../widgets/charts/portfolio_bar_chart.dart';
import '../../widgets/charts/category_list.dart';

class SummaryTab extends StatefulWidget {
  final Map<String, dynamic> statistics;
  final List<SavingsRecord> allRecords;
  final Map<String, Color> categoryColors;
  final bool privacyMode;
  final Future<void> Function() onRefresh;
  final Function(SavingsRecord) onEditRecord;
  final Function(MoneyType, double) onQuickMoneyTap;
  final VoidCallback onViewAllTap;
  final ColorPalette palette;

  const SummaryTab({
    super.key,
    required this.statistics,
    required this.allRecords,
    required this.categoryColors,
    required this.privacyMode,
    required this.onRefresh,
    required this.onEditRecord,
    required this.onQuickMoneyTap,
    required this.onViewAllTap,
    required this.palette,
  });

  @override
  State<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  bool _showPieChart = true;

  String _formatPrivateAmount(double amount) {
    if (widget.privacyMode) {
      return '••••••';
    }
    return Formatters.formatCurrency(amount);
  }

  Map<String, double> _calculateCategoryData() {
    final Map<String, double> data = {};
    for (var record in widget.allRecords) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: _buildDesktopLayout(context, l10n),
            );
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTotalCard(context, l10n),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildMoneyTypesRow(l10n),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildStatsRow(context, l10n),
                const SizedBox(height: AppConstants.largePadding),
                if (widget.allRecords.isNotEmpty)
                  _buildRecentMovements(context, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n) {
    final categoryData = _calculateCategoryData();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna Principal (Izquierda) - Resumen Original
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalCard(context, l10n),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildMoneyTypesRow(l10n),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildStatsRow(context, l10n),
              const SizedBox(height: AppConstants.largePadding),
              if (widget.allRecords.isNotEmpty)
                _buildRecentMovements(context, l10n),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        // Columna Lateral (Derecha) - Gráficos y Lista
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Toggle Switch
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Torta'),
                    icon: Icon(Icons.pie_chart),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Portafolio'),
                    icon: Icon(Icons.bar_chart),
                  ),
                ],
                selected: {_showPieChart},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _showPieChart = newSelection.first;
                  });
                },
                style: ButtonStyle(visualDensity: VisualDensity.compact),
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showPieChart
                    ? CategoryPieChart(
                        key: const ValueKey('pie'),
                        categoryData: categoryData,
                        categoryColors: widget.categoryColors,
                        palette: widget.palette,
                      )
                    : PortfolioBarChart(
                        key: const ValueKey('bar'),
                        categoryData: categoryData,
                      ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              CategoryList(
                categoryData: categoryData,
                categoryColors: widget.categoryColors,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard(BuildContext context, AppLocalizations l10n) {
    final totalAmount = widget.statistics['totalAmount']?.toDouble() ?? 0.0;
    final isPositive = totalAmount >= 0;

    List<Color>? gradientColors;
    Color? solidColor;
    Color shadowColor;

    if (widget.palette.affectTotalCard && isPositive) {
      final brightness = Theme.of(context).brightness;
      final hsl = HSLColor.fromColor(widget.palette.seedColor);

      if (brightness == Brightness.light) {
        solidColor = hsl
            .withLightness((hsl.lightness - 0.05).clamp(0.0, 1.0))
            .toColor();
        shadowColor = solidColor;
      } else {
        solidColor = hsl
            .withLightness((hsl.lightness + 0.05).clamp(0.0, 1.0))
            .toColor();
        shadowColor = solidColor;
      }
      gradientColors = null;
    } else {
      gradientColors = isPositive
          ? [Colors.green.shade400, Colors.green.shade600]
          : [Colors.red.shade400, Colors.red.shade600];
      shadowColor = isPositive ? Colors.green : Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: solidColor,
        gradient: gradientColors != null
            ? LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.totalSavings,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppConstants.largeFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${isPositive ? '' : '-'}${AppConstants.currencySymbol}${_formatPrivateAmount(totalAmount.abs())}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (widget.allRecords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.lastMovement}: ${Formatters.formatRelativeDate(widget.allRecords.first.createdAt, l10n)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: AppConstants.defaultFontSize,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoneyTypesRow(AppLocalizations l10n) {
    final physicalAmount =
        widget.statistics['totalPhysical']?.toDouble() ?? 0.0;
    final digitalAmount = widget.statistics['totalDigital']?.toDouble() ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildMoneyCard(
            title: l10n.physicalMoney,
            amount: physicalAmount,
            icon: Icons.account_balance_wallet,
            color: AppConstants.physicalMoneyColor,
            onTap: () =>
                widget.onQuickMoneyTap(MoneyType.physical, physicalAmount),
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: _buildMoneyCard(
            title: l10n.digitalMoney,
            amount: digitalAmount,
            icon: Icons.credit_card,
            color: AppConstants.digitalMoneyColor,
            onTap: () =>
                widget.onQuickMoneyTap(MoneyType.digital, digitalAmount),
          ),
        ),
      ],
    );
  }

  Widget _buildMoneyCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${amount < 0 ? '-' : ''}${AppConstants.currencySymbol}${_formatPrivateAmount(amount.abs())}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AppLocalizations l10n) {
    final totalRecords = widget.statistics['totalRecords'] ?? 0;
    final totalDeposits = widget.statistics['totalDeposits'] ?? 0;
    final totalWithdrawals = widget.statistics['totalWithdrawals'] ?? 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatisticsScreen(
              allRecords: widget.allRecords,
              categoryColors: widget.categoryColors,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              _buildStatItem(
                context,
                title: l10n.totalRecords,
                value: '$totalRecords',
                icon: Icons.receipt_long,
                color: Colors.orange,
              ),
              _buildDivider(),
              _buildStatItem(
                context,
                title: l10n.deposit,
                value: '$totalDeposits',
                icon: Icons.arrow_upward,
                color: AppConstants.depositColor,
              ),
              _buildDivider(),
              _buildStatItem(
                context,
                title: l10n.withdrawal,
                value: '$totalWithdrawals',
                icon: Icons.arrow_downward,
                color: AppConstants.withdrawalColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }

  Widget _buildRecentMovements(BuildContext context, AppLocalizations l10n) {
    final recentRecords = widget.allRecords
        .take(AppConstants.recentRecordsCount)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.recentMovements,
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: widget.onViewAllTap,
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ...recentRecords.map(
              (record) => RecentRecordItem(
                record: record,
                onTap: () => widget.onEditRecord(record),
                categoryColors: widget.categoryColors,
                l10n: l10n,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
