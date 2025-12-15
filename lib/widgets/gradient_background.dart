import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F044C), // deep indigo
            Color(0xFF2A0D6E), // indigo purple
            Color(0xFF7C3AED), // vibrant purple
            Color(0xFF00E5C4), // neon teal accent
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
