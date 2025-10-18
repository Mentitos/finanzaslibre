import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/savings_record.dart';
import '../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_translations.dart';


class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    
    String text = newValue.text.replaceAll('.', '');
    
    
    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return oldValue;
    }

    
    String formatted = _formatWithThousands(text);
    
    
    int selectionIndex = newValue.selection.end;
    int oldDots = oldValue.text.substring(0, oldValue.selection.end).split('.').length - 1;
    int newDots = formatted.substring(0, selectionIndex + (formatted.split('.').length - 1 - oldDots)).split('.').length - 1;
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: selectionIndex + newDots - oldDots,
      ),
    );
  }

  String _formatWithThousands(String text) {
    if (text.isEmpty) return text;
    
    
    String reversed = text.split('').reversed.join();
    String formatted = '';
    
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += '.';
      }
      formatted += reversed[i];
    }
    
    
    return formatted.split('').reversed.join();
  }
}

class RecordDialog extends StatefulWidget {
  final Function(SavingsRecord) onSave;
  final List<String> categories;
  final Map<String, Color>? categoryColors;
  final SavingsRecord? record;
  final String? initialCategory;

  const RecordDialog({
    super.key,
    required this.onSave,
    required this.categories,
    this.categoryColors,
    this.record,
    this.initialCategory,
  });

  @override
  State<RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<RecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _physicalController = TextEditingController();
  final _digitalController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

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
      _physicalController.text = record.physicalAmount > 0
          ? _formatNumberWithDots(record.physicalAmount.toStringAsFixed(0))
          : '';
      _digitalController.text = record.digitalAmount > 0
          ? _formatNumberWithDots(record.digitalAmount.toStringAsFixed(0))
          : '';
      _descriptionController.text = record.description;
      _notesController.text = record.notes ?? '';
      _selectedType = record.type;
      _selectedCategory = record.category;
    } else {
      _selectedCategory = widget.initialCategory ??
          (widget.categories.isNotEmpty ? widget.categories.first : 'General');
    }
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
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, l10n),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTypeSelector(context, l10n),
                      const SizedBox(height: 24),
                      _buildAmountSection(context, l10n),
                      const SizedBox(height: 24),
                      _buildCategorySelector(context, l10n),
                      const SizedBox(height: 20),
                      _buildDescriptionInput(context, l10n),
                      const SizedBox(height: 16),
                      _buildNotesInput(context, l10n),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (_selectedType == RecordType.deposit ? Colors.green : Colors.red)
            .withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isEditing ? Icons.edit : Icons.add_circle,
            color: _selectedType == RecordType.deposit ? Colors.green : Colors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isEditing ? l10n.editRecord : l10n.newRecord,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
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
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(
                context,
                RecordType.withdrawal,
                l10n.withdrawalUpper,
                Icons.remove_circle_outline,
                Colors.red,
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
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : unselectedBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : unselectedBorder!,
            width: isSelected ? 2 : 1,
          ),
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context, AppLocalizations l10n) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.amounts,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildAmountField(
          context,
          l10n,
          controller: _physicalController,
          label: l10n.physicalMoney,
          icon: Icons.account_balance_wallet,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildAmountField(
          context,
          l10n,
          controller: _digitalController,
          label: l10n.digitalMoney,
          icon: Icons.credit_card,
          color: Colors.purple,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.enterAtLeastOneAmount,
                  style: TextStyle(fontSize: 12, color: textColor),
                ),
              ),
            ],
          ),
        ),
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
    
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.text.isNotEmpty ? color : borderColor!,
          width: controller.text.isNotEmpty ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 32,
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
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      
                      ThousandsSeparatorInputFormatter(),
                      LengthLimitingTextInputFormatter(15),
                    ],
                    validator: (value) {
                     
                      final physicalClean = _physicalController.text.replaceAll('.', '');
                      final digitalClean = _digitalController.text.replaceAll('.', '');
                      final physical = double.tryParse(physicalClean) ?? 0;
                      final digital = double.tryParse(digitalClean) ?? 0;
                      if (physical == 0 && digital == 0) return '';
                      return null;
                    },
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, color: color, size: 20),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.category),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
      ),
      items: widget.categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.translateCategory(category))

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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.description),
        hintText: l10n.descriptionHintRecord,
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
      ),
      maxLines: 2,
      maxLength: 100,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildNotesInput(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: _notesController,
      decoration: InputDecoration(
        labelText: l10n.additionalNotes,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.note_add),
        hintText: l10n.additionalNotesHint,
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
      ),
      maxLines: 3,
      maxLength: 200,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.cancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _isLoading ? null : () => _saveRecord(l10n),
              style: FilledButton.styleFrom(
                backgroundColor: _selectedType == RecordType.deposit 
                    ? Colors.green 
                    : Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
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
    final physical = double.tryParse(physicalClean) ?? 0;
    final digital = double.tryParse(digitalClean) ?? 0;

    final record = SavingsRecord(
      id: _isEditing
          ? widget.record!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      physicalAmount: physical,
      digitalAmount: digital,
      description: _descriptionController.text.trim(),
      createdAt: _isEditing ? widget.record!.createdAt : DateTime.now(),
      type: _selectedType,
      category: _selectedCategory,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
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