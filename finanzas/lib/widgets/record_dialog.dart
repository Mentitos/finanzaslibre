import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/savings_record.dart';
import '../constants/app_constants.dart';

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
          ? record.physicalAmount.toStringAsFixed(0)
          : '';
      _digitalController.text = record.digitalAmount > 0
          ? record.digitalAmount.toStringAsFixed(0)
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTypeSelector(),
                      const SizedBox(height: 24),
                      _buildAmountSection(),
                      const SizedBox(height: 24),
                      _buildCategorySelector(),
                      const SizedBox(height: 20),
                      _buildDescriptionInput(),
                      const SizedBox(height: 16),
                      _buildNotesInput(),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              _isEditing ? 'Editar Registro' : 'Nuevo Registro',
              style: const TextStyle(
                fontSize: 20,
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

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de operación',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                RecordType.deposit,
                'DEPÓSITO',
                Icons.add_circle_outline,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(
                RecordType.withdrawal,
                'RETIRO',
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
    RecordType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Montos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildAmountField(
          controller: _physicalController,
          label: 'Dinero Físico',
          icon: Icons.account_balance_wallet,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildAmountField(
          controller: _digitalController,
          label: 'Dinero Digital',
          icon: Icons.credit_card,
          color: Colors.purple,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Ingresa al menos un monto',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.text.isNotEmpty ? color : Colors.grey[300]!,
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
                    color: controller.text.isEmpty ? Colors.grey[400] : color,
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
                        color: Colors.grey[300],
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
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      final physical = double.tryParse(_physicalController.text) ?? 0;
                      final digital = double.tryParse(_digitalController.text) ?? 0;

                      if (physical == 0 && digital == 0) {
                        return '';
                      }
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

  Widget _buildCategorySelector() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.category),
        filled: true,
        fillColor: Colors.grey[50],
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
              Text(category),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value!),
      validator: (value) => value == null ? 'Selecciona una categoría' : null,
    );
  }

  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Descripción',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.description),
        hintText: 'Ej: Ahorro mensual, gastos varios...',
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: 2,
      maxLength: 100,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildNotesInput() {
    return TextFormField(
      controller: _notesController,
      decoration: InputDecoration(
        labelText: 'Notas adicionales (opcional)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.note_add),
        hintText: 'Información extra...',
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: 3,
      maxLength: 200,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
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
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _isLoading ? null : _saveRecord,
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
                      _isEditing ? 'Actualizar' : 'Guardar',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes ingresar al menos una cantidad'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    final physical = double.tryParse(_physicalController.text) ?? 0;
    final digital = double.tryParse(_digitalController.text) ?? 0;

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