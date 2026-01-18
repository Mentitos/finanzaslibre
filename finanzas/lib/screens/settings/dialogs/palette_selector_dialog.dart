import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as picker;
import '../../../models/color_palette.dart';
import '../../../services/palette_manager.dart';

class PaletteSelectorDialog extends StatefulWidget {
  final ColorPalette currentPalette;
  final Function(ColorPalette) onPaletteSelected;

  const PaletteSelectorDialog({
    super.key,
    required this.currentPalette,
    required this.onPaletteSelected,
  });

  @override
  State<PaletteSelectorDialog> createState() => _PaletteSelectorDialogState();
}

class _PaletteSelectorDialogState extends State<PaletteSelectorDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ColorPalette> _customPalettes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCustomPalettes();
  }

  Future<void> _loadCustomPalettes() async {
    final palettes = await PaletteManager.loadCustomPalettes();
    if (mounted) {
      setState(() {
        _customPalettes = palettes;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxHeight: 650, maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.currentPalette.seedColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.palette,
                    color: widget.currentPalette.seedColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Paleta de Colores',
                      style: TextStyle(
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
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.currentPalette.seedColor,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: isDark
                    ? Colors.grey[400]
                    : Colors.grey[700],
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Predeterminadas'),
                  Tab(text: 'Personalizado'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPredefinedPalettesTab(),
                  _buildCustomPaletteTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredefinedPalettesTab() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: ColorPalette.predefinedPalettes.length,
      itemBuilder: (context, index) {
        final palette = ColorPalette.predefinedPalettes[index];
        final isSelected = palette.id == widget.currentPalette.id;

        return _buildPaletteCard(palette, isSelected, false);
      },
    );
  }

  Widget _buildCustomPaletteTab() {
    return Column(
      children: [
        // Botón crear nueva
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: ElevatedButton.icon(
            onPressed: _showCreateCustomPaletteDialog,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Crear Personalizada'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: widget.currentPalette.seedColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),

        // Lista de paletas personalizadas
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _customPalettes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay paletas personalizadas',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _customPalettes.length,
                  itemBuilder: (context, index) {
                    final palette = _customPalettes[index];
                    final isSelected = palette.id == widget.currentPalette.id;
                    return _buildPaletteCard(palette, isSelected, true);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPaletteCard(
    ColorPalette palette,
    bool isSelected,
    bool isCustom,
  ) {
    return InkWell(
      onTap: () async {
        await PaletteManager.savePalette(palette);
        widget.onPaletteSelected(palette);
        if (mounted) Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? palette.seedColor : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          gradient: LinearGradient(
            colors: [
              palette.seedColor.withOpacity(0.3),
              palette.seedColor.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Contenido - SIN COLUMN OVERFLOW
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Círculo de color
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: palette.seedColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: palette.seedColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Nombre
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      palette.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Hex (solo para custom)
                  if (isCustom && palette.customHex != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      palette.customHex!,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),

            // Edit Button (Only for Custom)
            if (isCustom)
              Positioned(
                top: 4,
                left: 4,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        _showCreateCustomPaletteDialog(paletteToEdit: palette),
                    onLongPress: () => _showDeletePaletteDialog(palette),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),

            // Check de selección
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: palette.seedColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),

            // Icono de eliminar (solo custom)
          ],
        ),
      ),
    );
  }

  void _showCreateCustomPaletteDialog({ColorPalette? paletteToEdit}) {
    showDialog(
      context: context,
      builder: (context) => _CustomPaletteCreatorDialog(
        currentPalette: widget.currentPalette,
        paletteToEdit: paletteToEdit,
        onPaletteCreated: (newPalette) async {
          await PaletteManager.saveCustomPalette(newPalette);
          _loadCustomPalettes();
        },
      ),
    );
  }

  void _showDeletePaletteDialog(ColorPalette palette) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Paleta'),
        content: Text('¿Eliminar "${palette.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await PaletteManager.deleteCustomPalette(palette.id);
              if (mounted) {
                Navigator.pop(context);
                _loadCustomPalettes();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// CREADOR DE PALETA CON PICKER MEJORADO
// ============================================

class _CustomPaletteCreatorDialog extends StatefulWidget {
  final ColorPalette currentPalette;
  final ColorPalette? paletteToEdit; // Optional, for editing
  final Function(ColorPalette) onPaletteCreated;

  const _CustomPaletteCreatorDialog({
    required this.currentPalette,
    this.paletteToEdit,
    required this.onPaletteCreated,
  });

  @override
  State<_CustomPaletteCreatorDialog> createState() =>
      _CustomPaletteCreatorDialogState();
}

class _CustomPaletteCreatorDialogState
    extends State<_CustomPaletteCreatorDialog> {
  final _nameController = TextEditingController();
  final _hexController = TextEditingController();
  Color _previewColor = const Color(0xFFFF004A);
  bool _useWhiteText = true;
  bool _affectTotalCard = false;

  @override
  void initState() {
    super.initState();
    if (widget.paletteToEdit != null) {
      _nameController.text = widget.paletteToEdit!.name;
      _previewColor = widget.paletteToEdit!.seedColor;
      _hexController.text = _toHex(_previewColor);
      _useWhiteText = widget.paletteToEdit!.useWhiteText;
      _affectTotalCard = widget.paletteToEdit!.affectTotalCard;
    } else {
      _hexController.text = '#FF004A';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  // Helper to format Color to Hex string
  String _toHex(Color color) =>
      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.create, color: _previewColor),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Paleta Personalizada',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nombre
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Paleta',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  maxLength: 20,
                ),
                const SizedBox(height: 12),

                // HEX FIELD (Replacing "Elige tu color")
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _hexController,
                        decoration: InputDecoration(
                          labelText: 'Color Hex',
                          prefixIcon: const Icon(Icons.tag),
                          border: const OutlineInputBorder(),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: _hexController.text),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copiado al portapapeles'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                tooltip: 'Copiar',
                              ),
                              IconButton(
                                icon: const Icon(Icons.content_paste, size: 20),
                                onPressed: () async {
                                  final data = await Clipboard.getData(
                                    'text/plain',
                                  );
                                  if (data?.text != null) {
                                    final text = data!.text!;
                                    _hexController.text = text;
                                    // Parse Hex to Color for Preview
                                    try {
                                      String clean = text
                                          .replaceAll('#', '')
                                          .toUpperCase();
                                      if (clean.length == 6) {
                                        setState(() {
                                          _previewColor = Color(
                                            int.parse('FF$clean', radix: 16),
                                          );
                                        });
                                      }
                                    } catch (_) {}
                                  }
                                },
                                tooltip: 'Pegar',
                              ),
                            ],
                          ),
                        ),
                        onChanged: (value) {
                          try {
                            String clean = value
                                .replaceAll('#', '')
                                .toUpperCase();
                            if (clean.length == 6) {
                              setState(() {
                                _previewColor = Color(
                                  int.parse('FF$clean', radix: 16),
                                );
                              });
                            }
                          } catch (_) {}
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                picker.ColorPicker(
                  pickerColor: _previewColor,
                  onColorChanged: (color) {
                    setState(() {
                      _previewColor = color;
                      _hexController.text =
                          '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                    });
                  },
                  showLabel: false,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: false,
                  displayThumbColor: true,
                  paletteType: picker.PaletteType.hsvWithHue,
                ),

                // Vista previa grande
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_previewColor, _previewColor.withOpacity(0.6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Vista Previa',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Mock AppBar Preview
                      Container(
                        width: 200,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _previewColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.menu,
                              color: _useWhiteText
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _nameController.text.isEmpty
                                    ? 'Título'
                                    : _nameController.text,
                                style: TextStyle(
                                  color: _useWhiteText
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Switch Texto Blanco
                SwitchListTile(
                  title: const Text('Usar Texto Blanco'),
                  value: _useWhiteText,
                  onChanged: (value) => setState(() => _useWhiteText = value),
                  activeColor: _previewColor,
                ),

                // Switch Colorear Total Principal
                SwitchListTile(
                  title: const Text('Colorear Total Principal'),
                  subtitle: const Text(
                    'Aplica el color seleccionado a la tarjeta de balance total.',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _affectTotalCard,
                  onChanged: (value) =>
                      setState(() => _affectTotalCard = value),
                  activeColor: _previewColor,
                ),
                const SizedBox(height: 16),

                // Colores sugeridos
                const Text(
                  'Colores sugeridos:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickColor(
                      const Color(0xFFFF004A),
                      '#FF004A',
                    ), // Fucsia
                    _buildQuickColor(
                      const Color(0xFFE91E63),
                      '#E91E63',
                    ), // Pink
                    _buildQuickColor(
                      const Color(0xFF9C27B0),
                      '#9C27B0',
                    ), // Purple
                    _buildQuickColor(
                      const Color(0xFF673AB7),
                      '#673AB7',
                    ), // Deep Purple
                    _buildQuickColor(
                      const Color(0xFF3F51B5),
                      '#3F51B5',
                    ), // Indigo
                    _buildQuickColor(
                      const Color(0xFF2196F3),
                      '#2196F3',
                    ), // Blue
                    _buildQuickColor(
                      const Color(0xFF00BCD4),
                      '#00BCD4',
                    ), // Cyan
                    _buildQuickColor(
                      const Color(0xFF009688),
                      '#009688',
                    ), // Teal
                    _buildQuickColor(
                      const Color(0xFF4CAF50),
                      '#4CAF50',
                    ), // Green
                    _buildQuickColor(
                      const Color(0xFF8BC34A),
                      '#8BC34A',
                    ), // Light Green
                    _buildQuickColor(
                      const Color(0xFFFF9800),
                      '#FF9800',
                    ), // Orange
                    _buildQuickColor(
                      const Color(0xFFFF5722),
                      '#FF5722',
                    ), // Deep Orange
                  ],
                ),
                const SizedBox(height: 24),

                // Botones 50/50
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: _createPalette,
                          style: FilledButton.styleFrom(
                            backgroundColor: _previewColor,
                            foregroundColor: _useWhiteText
                                ? Colors.white
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            widget.paletteToEdit != null ? 'Editar' : 'Crear',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickColor(Color color, String hex) {
    final isSelected = _previewColor.value == color.value;

    return InkWell(
      onTap: () {
        setState(() {
          _previewColor = color;
          _hexController.text = hex;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  void _createPalette() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un nombre')));
      return;
    }

    final palette = ColorPalette(
      // Keep ID if editing, otherwise generate new one
      id:
          widget.paletteToEdit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      type: PaletteType.custom,
      seedColor: _previewColor,
      customHex: _hexController.text,
      useWhiteText: _useWhiteText,
      affectTotalCard: _affectTotalCard,
    );

    widget.onPaletteCreated(palette);
    Navigator.pop(context);
  }
}
