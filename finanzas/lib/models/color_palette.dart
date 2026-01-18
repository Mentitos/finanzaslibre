import 'package:flutter/material.dart';

enum PaletteType { green, pink, blue, purple, orange, pastel, custom }

class ColorPalette {
  final String id;
  final String name;
  final PaletteType type;
  final Color seedColor;
  final String? customHex;
  final bool useWhiteText;
  final bool affectTotalCard;

  const ColorPalette({
    required this.id,
    required this.name,
    required this.type,
    required this.seedColor,
    this.customHex,
    this.useWhiteText = true,
    this.affectTotalCard = false,
  });

  // Paletas predeterminadas
  static const List<ColorPalette> predefinedPalettes = [
    ColorPalette(
      id: 'green',
      name: 'Verde',
      type: PaletteType.green,
      seedColor: Colors.green,
      useWhiteText: false,
    ),
    ColorPalette(
      id: 'pink',
      name: 'Fucsia',
      type: PaletteType.pink,
      seedColor: Color(0xFFEC1C57),
    ),
    ColorPalette(
      id: 'blue',
      name: 'Azul',
      type: PaletteType.blue,
      seedColor: Colors.blue,
    ),
    ColorPalette(
      id: 'purple',
      name: 'Púrpura',
      type: PaletteType.purple,
      seedColor: Color(0xFF9C27B0),
    ),
    ColorPalette(
      id: 'orange',
      name: 'Naranja',
      type: PaletteType.orange,
      seedColor: Color(0xFFFF6F00),
    ),
    ColorPalette(
      id: 'pastel',
      name: 'Púrpura Pastel',
      type: PaletteType.pastel,
      seedColor: Color(0xFFB39DDB),
    ),
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'seedColor': seedColor.value,
      'customHex': customHex,
      'useWhiteText': useWhiteText,
      'affectTotalCard': affectTotalCard,
    };
  }

  factory ColorPalette.fromJson(Map<String, dynamic> json) {
    return ColorPalette(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PaletteType.values[json['type'] as int],
      seedColor: Color(json['seedColor'] as int),
      customHex: json['customHex'] as String?,
      useWhiteText: json['useWhiteText'] as bool? ?? true,
      affectTotalCard: json['affectTotalCard'] as bool? ?? false,
    );
  }

  ColorPalette copyWith({
    String? id,
    String? name,
    PaletteType? type,
    Color? seedColor,
    String? customHex,
    bool? useWhiteText,
    bool? affectTotalCard,
  }) {
    return ColorPalette(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      seedColor: seedColor ?? this.seedColor,
      customHex: customHex ?? this.customHex,
      useWhiteText: useWhiteText ?? this.useWhiteText,
      affectTotalCard: affectTotalCard ?? this.affectTotalCard,
    );
  }
}
