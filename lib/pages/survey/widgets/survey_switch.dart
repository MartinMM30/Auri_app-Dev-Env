import 'package:flutter/material.dart';

class SurveySwitch extends StatelessWidget {
  final String text;
  final bool value;
  final Function(bool) onChanged;

  const SurveySwitch({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withOpacity(0.85),
              ),
            ),
          ),
          AnimatedScale(
            scale: value ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Switch(
              value: value,
              activeColor: cs.primary,
              inactiveThumbColor: cs.onSurface.withOpacity(0.5),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
