import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/savings_goal_model.dart';
import '../../l10n/app_localizations.dart';

class GoalDialog extends StatefulWidget {
  final SavingsGoal? goal;
  final Function(SavingsGoal) onSave;

  const GoalDialog({
    super.key,
    this.goal,
    required this.onSave,
  });

  @override
  State<GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<GoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  
  String _selectedEmoji = '🎯';
  DateTime? _deadline;
  bool _isLoading = false;

  final List<String> _emojiOptions = [
    '🎯', '💰', '🏠', '🚗', '✈️', '🎓', '💍', '🎮', 
    '📱', '💻', '🎸', '🏖️', '🏥', '👶', '🎄', '🎁'
  ];

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final goal = widget.goal!;
      _nameController.text = goal.name;
      _descriptionController.text = goal.description ?? '';
      _targetAmountController.text = goal.targetAmount.toStringAsFixed(0);
      _selectedEmoji = goal.emoji;
      _deadline = goal.deadline;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
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
                      _buildEmojiSelector(context),
                      const SizedBox(height: 20),
                      _buildNameInput(context, l10n),
                      const SizedBox(height: 16),
                      _buildDescriptionInput(context, l10n),
                      const SizedBox(height: 16),
                      _buildTargetAmountInput(context, l10n),
                      const SizedBox(height: 16),
                      _buildDeadlineSelector(context, l10n),
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
        color: Colors.green.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flag, color: Colors.green, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isEditing ? 'Editar Meta' : 'Nueva Meta',
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

  Widget _buildEmojiSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icono',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _emojiOptions.map((emoji) {
            final isSelected = emoji == _selectedEmoji;
            return InkWell(
              onTap: () => setState(() => _selectedEmoji = emoji),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green.withOpacity(0.2) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNameInput(BuildContext context, AppLocalizations l10n) {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nombre de la meta',
        hintText: 'Ej: Vacaciones 2025',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      textCapitalization: TextCapitalization.words,
      maxLength: 50,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingresa un nombre para la meta';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionInput(BuildContext context, AppLocalizations l10n) {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descripción (opcional)',
        hintText: 'Detalles de tu meta',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 2,
      maxLength: 100,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildTargetAmountInput(BuildContext context, AppLocalizations l10n) {
    return TextFormField(
      controller: _targetAmountController,
      decoration: const InputDecoration(
        labelText: 'Monto objetivo',
        hintText: '0',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
        prefixText: '\$',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa el monto objetivo';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Ingresa un monto válido';
        }
        return null;
      },
    );
  }

  Widget _buildDeadlineSelector(BuildContext context, AppLocalizations l10n) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (picked != null) {
          setState(() => _deadline = picked);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _deadline != null ? Colors.green : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha límite (opcional)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _deadline != null
                        ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                        : 'Sin fecha límite',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _deadline != null ? FontWeight.w600 : FontWeight.normal,
                      color: _deadline != null ? Colors.green : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (_deadline != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => setState(() => _deadline = null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              onPressed: _isLoading ? null : _saveGoal,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
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
                      _isEditing ? 'Actualizar' : 'Crear Meta',
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

  void _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final targetAmount = double.parse(_targetAmountController.text);

    final goal = _isEditing
        ? widget.goal!.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty 
                ? null 
                : _descriptionController.text.trim(),
            targetAmount: targetAmount,
            deadline: _deadline,
            emoji: _selectedEmoji,
          )
        : SavingsGoal(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty 
                ? null 
                : _descriptionController.text.trim(),
            targetAmount: targetAmount,
            createdAt: DateTime.now(),
            deadline: _deadline,
            emoji: _selectedEmoji,
          );

    widget.onSave(goal);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}