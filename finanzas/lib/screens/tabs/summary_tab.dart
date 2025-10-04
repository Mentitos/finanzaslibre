import 'package:flutter/material.dart';
import '../../models/savings_record.dart';
import '../../widgets/record_item.dart';
import '../../utils/formatters.dart';
import '../../constants/app_constants.dart';
import '../statistics_screen.dart';


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
  });

  String _formatPrivateAmount(double amount) {
    if (privacyMode) {
      return '••••••';
    }
    return Formatters.formatCurrency(amount);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalCard(context),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildMoneyTypesRow(),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildStatsRow(context), // PASAR context
            const SizedBox(height: AppConstants.largePadding),
            if (allRecords.isNotEmpty) _buildRecentMovements(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context) {
    final totalAmount = statistics['totalAmount']?.toDouble() ?? 0.0;
    final isPositive = totalAmount >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? Colors.green : Colors.red).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            AppConstants.totalSavingsLabel,
            style: TextStyle(
              color: Colors.white,
              fontSize: AppConstants.largeFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppConstants.currencySymbol}${_formatPrivateAmount(totalAmount)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (allRecords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Último movimiento: ${Formatters.formatRelativeDate(allRecords.first.createdAt)}',
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

  Widget _buildMoneyTypesRow() {
    final physicalAmount = statistics['totalPhysical']?.toDouble() ?? 0.0;
    final digitalAmount = statistics['totalDigital']?.toDouble() ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildMoneyCard(
            title: AppConstants.physicalMoneyLabel,
            amount: physicalAmount,
            icon: Icons.account_balance_wallet,
            color: AppConstants.physicalMoneyColor,
            onTap: () => onQuickMoneyTap(MoneyType.physical, physicalAmount),
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: _buildMoneyCard(
            title: AppConstants.digitalMoneyLabel,
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
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600], // Este queda igual, funciona en ambos modos
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${AppConstants.currencySymbol}${_formatPrivateAmount(amount)}',
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

  Widget _buildStatsRow(BuildContext context) {
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            _buildStatItem(
              context,
              title: 'Total Registros',
              value: '$totalRecords',
              icon: Icons.receipt_long,
              color: Colors.orange,
            ),
            _buildDivider(),
            _buildStatItem(
              context,
              title: AppConstants.depositLabel,
              value: '$totalDeposits',
              icon: Icons.arrow_upward,
              color: AppConstants.depositColor,
            ),
            _buildDivider(),
            _buildStatItem(
              context,
              title: AppConstants.withdrawalLabel,
              value: '$totalWithdrawals',
              icon: Icons.arrow_downward,
              color: AppConstants.withdrawalColor,
            ),
          ],
        ),
      ),
    ),
  ); // ESTE PARÉNTESIS CIERRA EL InkWell
}

  Widget _buildStatItem(
    BuildContext context, { // AGREGAR context
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    // Usar color adaptativo para el texto
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
    
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
              color: textColor.withOpacity(0.7), // USAR COLOR ADAPTATIVO
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
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildRecentMovements(BuildContext context) {
    final recentRecords = allRecords.take(AppConstants.recentRecordsCount).toList();

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
                  'Últimos Movimientos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: onViewAllTap,
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ...recentRecords.map((record) => RecentRecordItem(
              record: record,
              onTap: () => onEditRecord(record),
              categoryColors: categoryColors,
            )),
          ],
        ),
      ),
    );
  }
}