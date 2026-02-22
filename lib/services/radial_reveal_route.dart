import 'dart:math';
import 'package:flutter/material.dart';

class RadialRevealRoute extends PageRouteBuilder {
  final Widget page;
  final Offset centerOffset;

  RadialRevealRoute({required this.page, required this.centerOffset})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 700),
          reverseTransitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                ClipPath(
                  clipper: RadialClipper(
                    fraction: animation.value,
                    centerOffset: centerOffset,
                  ),
                  child: child,
                ),
              ],
            );
          },
        );
}

class RadialClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset centerOffset;

  RadialClipper({required this.fraction, required this.centerOffset});

  @override
  Path getClip(Size size) {
    // Calculate final radius needed to cover the whole screen from the centerOffset
    double finalRadius = _calculateDistance(centerOffset, size);
    
    // Smooth the fraction with a curve for better feel
    double progress = Curves.easeInOutQuart.transform(fraction);
    double radius = finalRadius * progress;

    return Path()
      ..addOval(Rect.fromCircle(center: centerOffset, radius: radius));
  }

  double _calculateDistance(Offset offset, Size size) {
    // Find the distance to the farthest corner
    double dx = max(offset.dx, size.width - offset.dx);
    double dy = max(offset.dy, size.height - offset.dy);
    return sqrt(dx * dx + dy * dy);
  }

  @override
  bool shouldReclip(RadialClipper oldClipper) {
    return oldClipper.fraction != fraction || oldClipper.centerOffset != centerOffset;
  }
}
