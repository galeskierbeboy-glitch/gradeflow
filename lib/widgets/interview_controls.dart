import 'package:flutter/material.dart';
import 'glass_card.dart';

class InterviewControls extends StatelessWidget {
  final String selectedNiche;
  final List<String> nicheKeys;
  final String selectedMode;
  final List<String> modeKeys;
  final Function(String?) onNicheChanged;
  final Function(String?) onModeChanged;
  final VoidCallback onRestart;

  const InterviewControls({
    super.key,
    required this.selectedNiche,
    required this.nicheKeys,
    required this.selectedMode,
    required this.modeKeys,
    required this.onNicheChanged,
    required this.onModeChanged,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Restart Button
        GlassButton(
          onPressed: onRestart,
          color: Colors.white24,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _buildDropdown(selectedNiche, nicheKeys, onNicheChanged),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: _buildDropdown(selectedMode, modeKeys, onModeChanged),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return GlassCard(
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.black87,
          items: items
              .map(
                (k) => DropdownMenuItem(
                  value: k,
                  child: Text(k, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
