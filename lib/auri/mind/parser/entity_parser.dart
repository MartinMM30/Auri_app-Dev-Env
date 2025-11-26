// lib/auri/mind/parser/entity_parser.dart

import 'package:flutter/material.dart';

class EntityParser {
  /// Método universal llamado por los intents.
  /// Extrae fecha, hora, intervalos y tarea.
  static Map<String, dynamic> extract(String rawText) {
    final text = rawText.toLowerCase().trim();

    final date = _extractDate(text);
    final time = _extractTime(text);
    final interval = _extractInterval(text);
    final task = _extractTask(text);

    return {"date": date, "time": time, "interval": interval, "task": task};
  }

  // ============================================================
  //  PARSEO DE FECHA
  // ============================================================
  static DateTime? _extractDate(String t) {
    final now = DateTime.now();

    if (t.contains("mañana")) {
      return now.add(const Duration(days: 1));
    }

    if (t.contains("pasado mañana")) {
      return now.add(const Duration(days: 2));
    }

    if (t.contains("hoy")) {
      return now;
    }

    return null;
  }

  // ============================================================
  //  PARSEO DE HORA
  // ============================================================
  static TimeOfDay? _extractTime(String t) {
    final regex = RegExp(r"(\d{1,2}):(\d{2})");
    final match = regex.firstMatch(t);

    if (match != null) {
      final h = int.tryParse(match.group(1)!);
      final m = int.tryParse(match.group(2)!);
      if (h != null && m != null) {
        return TimeOfDay(hour: h, minute: m);
      }
    }

    if (t.contains("en la mañana")) return const TimeOfDay(hour: 9, minute: 0);
    if (t.contains("en la tarde")) return const TimeOfDay(hour: 15, minute: 0);
    if (t.contains("en la noche")) return const TimeOfDay(hour: 20, minute: 0);

    return null;
  }

  // ============================================================
  //  PARSEO DE INTERVALOS ("en 2 horas")
  // ============================================================
  static Duration? _extractInterval(String t) {
    final regex = RegExp(r"en (\d+) (minutos|minuto|horas|hora)");
    final match = regex.firstMatch(t);

    if (match != null) {
      final n = int.tryParse(match.group(1)!);
      if (n == null) return null;

      final unit = match.group(2)!;

      if (unit.startsWith("minuto")) return Duration(minutes: n);
      if (unit.startsWith("hora")) return Duration(hours: n);
    }

    return null;
  }

  // ============================================================
  //  TAREA ("recordarme pagar el agua")
  // ============================================================
  static String? _extractTask(String text) {
    const triggers = [
      "recordarme",
      "recuérdame",
      "recuerdame",
      "recordar",
      "avísame",
      "avisame",
    ];

    String cleaned = text;

    for (final w in triggers) {
      cleaned = cleaned.replaceAll(w, "");
    }

    cleaned = cleaned.trim();

    if (cleaned.isEmpty) return null;

    return cleaned;
  }
}
