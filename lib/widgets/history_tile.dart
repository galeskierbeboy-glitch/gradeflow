import 'package:flutter/material.dart';

class HistoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback? onTap;

  const HistoryTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 1,
      color: isDark ? Colors.grey[850] : Colors.grey[50],
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
        ),
        trailing: trailing != null
            ? Text(
                trailing!,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              )
            : null,
      ),
    );
  }
}
