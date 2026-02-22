import 'dart:math';
import 'package:flutter/material.dart';

class AuraBackground extends StatefulWidget {
  final int selectedIndex;
  const AuraBackground({super.key, required this.selectedIndex});

  @override
  State<AuraBackground> createState() => _AuraBackgroundState();
}

class _AuraBackgroundState extends State<AuraBackground> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  // Define colors for each tab
  final List<List<Color>> _tabColors = [
    [const Color(0xFF6C63FF), const Color(0xFF3F3D56)], // Vault: Purple/Deep
    [const Color(0xFF00BFA6), const Color(0xFF00796B)], // Keys: Teal/Green
    [const Color(0xFFFF6584), const Color(0xFFC2185B)], // Stats: Pink/Rose
    [const Color(0xFFFFA000), const Color(0xFFFF6D00)], // Setup: Amber/Orange
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _tabColors[widget.selectedIndex % _tabColors.length];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Base Background
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            
            // Animated Aura Blobs
            _buildBlob(
              color: colors[0].withAlpha(isDark ? 40 : 60),
              size: 400,
              scale: 1.0 + 0.2 * sin(_controller.value * 2 * pi),
              offset: Offset(
                100 * sin(_controller.value * 2 * pi),
                150 * cos(_controller.value * 2 * pi),
              ),
              alignment: Alignment.topLeft,
            ),
            
            _buildBlob(
              color: colors[1].withAlpha(isDark ? 30 : 50),
              size: 350,
              scale: 1.0 + 0.15 * cos(_controller.value * 3 * pi),
              offset: Offset(
                80 * cos(_controller.value * 2 * pi + pi),
                120 * sin(_controller.value * 2 * pi + pi),
              ),
              alignment: Alignment.bottomRight,
            ),

            _buildBlob(
              color: colors[0].withAlpha(isDark ? 20 : 40),
              size: 300,
              scale: 1.0 + 0.1 * sin(_controller.value * 4 * pi),
              offset: Offset(
                120 * cos(_controller.value * 1.5 * pi),
                80 * sin(_controller.value * 1.5 * pi),
              ),
              alignment: Alignment.centerLeft,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBlob({
    required Color color,
    required double size,
    required double scale,
    required Offset offset,
    required Alignment alignment,
  }) {
    return AnimatedAlign(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color,
                  color.withAlpha(0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
