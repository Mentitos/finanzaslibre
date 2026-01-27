import 'package:flutter/material.dart';

class SnackBarUtils {
  /// Shows a SnackBar, removing any current one first to prevent stacking.
  static void show(BuildContext context, String message, {Color? color}) {
    final messenger = ScaffoldMessenger.of(context);

    // Clear current queue to prevent stacking
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(
          seconds: 2,
        ), // Short duration for rapid updates
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
