import 'package:flutter/material.dart';

class SurveyTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;

  const SurveyTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        cursorColor: cs.primary,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: cs.surface.withOpacity(0.08),
          floatingLabelStyle: TextStyle(color: cs.primary),

          // BORDER
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: cs.primary.withOpacity(0.25)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: cs.primary, width: 1.8),
          ),
        ),
      ),
    );
  }
}
