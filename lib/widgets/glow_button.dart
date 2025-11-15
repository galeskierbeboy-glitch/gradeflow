import 'package:flutter/material.dart';

class GlowButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  const GlowButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 72, 2, 151),
            Color.fromARGB(255, 1, 136, 141),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            // Fixed: use withValues(alpha: …) instead of withOpacity()
            color: const Color.fromARGB(255, 3, 18, 155).withValues(alpha: 0.6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }
}
