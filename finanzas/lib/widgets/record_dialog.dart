import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/savings_record.dart';
import '../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_translations.dart';
import '../models/recurring_transaction.dart';
import '../utils/input_formatters.dart';

class RecordDialog extends StatefulWidget {
  final Function(SavingsRecord) onSave;
  final List<String> categories;
  final Map<String, Color>? categoryColors;
  final Map<String, IconData>? categoryIcons;
  final SavingsRecord? record;
  final String? initialCategory;
  final RecurringTransaction? template; // New parameter
  final double? currentPhysicalBalance;
  final double? currentDigitalBalance;

  const RecordDialog({
    super.key,
    required this.onSave,
    required this.categories,
    this.categoryColors,
    this.categoryIcons,
    this.record,
    this.initialCategory,
    this.template, // New parameter
    this.currentPhysicalBalance,
    this.currentDigitalBalance,
  });

  @override
  State<RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<RecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _physicalController = TextEditingController();
  final _digitalController = TextEditingController();
  final _descriptionController = TextEditingController();

  RecordType _selectedType = RecordType.deposit;
  String _selectedCategory = 'General';
  bool _isLoading = false;

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (_isEditing) {
      final record = widget.record!;
      _physicalController.text = record.physicalAmount != 0
          ? _formatNumberWithDots(record.physicalAmount.toStringAsFixed(0))
          : '';
      _digitalController.text = record.digitalAmount != 0
          ? _formatNumberWithDots(record.digitalAmount.toStringAsFixed(0))
          : '';
      _descriptionController.text = record.description;
      _selectedType = record.type;
      _selectedCategory = record.category;

      if (_selectedType == RecordType.adjustment) {
        // If editing an adjustment, show the stored deltas
        _physicalController.text = record.physicalAmount != 0
            ? SignedThousandsSeparatorInputFormatter()
                  .formatEditUpdate(
                    TextEditingValue.empty,
                    TextEditingValue(
                      text: record.physicalAmount.toStringAsFixed(0),
                    ),
                  )
                  .text
            : '';
        _digitalController.text = record.digitalAmount != 0
            ? SignedThousandsSeparatorInputFormatter()
                  .formatEditUpdate(
                    TextEditingValue.empty,
                    TextEditingValue(
                      text: record.digitalAmount.toStringAsFixed(0),
                    ),
                  )
                  .text
            : '';
      }
    } else {
      _selectedCategory =
          widget.initialCategory ??
          (widget.categories.isNotEmpty ? widget.categories.first : 'General');
    }
  }

  void _onTypeChanged(RecordType newType) {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _selectedType = newType;
      if (newType == RecordType.adjustment && !_isEditing) {
        _physicalController.text = widget.currentPhysicalBalance != null
            ? _formatNumberWithDots(
                widget.currentPhysicalBalance!.toStringAsFixed(0),
              )
            : '';
        _digitalController.text = widget.currentDigitalBalance != null
            ? _formatNumberWithDots(
                widget.currentDigitalBalance!.toStringAsFixed(0),
              )
            : '';
        _descriptionController.text = l10n.adjustment;
      } else if (newType != RecordType.adjustment) {
        _physicalController.clear();
        _digitalController.clear();
        if (_descriptionController.text == l10n.adjustment) {
          _descriptionController.clear();
        }
      }
    });
  }

  String _formatNumberWithDots(String number) {
    if (number.isEmpty) return number;
    String reversed = number.split('').reversed.join();
    String formatted = '';

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += '.';
      }
      formatted += reversed[i];
    }

    return formatted.split('').reversed.join();
  }

  @override
  void dispose() {
    _physicalController.dispose();
    _digitalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isDesktop ? 800 : screenWidth * 0.95,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, l10n),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTypeSelector(context, l10n),
                      const SizedBox(height: 32),
                      _buildAmountSection(context, l10n, isDesktop),
                      const SizedBox(height: 32),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildCategorySelector(context, l10n),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildDescriptionInput(context, l10n),
                            ),
                          ],
                        )
                      else ...[
                        _buildCategorySelector(context, l10n),
                        const SizedBox(height: 24),
                        _buildDescriptionInput(context, l10n),
                      ],
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

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    Color headerColor;
    IconData headerIcon;
    Color iconColor;

    switch (_selectedType) {
      case RecordType.deposit:
        headerColor = Colors.green;
        headerIcon = _isEditing ? Icons.edit : Icons.add_circle;
        break;
      case RecordType.withdrawal:
        headerColor = Colors.red;
        headerIcon = _isEditing ? Icons.edit : Icons.remove_circle;
        break;
      case RecordType.adjustment:
        headerColor = Colors.blue;
        headerIcon = _isEditing ? Icons.edit : Icons.sync_alt;
        break;
    }
    iconColor = headerColor;

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
          Icon(headerIcon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _isEditing ? l10n.editRecord : l10n.newRecord,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.operationType,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                context,
                RecordType.deposit,
                l10n.depositUpper,
                Icons.add_circle_outline,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTypeOption(
                context,
                RecordType.withdrawal,
                l10n.withdrawalUpper,
                Icons.remove_circle_outline,
                Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTypeOption(
                context,
                RecordType.adjustment,
                l10n.adjustmentUpper,
                Icons.sync_alt,
                Colors.blue,
              ),
            ),
          ],
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
    final unselectedBorder = isDark ? Colors.grey[700] : Colors.grey[300];
    final unselectedColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return GestureDetector(
      onTap: () => _onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : unselectedBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : unselectedBorder!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : unselectedColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
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

  Widget _buildAmountSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final isAdjustment = _selectedType == RecordType.adjustment;

    final physicalField = _buildAmountField(
      context,
      l10n,
      controller: _physicalController,
      label: l10n.physicalMoney,
      icon: Icons.account_balance_wallet,
      color: Colors.blue,
    );

    final digitalField = _buildAmountField(
      context,
      l10n,
      controller: _digitalController,
      label: l10n.digitalMoney,
      icon: Icons.credit_card,
      color: Colors.purple,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isAdjustment ? l10n.newBalance : l10n.amounts,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (!isAdjustment) ...[
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
          ],
        ),
        const SizedBox(height: 16),
        if (isDesktop)
          Row(
            children: [
              Expanded(child: physicalField),
              const SizedBox(width: 20),
              Expanded(child: digitalField),
            ],
          )
        else ...[
          physicalField,
          const SizedBox(height: 16),
          digitalField,
        ],
        if (isAdjustment) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.adjustmentInfo,
                    style: TextStyle(fontSize: 13, color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAmountField(
    BuildContext context,
    AppLocalizations l10n, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey[700] : Colors.grey[300];
    final isAdjustment = _selectedType == RecordType.adjustment;

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
                    keyboardType: isAdjustment
                        ? const TextInputType.numberWithOptions(signed: true)
                        : TextInputType.number,
                    inputFormatters: [
                      isAdjustment
                          ? SignedThousandsSeparatorInputFormatter()
                          : ThousandsSeparatorInputFormatter(),
                      LengthLimitingTextInputFormatter(16),
                    ],
                    validator: (value) {
                      if (_selectedType != RecordType.adjustment) {
                        final physicalClean = _physicalController.text
                            .replaceAll('.', '');
                        final digitalClean = _digitalController.text.replaceAll(
                          '.',
                          '',
                        );
                        final physical = double.tryParse(physicalClean) ?? 0;
                        final digital = double.tryParse(digitalClean) ?? 0;
                        if (physical == 0 && digital == 0) return '';
                      }
                      return null;
                    },
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

    if (_selectedType == RecordType.adjustment) {
      return TextFormField(
        initialValue: l10n.translateCategory('General'),
        enabled: false,
        decoration: InputDecoration(
          labelText: l10n.category,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          // prefixIcon: const Icon(Icons.tune), // Descomentar si se quiere ícono
        ),
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: l10n.category,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: widget.categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Row(
            children: [
              Icon(
                AppConstants.getCategoryIcon(category, widget.categoryIcons),
                color: _getCategoryColor(category),
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.translateCategory(category)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value!),
      validator: (value) => value == null ? l10n.selectCategory : null,
    );
  }

  Widget _buildDescriptionInput(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: l10n.description,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        prefixIcon: const Icon(Icons.description),
        hintText: l10n.descriptionHintRecord,
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      minLines: 1,
      maxLines: 3,
      maxLength: 100,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color buttonColor;
    switch (_selectedType) {
      case RecordType.deposit:
        buttonColor = Colors.green;
        break;
      case RecordType.withdrawal:
        buttonColor = Colors.red;
        break;
      case RecordType.adjustment:
        buttonColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(l10n.cancel),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _isLoading ? null : () => _saveRecord(l10n),
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEditing ? l10n.update : l10n.save,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveRecord(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.mustEnterAtLeastOneAmount),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    final physicalClean = _physicalController.text.replaceAll('.', '');
    final digitalClean = _digitalController.text.replaceAll('.', '');
    final newPhysical = double.tryParse(physicalClean) ?? 0;
    final newDigital = double.tryParse(digitalClean) ?? 0;

    double physicalAmountToSave = newPhysical;
    double digitalAmountToSave = newDigital;
    RecordType typeToSave = _selectedType;

    if (_selectedType == RecordType.adjustment) {
      final physicalDelta = newPhysical - (widget.currentPhysicalBalance ?? 0);
      final digitalDelta = newDigital - (widget.currentDigitalBalance ?? 0);

      if (physicalDelta == 0 && digitalDelta == 0) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.localeName == 'es'
                  ? 'No hay cambios en el balance'
                  : 'No balance changes detected',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      physicalAmountToSave = physicalDelta;
      digitalAmountToSave = digitalDelta;
    }

    final record = SavingsRecord(
      id: _isEditing
          ? widget.record!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      physicalAmount: physicalAmountToSave,
      digitalAmount: digitalAmountToSave,
      description: _descriptionController.text.trim(),
      createdAt: _isEditing ? widget.record!.createdAt : DateTime.now(),
      type: typeToSave,
      category: _selectedType == RecordType.adjustment
          ? 'General'
          : _selectedCategory,
      notes: null,
    );

    widget.onSave(record);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Color _getCategoryColor(String category) {
    return AppConstants.getCategoryColor(category, widget.categoryColors);
  }
}
