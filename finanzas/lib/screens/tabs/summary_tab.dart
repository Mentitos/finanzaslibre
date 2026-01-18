import 'package:flutter/material.dart';
import '../../models/savings_record.dart';
import '../../models/color_palette.dart';
import '../../widgets/record_item.dart';
import '../../utils/formatters.dart';
import '../../constants/app_constants.dart';
import '../statistics_screen.dart';
import '../../l10n/app_localizations.dart';

class SummaryTab extends StatelessWidget {
  final Map<String, dynamic> statistics;
  final List<SavingsRecord> allRecords;
  final Map<String, Color> categoryColors;
  final bool privacyMode;
  final Future<void> Function() onRefresh;
  final Function(SavingsRecord) onEditRecord;
  final Function(MoneyType, double) onQuickMoneyTap;
  final VoidCallback onViewAllTap;

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

  final ColorPalette palette;

  String _formatPrivateAmount(double amount) {
    if (privacyMode) {
      return '••••••';
    }
    return Formatters.formatCurrency(amount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
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
            if (allRecords.isNotEmpty) _buildRecentMovements(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context, AppLocalizations l10n) {
    final totalAmount = statistics['totalAmount']?.toDouble() ?? 0.0;
    final isPositive = totalAmount >= 0;

    List<Color>? gradientColors; // Nullable
    Color? solidColor; // For custom palette
    Color shadowColor;

    if (palette.affectTotalCard && isPositive) {
      // Logic: Darker for Light Theme, Lighter for Dark Theme based on Seed
      final brightness = Theme.of(context).brightness;
      final hsl = HSLColor.fromColor(palette.seedColor);

      if (brightness == Brightness.light) {
        // Light Theme: Use Solid Subtle Darker Tone (Changed from 0.15 to 0.05)
        solidColor = hsl
            .withLightness((hsl.lightness - 0.05).clamp(0.0, 1.0))
            .toColor();
        shadowColor = solidColor;
      } else {
        // Dark Theme: Use Solid Subtle Lighter Tone (Changed from 0.15 to 0.05)
        solidColor = hsl
            .withLightness((hsl.lightness + 0.05).clamp(0.0, 1.0))
            .toColor();
        shadowColor = solidColor;
      }
      gradientColors = null; // No gradient
    } else {
      // Default Green/Red Gradient
      gradientColors = isPositive
          ? [Colors.green.shade400, Colors.green.shade600]
          : [Colors.red.shade400, Colors.red.shade600];
      shadowColor = isPositive ? Colors.green : Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: solidColor, // Apply solid color if present
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
            color: shadowColor.withOpacity(0.3),
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
          Text(
            '${isPositive ? '' : '-'}${AppConstants.currencySymbol}${_formatPrivateAmount(totalAmount.abs())}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (allRecords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.lastMovement}: ${Formatters.formatRelativeDate(allRecords.first.createdAt, l10n)}',
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
    final physicalAmount = statistics['totalPhysical']?.toDouble() ?? 0.0;
    final digitalAmount = statistics['totalDigital']?.toDouble() ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildMoneyCard(
            title: l10n.physicalMoney,
            amount: physicalAmount,
            icon: Icons.account_balance_wallet,
            color: AppConstants.physicalMoneyColor,
            onTap: () => onQuickMoneyTap(MoneyType.physical, physicalAmount),
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: _buildMoneyCard(
            title: l10n.digitalMoney,
            amount: digitalAmount,
            icon: Icons.credit_card,
            color: AppConstants.digitalMoneyColor,
            onTap: () => onQuickMoneyTap(MoneyType.digital, digitalAmount),
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
      shadowColor: color.withOpacity(0.2),
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
                  color: color.withOpacity(0.1),
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
              Text(
                '${amount < 0 ? '-' : ''}${AppConstants.currencySymbol}${_formatPrivateAmount(amount.abs())}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AppLocalizations l10n) {
    final totalRecords = statistics['totalRecords'] ?? 0;
    final totalDeposits = statistics['totalDeposits'] ?? 0;
    final totalWithdrawals = statistics['totalWithdrawals'] ?? 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatisticsScreen(
              allRecords: allRecords,
              categoryColors: categoryColors,
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
            style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 50, color: Colors.grey.withOpacity(0.3));
  }

  Widget _buildRecentMovements(BuildContext context, AppLocalizations l10n) {
    final recentRecords = allRecords
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
                Text(
                  l10n.recentMovements,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(onPressed: onViewAllTap, child: Text(l10n.viewAll)),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ...recentRecords.map(
              (record) => RecentRecordItem(
                record: record,
                onTap: () => onEditRecord(record),
                categoryColors: categoryColors,
                l10n: l10n,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
