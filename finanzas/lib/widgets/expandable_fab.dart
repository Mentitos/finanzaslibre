import 'package:flutter/material.dart';
import 'dart:async';

class ExpandableFab extends StatefulWidget {
  final VoidCallback? onMainPressed; // Toggles menu usually
  final List<FabAction> children;

  const ExpandableFab({super.key, this.onMainPressed, required this.children});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class FabAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  FabAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;
  bool _showLabels = false;
  Timer? _labelHideTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _labelHideTimer?.cancel();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
        _showLabels = true;
        _startLabelHideTimer();
      } else {
        _controller.reverse();
        _labelHideTimer?.cancel();
        _showLabels = false;
      }
    });
  }

  void _startLabelHideTimer() {
    _labelHideTimer?.cancel();
    _labelHideTimer = Timer(const Duration(seconds: 1), () {
      if (mounted && _isOpen) {
        setState(() {
          _showLabels = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          CrossAxisAlignment.end, // Keep end to align right-most edge
      // To center the small buttons over the big one:
      // If we use standard size for all, standard right alignment works fine.
      // If we want "centered", we wrap children in a logic that centers them relative to the bottom FAB.
      // But typically FABs are right-aligned. The user said "centren... cuadrado original".
      // If all are standard size, CrossAxisAlignment.end (right alignment) creates a vertical stack where centers are aligned if widths are equal.
      // FloatingActionButton has fixed size.
      children: [
        if (_isOpen)
          ...widget.children.map((action) => _buildChildButton(action)),
        FloatingActionButton(
          onPressed: () {
            _toggle();
            widget.onMainPressed?.call();
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 0.125).animate(_expandAnimation),
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildChildButton(FabAction action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IgnorePointer(
            ignoring: !_showLabels,
            child: AnimatedOpacity(
              opacity: _showLabels ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  action.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ScaleTransition(
            scale: _expandAnimation,
            child: FloatingActionButton(
              // Changed from small to standard
              onPressed: () {
                _toggle();
                action.onTap();
              },
              backgroundColor: action.color,
              heroTag: null,
              child: Icon(action.icon, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
