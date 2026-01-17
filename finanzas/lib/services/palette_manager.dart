import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/color_palette.dart';

class PaletteManager {
  static const String _paletteKey = 'selected_color_palette';
  static const String _customPalettesKey = 'custom_color_palettes';

  static Future<void> savePalette(ColorPalette palette) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paletteKey, jsonEncode(palette.toJson()));
  }

  static Future<ColorPalette> loadPalette() async {
    final prefs = await SharedPreferences.getInstance();
    final paletteJson = prefs.getString(_paletteKey);

    if (paletteJson != null) {
      try {
        final data = jsonDecode(paletteJson) as Map<String, dynamic>;
        return ColorPalette.fromJson(data);
      } catch (e) {
        debugPrint('Error cargando paleta: $e');
      }
    }

    return ColorPalette.predefinedPalettes.first;
  }

  static Future<void> saveCustomPalette(ColorPalette palette) async {
    final prefs = await SharedPreferences.getInstance();
    final customPalettes = await loadCustomPalettes();
    
    customPalettes.removeWhere((p) => p.id == palette.id);
    customPalettes.add(palette);
    
    final palettesJson = jsonEncode(
      customPalettes.map((p) => p.toJson()).toList(),
    );
    await prefs.setString(_customPalettesKey, palettesJson);
  }

  static Future<List<ColorPalette>> loadCustomPalettes() async {
    final prefs = await SharedPreferences.getInstance();
    final palettesJson = prefs.getString(_customPalettesKey);

    if (palettesJson != null) {
      try {
        final List<dynamic> data = jsonDecode(palettesJson);
        return data.map((json) => ColorPalette.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Error cargando paletas personalizadas: $e');
      }
    }

    return [];
  }

  static Future<void> deleteCustomPalette(String id) async {
    final customPalettes = await loadCustomPalettes();
    customPalettes.removeWhere((p) => p.id == id);
    
    final prefs = await SharedPreferences.getInstance();
    final palettesJson = jsonEncode(
      customPalettes.map((p) => p.toJson()).toList(),
    );
    await prefs.setString(_customPalettesKey, palettesJson);
  }
}