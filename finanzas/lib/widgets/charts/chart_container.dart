import 'package:flutter/material.dart';

class ChartContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;

  const ChartContainer({
    super.key,
    required this.title,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent, // Removed white background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // Removed border side
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        height: height,
        child: Column(
          children: [
            // Pill shaped header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3B44), // Dark blue/green from image
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
