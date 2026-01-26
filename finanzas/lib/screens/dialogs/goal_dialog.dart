import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/color_palette.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import '../../models/savings_goal_model.dart';
import '../../l10n/app_localizations.dart';

class GoalDialog extends StatefulWidget {
  final SavingsGoal? goal;
  final ColorPalette palette;
  final Function(SavingsGoal) onSave;

  const GoalDialog({
    super.key,
    this.goal,
    required this.palette,
    required this.onSave,
  });

  @override
  State<GoalDialog> createState() => _GoalDialogState();
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Si está vacío, devolver igual
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Eliminar puntos viejos
    String cleanText = newValue.text.replaceAll('.', '');

    // Intentar parsear el número
    int? value = int.tryParse(cleanText);
    if (value == null) return oldValue;

    // Formatear con puntos
    final newString = _formatWithDots(value.toString());

    // Calcular nueva posición del cursor
    int selectionIndex =
        newString.length - (cleanText.length - newValue.selection.end);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  /// Función auxiliar: agrega puntos cada 3 dígitos
  String _formatWithDots(String number) {
    final chars = number.split('').reversed.toList();
    final buffer = StringBuffer();

    for (int i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write('.');
      buffer.write(chars[i]);
    }

    return buffer.toString().split('').reversed.join();
  }
}

class _GoalDialogState extends State<GoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();

  String _selectedEmoji = '🎯';
  String? _imagePath;
  DateTime? _deadline;
  bool _isLoading = false;

  final List<String> _emojiOptions = [
    '🎯',
    '💰',
    '🏠',
    '🚗',
    '✈️',
    '🎓',
    '💍',
    '🎮',
    '📱',
    '💻',
    '🎸',
    '🏖️',
    '🏥',
    '👶',
    '🎄',
    '🎁',
  ];

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final goal = widget.goal!;
      _nameController.text = goal.name;
      _descriptionController.text = goal.description ?? '';

      _targetAmountController.text = _formatNumberWithDots(
        goal.targetAmount.toStringAsFixed(0),
      );
      _selectedEmoji = goal.emoji;
      _imagePath = goal.imagePath;
      _deadline = goal.deadline;
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
        color: widget.palette.seedColor.withValues(alpha: 0.1),
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
              color: widget.palette.seedColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.flag, color: widget.palette.seedColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isEditing ? 'Editar Meta' : 'Nueva Meta',
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

  Widget _buildEmojiSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icono e Imagen',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._emojiOptions.map((emoji) {
              final isSelected = emoji == _selectedEmoji;
              return InkWell(
                onTap: () => setState(() => _selectedEmoji = emoji),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Fondo transparente siempre
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors
                                      .white // Relieve Blanco en Dark Mode
                                : Colors.black) // Relieve Negro en Light Mode
                          : Colors.transparent,
                      width: isSelected ? 2 : 0,
                    ),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            }),
            // Botón de + para emoji personalizado
            InkWell(
              onTap: _showCustomEmojiInput,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !_emojiOptions.contains(_selectedEmoji)
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                        : Colors
                              .grey[400]!, // Borde gris si no está seleccionado
                    width: !_emojiOptions.contains(_selectedEmoji)
                        ? 2
                        : 1, // Borde más grueso si es seleccionado personalizado
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            // Selector de Imagen (Ahora dentro del Wrap)
            InkWell(
              onTap: _showImageSourceDialog,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: _imagePath != null
                      ? DecorationImage(
                          image: FileImage(File(_imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _imagePath == null
                    ? Icon(Icons.camera_alt, color: Colors.grey[600], size: 24)
                    : null,
              ),
            ),
          ],
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
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
        ThousandsSeparatorInputFormatter(), // 🔥 AGREGAR FORMATEO
        LengthLimitingTextInputFormatter(15),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa el monto objetivo';
        }
        // 🔥 LIMPIAR PUNTOS ANTES DE VALIDAR
        final cleanValue = value.replaceAll('.', '');
        final amount = double.tryParse(cleanValue);
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
          initialDate:
              _deadline ?? DateTime.now().add(const Duration(days: 30)),
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
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _deadline != null
                        ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                        : 'Sin fecha límite',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _deadline != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: _deadline != null
                          ? Colors.green
                          : Colors.grey[600],
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
                backgroundColor: () {
                  final hsl = HSLColor.fromColor(widget.palette.seedColor);
                  final isLight =
                      Theme.of(context).brightness == Brightness.light;
                  // Light Mode: Darken slightly (0.05) to ensure readability
                  // Dark Mode: Lighten slightly (0.05) to ensure visibility
                  final lightness = isLight
                      ? (hsl.lightness - 0.05).clamp(0.0, 1.0)
                      : (hsl.lightness + 0.05).clamp(0.0, 1.0);

                  return hsl.withLightness(lightness).toColor();
                }(),
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

    // 🔥 LIMPIAR PUNTOS ANTES DE PARSEAR
    final cleanAmount = _targetAmountController.text.replaceAll('.', '');
    final targetAmount = double.parse(cleanAmount);

    final goal = _isEditing
        ? widget.goal!.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            targetAmount: targetAmount,
            deadline: _deadline,
            emoji: _selectedEmoji,
            imagePath: _imagePath,
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
            imagePath: _imagePath,
          );

    widget.onSave(goal);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _showCustomEmojiInput() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emoji Personalizado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Escribe o pega tu emoji aquí:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32),
              maxLength: 2, // Limitar a 1-2 caracteres para emojis
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _selectedEmoji = controller.text;
                });
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Usar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Eliminar Foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  setState(() => _imagePath = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }
}
