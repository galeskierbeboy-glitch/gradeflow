import 'package:flutter/material.dart';
import 'glass_card.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
  });

  Color _brandColor() {
    if (icon == Icons.upload_file) return Colors.indigoAccent;
    if (icon == Icons.auto_fix_high) return Colors.cyan;
    return Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    final btn = GlassButton(
      onPressed: onPressed,
      color: _brandColor(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 18),
          if (icon != null) const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );

    if (expanded) {
      return SizedBox(width: double.infinity, child: btn);
    }
    return btn;
  }
}
