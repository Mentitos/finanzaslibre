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
    setState(() {
      _customPalettes = palettes;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxHeight: 600),
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
                  Expanded(
                    child: Text(
                      'Paleta de Colores',
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
                tabs: const [
                  Tab(text: 'Predeterminadas', icon: Icon(Icons.apps, size: 20)),
                  Tab(text: 'Personalizado', icon: Icon(Icons.tune, size: 20)),
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
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
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
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showCreateCustomPaletteDialog,
            icon: const Icon(Icons.add),
            label: const Text('Crear Paleta Personalizada'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
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
                        childAspectRatio: 1.2,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () async {
        await PaletteManager.savePalette(palette);
        widget.onPaletteSelected(palette);
        if (mounted) Navigator.pop(context);
      },
      onLongPress: isCustom
          ? () => _showDeletePaletteDialog(palette)
          : null,
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
            // Contenido
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Círculo de color
                  Container(
                    width: 50,
                    height: 50,
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
                  const SizedBox(height: 12),

                  // Nombre
                  Text(
                    palette.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Hex (solo para custom)
                  if (isCustom && palette.customHex != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      palette.customHex!,
                      style: TextStyle(
                        fontSize: 11,
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
                    size: 16,
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
                    size: 16,
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
        content: Text('¿Eliminar la paleta "${palette.name}"?'),
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
// 4. DIÁLOGO CREADOR DE PALETA PERSONALIZADA
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
  Color _previewColor = Colors.blue;

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
      // Ignorar errores de parsing
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                const Text(
                  'Nueva Paleta Personalizada',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nombre
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la paleta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              maxLength: 30,
            ),
            const SizedBox(height: 16),

            // Código Hexadecimal
            TextField(
              controller: _hexController,
              decoration: const InputDecoration(
                labelText: 'Código Hexadecimal',
                hintText: '#FF5722',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f#]')),
                LengthLimitingTextInputFormatter(7),
              ],
              onChanged: _updateColorFromHex,
            ),
            const SizedBox(height: 24),

            // Colores rápidos
            const Text(
              'Colores sugeridos:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickColorButton(Colors.pink, '#E91E63'),
                _buildQuickColorButton(Colors.purple, '#9C27B0'),
                _buildQuickColorButton(Colors.deepPurple, '#673AB7'),
                _buildQuickColorButton(Colors.indigo, '#3F51B5'),
                _buildQuickColorButton(Colors.cyan, '#00BCD4'),
                _buildQuickColorButton(Colors.teal, '#009688'),
                _buildQuickColorButton(Colors.lime, '#CDDC39'),
                _buildQuickColorButton(Colors.amber, '#FFC107'),
                _buildQuickColorButton(Colors.deepOrange, '#FF5722'),
                _buildQuickColorButton(const Color(0xFFB39DDB), '#B39DDB'),
                _buildQuickColorButton(const Color(0xFF90CAF9), '#90CAF9'),
                _buildQuickColorButton(const Color(0xFFFFAB91), '#FFAB91'),
              ],
            ),
            const SizedBox(height: 24),

            // Vista previa
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                    width: 60,
                    height: 60,
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
    );
  }

  Widget _buildQuickColorButton(Color color, String hex) {
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
            color: _previewColor == color ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  void _createPalette() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre para la paleta')),
      );
      return;
    }

    final palette = ColorPalette(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: PaletteType.custom,
      seedColor: _previewColor,
      customHex: _hexController.text.isNotEmpty ? _hexController.text : null,
    );

    widget.onPaletteCreated(palette);
    Navigator.pop(context);
  }
}