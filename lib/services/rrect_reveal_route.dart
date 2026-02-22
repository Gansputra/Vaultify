import 'package:flutter/material.dart';

class RRectRevealRoute extends PageRouteBuilder {
  final Widget page;
  final Rect buttonRect;
  final double borderRadius;

  RRectRevealRoute({
    required this.page,
    required this.buttonRect,
    this.borderRadius = 24, // Default pill radius
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                ClipPath(
                  clipper: RRectClipper(
                    fraction: animation.value,
                    buttonRect: buttonRect,
                    initialRadius: borderRadius,
                  ),
                  child: child,
                ),
              ],
            );
          },
        );
}

class RRectClipper extends CustomClipper<Path> {
  final double fraction;
  final Rect buttonRect;
  final double initialRadius;

  RRectClipper({
    required this.fraction,
    required this.buttonRect,
    required this.initialRadius,
  });

  @override
  Path getClip(Size size) {
    double progress = Curves.easeInOutExpo.transform(fraction);

    // Calculate the lerped Rect between button and full screen
    final currentRect = Rect.fromLTRB(
      lerp(buttonRect.left, 0, progress),
      lerp(buttonRect.top, 0, progress),
      lerp(buttonRect.right, size.width, progress),
      lerp(buttonRect.bottom, size.height, progress),
    );

    // Calculate the lerped Radius (pill radius to 0 for screen corners)
    final currentRadius = lerp(initialRadius, 0, progress);

    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        currentRect,
        Radius.circular(currentRadius),
      ));
  }

  double lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldReclip(RRectClipper oldClipper) {
    return oldClipper.fraction != fraction;
  }
}
