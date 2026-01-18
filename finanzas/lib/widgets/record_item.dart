import 'package:finanzas/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../models/savings_record.dart';
import '../utils/formatters.dart';
import '../constants/app_constants.dart';
import '../../l10n/category_translations.dart';
import 'marquee_widget.dart';

class RecordItem extends StatelessWidget {
  final SavingsRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showCategory;
  final Map<String, Color>? categoryColors;
  final AppLocalizations l10n;

  const RecordItem({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
    this.categoryColors,
    this.showCategory = false,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final categoryName = l10n.translateCategory(record.category);

    Color transactionColor;
    IconData icon;
    String amountText;

    var typeForDisplay = record.type;
    if (typeForDisplay == RecordType.adjustment) {
      typeForDisplay = record.totalAmount >= 0
          ? RecordType.deposit
          : RecordType.withdrawal;
    }

    switch (typeForDisplay) {
      case RecordType.deposit:
        transactionColor = Colors.green;
        icon = Icons.arrow_upward;
        amountText =
            '+\$${Formatters.formatCurrency(record.totalAmount.abs())}';
        break;
      case RecordType.withdrawal:
        transactionColor = Colors.red;
        icon = Icons.arrow_downward;
        amountText =
            '-\$${Formatters.formatCurrency(record.totalAmount.abs())}';
        break;
      case RecordType.adjustment:
        // This case will not be reached due to the logic above, but kept for safety.
        transactionColor = Colors.blue;
        icon = Icons.sync_alt;
        amountText = Formatters.formatCurrencyWithSign(record.totalAmount);
        break;
    }

    final categoryColor = AppConstants.getCategoryColor(
      record.category,
      categoryColors,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: transactionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: transactionColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.description.isEmpty
                          ? categoryName
                          : record.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (showCategory) ...[
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: categoryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                categoryName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: categoryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            Formatters.formatRelativeDate(
                              record.createdAt,
                              l10n,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (record.notes != null && record.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        record.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100, // Fixed width to force marquee if needed
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: MarqueeWidget(
                        child: Text(
                          amountText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: transactionColor,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (record.physicalAmount != 0) ...[
                        Icon(
                          Icons.account_balance_wallet,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          Formatters.formatCurrencyWithSign(
                            record.physicalAmount,
                            showPositiveSign:
                                record.type == RecordType.adjustment,
                            useScientificNotation: true,
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (record.digitalAmount != 0) const SizedBox(width: 4),
                      ],
                      if (record.digitalAmount != 0) ...[
                        Icon(
                          Icons.credit_card,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          Formatters.formatCurrencyWithSign(
                            record.digitalAmount,
                            showPositiveSign:
                                record.type == RecordType.adjustment,
                            useScientificNotation: true,
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: Colors.grey[400],
                iconSize: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentRecordItem extends StatelessWidget {
  final SavingsRecord record;
  final VoidCallback onTap;
  final Map<String, Color>? categoryColors;
  final AppLocalizations l10n;

  const RecentRecordItem({
    super.key,
    required this.record,
    required this.onTap,
    this.categoryColors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    Color transactionColor;
    IconData icon;
    String amountText;

    var typeForDisplay = record.type;
    if (typeForDisplay == RecordType.adjustment) {
      typeForDisplay = record.totalAmount >= 0
          ? RecordType.deposit
          : RecordType.withdrawal;
    }

    switch (typeForDisplay) {
      case RecordType.deposit:
        transactionColor = Colors.green;
        icon = Icons.arrow_upward;
        amountText =
            '+\$${Formatters.formatCurrency(record.totalAmount.abs())}';
        break;
      case RecordType.withdrawal:
        transactionColor = Colors.red;
        icon = Icons.arrow_downward;
        amountText =
            '-\$${Formatters.formatCurrency(record.totalAmount.abs())}';
        break;
      case RecordType.adjustment:
        // This case will not be reached
        transactionColor = Colors.blue;
        icon = Icons.sync_alt;
        amountText = Formatters.formatCurrencyWithSign(record.totalAmount);
        break;
    }

    final categoryColor = AppConstants.getCategoryColor(
      record.category,
      categoryColors,
    );

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: transactionColor.withOpacity(0.1),
        child: Icon(icon, color: transactionColor, size: 20),
      ),
      title: Text(
        record.description.isEmpty ? record.category : record.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: categoryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                l10n.translateCategory(record.category),
                style: TextStyle(
                  fontSize: 10,
                  color: categoryColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              Formatters.formatRelativeDate(record.createdAt, l10n),
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: SizedBox(
        width: 100, // Constrain width for marquee
        child: Align(
          alignment: Alignment.centerRight,
          child: MarqueeWidget(
            child: Text(
              amountText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transactionColor,
                fontSize: 15,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
