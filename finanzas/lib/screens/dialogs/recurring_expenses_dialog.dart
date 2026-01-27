import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // For Timer custom refresh
import '../../models/recurring_transaction.dart';
import '../../models/savings_record.dart';
import '../../services/savings_data_manager.dart';
import '../../services/data_change_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_translations.dart';
import '../../constants/app_constants.dart';
import '../../utils/input_formatters.dart';

class RecurringExpensesDialog extends StatefulWidget {
  final Function(RecurringTransaction) onSelectTemplate;

  const RecurringExpensesDialog({super.key, required this.onSelectTemplate});

  @override
  State<RecurringExpensesDialog> createState() =>
      _RecurringExpensesDialogState();
}

class _RecurringExpensesDialogState extends State<RecurringExpensesDialog> {
  final _dataManager = SavingsDataManager();
  List<RecurringTransaction> _templates = [];
  bool _isLoading = true;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _loadTemplates();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    // setState(() => _isLoading = true); // Don't show loading spinner on periodic refresh
    // Just silent update
    final templates = await _dataManager.loadRecurringTemplates();
    if (mounted) {
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTemplate(String id) async {
    await _dataManager.deleteRecurringTemplate(id);
    _loadTemplates();
  }

  void _showAddTemplateDialog({RecurringTransaction? existingTemplate}) {
    showDialog(
      context: context,
      builder: (context) => _AddTemplateDialog(
        existingTemplate: existingTemplate,
        onSave: (template, payNow) async {
          if (payNow) {
            template.lastProcessedDate = DateTime.now();
            final record = SavingsRecord(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              physicalAmount: template.physicalAmount,
              digitalAmount: template.digitalAmount,
              description: template.name,
              createdAt: DateTime.now(),
              type: template.type,
              category: template.category,
            );
            await _dataManager.addRecord(record);
            DataChangeNotifier().notifyDataChanged();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago inicial registrado')),
              );
            }
          }

          if (existingTemplate != null) {
            await _dataManager.deleteRecurringTemplate(existingTemplate.id);
          }
          await _dataManager.addRecurringTemplate(template);

          if (mounted) _loadTemplates();
        },
      ),
    );
  }

  String _getFrequencyText(
    BuildContext context,
    RecurringTransaction template,
  ) {
    String freq;
    switch (template.frequency) {
      case RecurringFrequency.daily:
        freq = 'Diario';
        break;
      case RecurringFrequency.weekly:
        freq = 'Semanal';
        break;
      case RecurringFrequency.monthly:
        freq = 'Mensual (Día ${template.recurrenceDay ?? "?"})';
        break;
      case RecurringFrequency.yearly:
        freq = 'Anual';
        break;
      case RecurringFrequency.custom:
        final interval = template.customInterval ?? 1;
        final unit = template.customUnit ?? RecurringUnit.day;
        String unitText;
        switch (unit) {
          case RecurringUnit.second:
            unitText = 'segundos';
            break;
          case RecurringUnit.minute:
            unitText = 'minutos';
            break;
          case RecurringUnit.hour:
            unitText = 'horas';
            break;
          case RecurringUnit.day:
            unitText = 'días';
            break;
          case RecurringUnit.week:
            unitText = 'semanas';
            break;
          case RecurringUnit.month:
            unitText = 'meses';
            break;
          case RecurringUnit.year:
            unitText = 'años';
            break;
        }
        freq = 'Cada $interval $unitText';
        break;
    }

    // Add Countdown
    final remainingText = template.getDaysRemainingText(); // Use new helper
    return '$freq • $remainingText';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gastos Recurrentes',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _templates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.repeat,
                            size: 48,
                            color: Theme.of(context).disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay plantillas guardadas',
                            style: TextStyle(
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _templates.length,
                      itemBuilder: (context, index) {
                        final template = _templates[index];
                        final total =
                            template.physicalAmount + template.digitalAmount;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppConstants.getCategoryColor(
                              template.category,
                            ),
                            child: Icon(
                              AppConstants.getCategoryIcon(template.category),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(template.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.translateCategory(template.category)} • \$${total.toStringAsFixed(0)}',
                              ),
                              Text(
                                _getFrequencyText(context, template),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showAddTemplateDialog(
                                  existingTemplate: template,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteTemplate(template.id),
                              ),
                            ],
                          ),
                          onTap: () {
                            widget.onSelectTemplate(template);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showAddTemplateDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Nueva Suscripción/Gasto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTemplateDialog extends StatefulWidget {
  final Function(RecurringTransaction, bool) onSave;
  final RecurringTransaction? existingTemplate;

  const _AddTemplateDialog({required this.onSave, this.existingTemplate});

  @override
  State<_AddTemplateDialog> createState() => _AddTemplateDialogState();
}

class _AddTemplateDialogState extends State<_AddTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _physicalController;
  late TextEditingController _digitalController;
  late TextEditingController _descriptionController;
  late TextEditingController _recurrenceDayController;
  late TextEditingController _customIntervalController; // New

  String _selectedCategory = 'General';
  RecordType _selectedType = RecordType.withdrawal;
  RecurringFrequency _selectedFrequency = RecurringFrequency.monthly;
  RecurringUnit _selectedCustomUnit = RecurringUnit.day; // New
  bool _payNow = false;
  bool _autoPay = false; // New state

  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    final t = widget.existingTemplate;
    _nameController = TextEditingController(text: t?.name ?? '');
    _physicalController = TextEditingController(
      text: t != null && t.physicalAmount > 0
          ? t.physicalAmount.toStringAsFixed(0)
          : '',
    );
    _digitalController = TextEditingController(
      text: t != null && t.digitalAmount > 0
          ? t.digitalAmount.toStringAsFixed(0)
          : '',
    );
    _descriptionController = TextEditingController(text: t?.description ?? '');
    _recurrenceDayController = TextEditingController(
      text: t?.recurrenceDay?.toString() ?? '1',
    );
    _customIntervalController = TextEditingController(
      text: t?.customInterval?.toString() ?? '1',
    );

    if (t != null) {
      _selectedCategory = t.category;
      _selectedType = t.type;
      _selectedFrequency = t.frequency;
      if (t.customUnit != null) _selectedCustomUnit = t.customUnit!;
      _autoPay = t.autoPay; // Load existing state
    }

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await SavingsDataManager().loadCategories();
    if (mounted) {
      setState(() {
        _categories = cats;
        if (!_categories.contains(_selectedCategory)) {
          if (_categories.contains('General')) {
            _selectedCategory = 'General';
          } else if (_categories.isNotEmpty) {
            _selectedCategory = _categories.first;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _physicalController.dispose();
    _digitalController.dispose();
    _descriptionController.dispose();
    _recurrenceDayController.dispose();
    _customIntervalController.dispose(); // New
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      int? day;
      if (_selectedFrequency == RecurringFrequency.monthly) {
        day = int.tryParse(_recurrenceDayController.text);
      }

      int? customInterval;
      RecurringUnit? customUnit;
      if (_selectedFrequency == RecurringFrequency.custom) {
        customInterval = int.tryParse(_customIntervalController.text) ?? 1;
        customUnit = _selectedCustomUnit;
      }

      final physicalClean = _physicalController.text.replaceAll('.', '');
      final digitalClean = _digitalController.text.replaceAll('.', '');
      final physical = double.tryParse(physicalClean) ?? 0;
      final digital = double.tryParse(digitalClean) ?? 0;

      final template = RecurringTransaction(
        id:
            widget.existingTemplate?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        physicalAmount: physical,
        digitalAmount: digital,
        category: _selectedCategory,
        type: _selectedType,
        description: _descriptionController.text,
        frequency: _selectedFrequency,
        recurrenceDay: day,
        customInterval: customInterval,
        customUnit: customUnit,
        startDate: widget.existingTemplate?.startDate ?? DateTime.now(),
        lastProcessedDate: widget.existingTemplate?.lastProcessedDate,
        autoPay: _autoPay, // Save state
      );
      widget.onSave(template, _payNow);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTemplate != null;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, isEditing, l10n),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTypeSelector(context, l10n),
                      const SizedBox(height: 24),
                      // Name Input (Title style)
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la suscripción',
                          hintText: 'ej. Netflix, Luz, Gimnasio',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey[850]
                              : Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(Icons.label_outline),
                        ),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      // Frequency Section
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<RecurringFrequency>(
                              value: _selectedFrequency,
                              decoration: InputDecoration(
                                labelText: 'Frecuencia',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.grey[850]
                                    : Colors.grey[50],
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: RecurringFrequency.monthly,
                                  child: Text('Mensual'),
                                ),
                                DropdownMenuItem(
                                  value: RecurringFrequency.weekly,
                                  child: Text('Semanal'),
                                ),
                                DropdownMenuItem(
                                  value: RecurringFrequency.daily,
                                  child: Text('Diario'),
                                ),
                                DropdownMenuItem(
                                  value: RecurringFrequency.custom,
                                  child: Text('Otro/Manual'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedFrequency = v!),
                            ),
                          ),
                          if (_selectedFrequency ==
                              RecurringFrequency.monthly) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _recurrenceDayController,
                                decoration: InputDecoration(
                                  labelText: 'Día del pago',
                                  hintText: '1-31',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.grey[850]
                                      : Colors.grey[50],
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  final n = int.tryParse(v ?? '');
                                  if (n == null || n < 1 || n > 31)
                                    return 'Inválido';
                                  return null;
                                },
                              ),
                            ),
                          ],
                          if (_selectedFrequency ==
                              RecurringFrequency.custom) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _customIntervalController,
                                decoration: InputDecoration(
                                  labelText: 'Cada',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.grey[850]
                                      : Colors.grey[50],
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  final n = int.tryParse(v ?? '');
                                  if (n == null || n < 1) return 'Err';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<RecurringUnit>(
                                value: _selectedCustomUnit,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.grey[850]
                                      : Colors.grey[50],
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: RecurringUnit.second,
                                    child: Text('Segundos'),
                                  ),
                                  DropdownMenuItem(
                                    value: RecurringUnit.minute,
                                    child: Text('Minutos'),
                                  ),
                                  DropdownMenuItem(
                                    value: RecurringUnit.hour,
                                    child: Text('Horas'),
                                  ),
                                  DropdownMenuItem(
                                    value: RecurringUnit.day,
                                    child: Text('Días'),
                                  ),
                                  DropdownMenuItem(
                                    value: RecurringUnit.week,
                                    child: Text('Semanas'),
                                  ),
                                  DropdownMenuItem(
                                    value: RecurringUnit.month,
                                    child: Text('Meses'),
                                  ),
                                  DropdownMenuItem(
                                    value: RecurringUnit.year,
                                    child: Text('Años'),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _selectedCustomUnit = v!),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildAmountSection(context, l10n),
                      const SizedBox(height: 16),
                      _buildCategorySelector(context, l10n),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Descripción (Opcional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey[850]
                              : Colors.grey[50],
                          prefixIcon: const Icon(Icons.notes),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Auto Pay Checkbox
                      CheckboxListTile(
                        value: _autoPay,
                        onChanged: (v) => setState(() => _autoPay = v == true),
                        title: const Text('Pago Automático (Sin aprobación)'),
                        subtitle: const Text(
                          'Se procesará inmediatamente al vencer sin mostrar diálogo',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        secondary: Icon(
                          Icons.bolt,
                          color: _autoPay ? Colors.amber : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!isEditing)
                        CheckboxListTile(
                          value: _payNow,
                          onChanged: (v) => setState(() => _payNow = v == true),
                          title: const Text('Cobrar primera cuota ahora'),
                          subtitle: const Text(
                            'Se creará un registro en el historial inmediatamente',
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          secondary: const Icon(Icons.flash_on),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isEditing,
    AppLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color headerColor;
    IconData headerIcon;
    switch (_selectedType) {
      case RecordType.deposit:
        headerColor = Colors.green;
        headerIcon = Icons.add_circle;
        break;
      case RecordType.withdrawal:
        headerColor = Colors.red;
        headerIcon = Icons.remove_circle;
        break;
      case RecordType.adjustment:
        headerColor = Colors.blue;
        headerIcon = Icons.sync_alt;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: headerColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(headerIcon, color: headerColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isEditing ? 'Editar Suscripción' : 'Nueva Suscripción',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildTypeOption(
            context,
            RecordType.deposit,
            'INGRESO',
            Icons.add_circle_outline,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTypeOption(
            context,
            RecordType.withdrawal,
            'GASTO / RETIRO',
            Icons.remove_circle_outline,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption(
    BuildContext context,
    RecordType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? Colors.grey[800] : Colors.grey[100];
    final unselectedColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : unselectedBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : unselectedColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : unselectedColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context, AppLocalizations l10n) {
    // Removed unused isDark

    final physicalField = _buildAmountField(
      context,
      controller: _physicalController,
      label: l10n.physicalMoney,
      icon: Icons.account_balance_wallet,
      color: Colors.blue,
    );
    final digitalField = _buildAmountField(
      context,
      controller: _digitalController,
      label: l10n.digitalMoney,
      icon: Icons.credit_card,
      color: Colors.purple,
    );

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.amounts,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              '(${l10n.enterAtLeastOneAmount})',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isDesktop)
          Row(
            children: [
              Expanded(child: physicalField),
              const SizedBox(width: 16),
              Expanded(child: digitalField),
            ],
          )
        else ...[
          physicalField,
          const SizedBox(height: 16),
          digitalField,
        ],
      ],
    );
  }

  Widget _buildAmountField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey[700] : Colors.grey[300];

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: controller.text.isNotEmpty ? color : borderColor!,
          width: controller.text.isNotEmpty ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: controller.text.isEmpty
                        ? (isDark ? Colors.grey[600] : Colors.grey[400])
                        : color,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      ThousandsSeparatorInputFormatter(),
                      LengthLimitingTextInputFormatter(16),
                    ],
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, color: color, size: 24),
                    onPressed: () => setState(() => controller.clear()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: l10n.category,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
        prefixIcon: Icon(
          AppConstants.getCategoryIcon(_selectedCategory),
          color: AppConstants.getCategoryColor(_selectedCategory),
        ),
      ),
      items: _categories
          .map(
            (c) => DropdownMenuItem(
              value: c,
              child: Text(AppLocalizations.of(context)!.translateCategory(c)),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedCategory = v!),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: _selectedType == RecordType.deposit
                  ? Colors.green
                  : Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
