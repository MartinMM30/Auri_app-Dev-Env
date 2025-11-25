import 'package:flutter/material.dart';

class SurveyMultiTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;

  const SurveyMultiTextField({
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
        maxLines: null,
        cursorColor: cs.primary,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: true,
          filled: true,
          fillColor: cs.surface.withOpacity(0.08),
          floatingLabelStyle: TextStyle(color: cs.primary),
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
