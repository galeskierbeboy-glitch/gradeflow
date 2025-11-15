import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackCard extends StatelessWidget {
  final String feedback;
  final TextStyle? style;

  const FeedbackCard({super.key, required this.feedback, this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: SingleChildScrollView(
        child: Text(
          feedback,
          style:
              style ??
              GoogleFonts.urbanist(
                color: Colors.white,
                fontSize: 16,
                height: 1.7,
              ),
        ),
      ),
    );
  }
}
