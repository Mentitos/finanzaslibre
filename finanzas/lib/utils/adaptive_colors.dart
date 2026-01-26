import 'package:flutter/material.dart';
import '../models/color_palette.dart';

class AdaptiveColors {
  // Obtener color adaptado según el contexto
  static Color getAdaptiveColor(
    BuildContext context,
    ColorPalette palette,
    AdaptiveColorType type,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      // Colores que siempre siguen la paleta
      case AdaptiveColorType.primary:
        return palette.seedColor;

      case AdaptiveColorType.success:
        return palette.seedColor;

      case AdaptiveColorType.primaryContainer:
        return isDark
            ? palette.seedColor.withValues(alpha: 0.3)
            : palette.seedColor.withValues(alpha: 0.1);

      // Colores que mantienen su identidad
      case AdaptiveColorType.error:
        return Colors.red;

      case AdaptiveColorType.warning:
        return Colors.orange;

      case AdaptiveColorType.info:
        return Colors.blue;
    }
  }

  // Método para obtener color de depósito (sigue la paleta)
  static Color getDepositColor(BuildContext context, ColorPalette palette) {
    return palette.seedColor;
  }

  // Método para obtener color de retiro (siempre rojo)
  static Color getWithdrawalColor(BuildContext context) {
    return Colors.red;
  }

  // Método para obtener color de dinero físico (adaptable)
  static Color getPhysicalMoneyColor(
    BuildContext context,
    ColorPalette palette,
  ) {
    // Si la paleta es azul, mantener azul
    if (palette.type == PaletteType.blue) {
      return Colors.blue;
    }
    // Sino, usar la paleta principal
    return palette.seedColor;
  }

  // Método para obtener color de dinero digital (siempre púrpura)
  static Color getDigitalMoneyColor(BuildContext context) {
    return Colors.purple;
  }
}

enum AdaptiveColorType {
  primary,
  success,
  primaryContainer,
  error,
  warning,
  info,
}
