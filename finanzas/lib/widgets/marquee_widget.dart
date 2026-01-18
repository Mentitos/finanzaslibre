import 'package:flutter/material.dart';

class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Axis direction;
  final Duration animationDuration;
  final Duration backDuration;
  final Duration pauseDuration;

  const MarqueeWidget({
    super.key,
    required this.child,
    this.direction = Axis.horizontal,
    this.animationDuration = const Duration(milliseconds: 6000),
    this.backDuration = const Duration(milliseconds: 800),
    this.pauseDuration = const Duration(milliseconds: 800),
  });

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling() async {
    if (!mounted) return;

    // Check if scrolling is needed
    if (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent > 0) {
      await Future.delayed(widget.pauseDuration);
      if (!mounted) return;

      try {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: widget.animationDuration,
          curve: Curves.linear,
        );
      } catch (e) {
        // Ignore animation errors (e.g. widget disposed)
        return;
      }

      if (!mounted) return;
      await Future.delayed(widget.pauseDuration);
      if (!mounted) return;

      try {
        // Snap back or scroll back? User said "carousel", usually means wrapping.
        // But implementing seamless wrapping manually is hard.
        // A simple "scroll to end, pause, jump/scroll to start" is robust.
        // "start spinning ... right to left"

        // Let's just jump back instantly and loop, usually cleaner for stock-ticker style?
        // Or scroll back?
        // User said "girar tipo carrusel" (rotate like carousel). Use infinite loop logic?
        // Infinite loop requires duplicating the widget.

        // Let's stick to simple "AutoScroll" first: Start -> End -> Start.
        // Re-starting:
        _scrollController.jumpTo(0);
        _startScrolling();
      } catch (e) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: widget.direction,
      physics: const NeverScrollableScrollPhysics(), // User shouldn't touch it
      child: widget.child,
    );
  }
}
