import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/color_palette.dart';
import '../../../services/palette_manager.dart';
import '../../../l10n/app_localizations.dart';

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
                unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[700],
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                          Icon(Icons.palette_outlined,
                              size: 64, color: Colors.grey[400]),
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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

  Widget _buildPaletteCard(ColorPalette palette, bool isSelected, bool isCustom) {
    return InkWell(
      onTap: () async {
        await PaletteManager.savePalette(palette);
        widget.onPaletteSelected(palette);
        if (mounted) Navigator.pop(context);
      },
      onLongPress: isCustom ? () => _showDeletePaletteDialog(palette) : null,
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
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
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
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),

            // Icono de eliminar (solo custom)
            if (isCustom && !isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCreateCustomPaletteDialog() {
    showDialog(
      context: context,
      builder: (context) => _CustomPaletteCreatorDialog(
        onPaletteCreated: (palette) async {
          await PaletteManager.saveCustomPalette(palette);
          await _loadCustomPalettes();
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
          FilledButton(
            onPressed: () async {
              await PaletteManager.deleteCustomPalette(palette.id);
              await _loadCustomPalettes();
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
  final Function(ColorPalette) onPaletteCreated;

  const _CustomPaletteCreatorDialog({required this.onPaletteCreated});

  @override
  State<_CustomPaletteCreatorDialog> createState() =>
      _CustomPaletteCreatorDialogState();
}

class _CustomPaletteCreatorDialogState
    extends State<_CustomPaletteCreatorDialog> {
  final _nameController = TextEditingController();
  final _hexController = TextEditingController();
  Color _previewColor = const Color(0xFFFF004A);

  @override
  void initState() {
    super.initState();
    _hexController.text = '#FF004A';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  void _updateColorFromHex(String hex) {
    try {
      String cleanHex = hex.replaceAll('#', '').toUpperCase();
      if (cleanHex.length == 6) {
        setState(() {
          _previewColor = Color(int.parse('FF$cleanHex', radix: 16));
        });
      }
    } catch (e) {
      // Ignorar errores
    }
  }

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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nombre
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  maxLength: 20,
                ),
                const SizedBox(height: 16),

                // Código Hexadecimal
                TextField(
                  controller: _hexController,
                  decoration: InputDecoration(
                    labelText: 'Código Hexadecimal',
                    hintText: '#FF004A',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.tag),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.content_paste),
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        if (data?.text != null) {
                          _hexController.text = data!.text!;
                          _updateColorFromHex(data.text!);
                        }
                      },
                      tooltip: 'Pegar',
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f#]')),
                    LengthLimitingTextInputFormatter(7),
                  ],
                  onChanged: _updateColorFromHex,
                ),
                const SizedBox(height: 24),

                // Vista previa grande
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _previewColor,
                        _previewColor.withOpacity(0.6),
                      ],
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
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _previewColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _previewColor.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                    _buildQuickColor(const Color(0xFFFF004A), '#FF004A'), // Fucsia
                    _buildQuickColor(const Color(0xFFE91E63), '#E91E63'), // Pink
                    _buildQuickColor(const Color(0xFF9C27B0), '#9C27B0'), // Purple
                    _buildQuickColor(const Color(0xFF673AB7), '#673AB7'), // Deep Purple
                    _buildQuickColor(const Color(0xFF3F51B5), '#3F51B5'), // Indigo
                    _buildQuickColor(const Color(0xFF2196F3), '#2196F3'), // Blue
                    _buildQuickColor(const Color(0xFF00BCD4), '#00BCD4'), // Cyan
                    _buildQuickColor(const Color(0xFF009688), '#009688'), // Teal
                    _buildQuickColor(const Color(0xFF4CAF50), '#4CAF50'), // Green
                    _buildQuickColor(const Color(0xFF8BC34A), '#8BC34A'), // Light Green
                    _buildQuickColor(const Color(0xFFFF9800), '#FF9800'), // Orange
                    _buildQuickColor(const Color(0xFFFF5722), '#FF5722'), // Deep Orange
                  ],
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _createPalette,
                        style: FilledButton.styleFrom(
                          backgroundColor: _previewColor,
                        ),
                        child: const Text('Crear'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre')),
      );
      return;
    }

    final palette = ColorPalette(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: PaletteType.custom,
      seedColor: _previewColor,
      customHex: _hexController.text,
    );

    widget.onPaletteCreated(palette);
    Navigator.pop(context);
  }
}