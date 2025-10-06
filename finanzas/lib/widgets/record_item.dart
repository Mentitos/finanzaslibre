import 'package:finanzas/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../models/savings_record.dart';
import '../utils/formatters.dart';
import '../constants/app_constants.dart';
import '../../l10n/category_translations.dart';


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
    // Verde para depósitos, rojo para retiros
    final transactionColor = record.type == RecordType.deposit 
        ? Colors.green 
        : Colors.red;
    
    // Color de categoría
    final categoryColor = AppConstants.getCategoryColor(record.category, categoryColors);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono con color de transacción (verde/rojo)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: transactionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  record.type == RecordType.deposit
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: transactionColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        record.description.isEmpty
            ? categoryName   // <--- USAR categoryName
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: categoryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  categoryName, // <--- USAR categoryName
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
                            Formatters.formatRelativeDate(record.createdAt),
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
                  // Monto con color de transacción (verde/rojo)
                  Text(
                    '${record.type == RecordType.deposit ? '+' : '-'}\$${Formatters.formatCurrency(record.totalAmount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: transactionColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (record.physicalAmount > 0) ...[
                        Icon(
                          Icons.account_balance_wallet,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '\$${Formatters.formatCurrency(record.physicalAmount)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (record.digitalAmount > 0) const SizedBox(width: 4),
                      ],
                      if (record.digitalAmount > 0) ...[
                        Icon(
                          Icons.credit_card,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '\$${Formatters.formatCurrency(record.digitalAmount)}',
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

// Widget para "Últimos Movimientos" en la pestaña de resumen
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
    // Verde/rojo para la transacción
    final transactionColor = record.type == RecordType.deposit 
        ? Colors.green 
        : Colors.red;
    
    // Color de categoría para el badge
    final categoryColor = AppConstants.getCategoryColor(record.category, categoryColors);
    
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: transactionColor.withOpacity(0.1),
        child: Icon(
          record.type == RecordType.deposit
              ? Icons.arrow_upward
              : Icons.arrow_downward,
          color: transactionColor,
          size: 20,
        ),
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
              Formatters.formatRelativeDate(record.createdAt),
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Text(
        '${record.type == RecordType.deposit ? '+' : '-'}\$${Formatters.formatCurrency(record.totalAmount)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: transactionColor,
          fontSize: 15,
        ),
      ),
    );
  }
}