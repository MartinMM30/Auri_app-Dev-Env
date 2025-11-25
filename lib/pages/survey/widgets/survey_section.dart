import 'package:flutter/material.dart';

class SurveySection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SurveySection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.primary.withOpacity(0.2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
          ),

          ...children,
        ],
      ),
    );
  }
}
