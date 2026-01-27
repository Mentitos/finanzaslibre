import 'package:flutter/material.dart';
import '../../models/recurring_transaction.dart';

class DueRecurringDialog extends StatefulWidget {
  final List<RecurringTransaction> dueTransactions;
  final Function(List<RecurringTransaction>) onProcess;
  final VoidCallback onSkip;

  const DueRecurringDialog({
    super.key,
    required this.dueTransactions,
    required this.onProcess,
    required this.onSkip,
  });

  @override
  State<DueRecurringDialog> createState() => _DueRecurringDialogState();
}

class _DueRecurringDialogState extends State<DueRecurringDialog> {
  // Allow user to uncheck specific items if they aren't ready to pay yet
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    // Default select all
    _selectedIds.addAll(widget.dueTransactions.map((t) => t.id));
  }

  void _process() {
    final toProcess = widget.dueTransactions
        .where((t) => _selectedIds.contains(t.id))
        .toList();
    widget.onProcess(toProcess);
    // Navigator.of(context).pop(); // Handled by callback
  }

  @override
  Widget build(BuildContext context) {
    // Localize later
    final total = widget.dueTransactions
        .where((t) => _selectedIds.contains(t.id))
        .fold(0.0, (sum, t) => sum + t.physicalAmount + t.digitalAmount);

    return AlertDialog(
      title: const Text('Gastos Recurrentes Pendientes'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Se detectaron los siguientes pagos pendientes:'),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.dueTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = widget.dueTransactions[index];
                  final amount =
                      transaction.physicalAmount + transaction.digitalAmount;
                  return CheckboxListTile(
                    value: _selectedIds.contains(transaction.id),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedIds.add(transaction.id);
                        } else {
                          _selectedIds.remove(transaction.id);
                        }
                      });
                    },
                    title: Text(transaction.name),
                    subtitle: Text('\$${amount.toStringAsFixed(0)}'),
                    secondary: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total a procesar: \$${total.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onSkip();
            // Navigator.of(context).pop(); // Handled by callback
          },
          child: const Text('Omitir por ahora'),
        ),
        FilledButton(
          onPressed: _selectedIds.isEmpty ? null : _process,
          child: const Text('Procesar Selección'),
        ),
      ],
    );
  }
}
