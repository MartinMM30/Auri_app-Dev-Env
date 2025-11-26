// lib/auri/mind/intents/reminder_intents.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:auri_app/auri/mind/intents/auri_intent_engine.dart';
import 'package:auri_app/auri/mind/parser/entity_parser.dart';
import 'package:auri_app/models/reminder_hive.dart';
import 'dart:convert';

/// ---------------------------------------------------------------
/// 🧠 ReminderIntents — Detecta si el usuario quiere crear recordatorios
/// y provee utilidades para crear recordatorios en Hive.
/// ---------------------------------------------------------------
class ReminderIntents {
  // ============================================================
  // 1) DETECTOR DE INTENT
  // ============================================================
  /// Detecta si el texto describe un recordatorio.
  ///
  /// Retorna `AuriIntentResult("add_reminder", entities)` o `null`.
  static AuriIntentResult? detect(String text) {
    if (text.contains("recuérdame") ||
        text.contains("recuerdame") ||
        text.contains("recordatorio") ||
        text.contains("recordar") ||
        text.contains("avísame") ||
        text.contains("avisame")) {
      final entities = EntityParser.extract(text);
      return AuriIntentResult("add_reminder", entities);
    }

    return null;
  }

  // ============================================================
  // 2) CREACIÓN DE RECORDATORIOS
  // ============================================================
  /// Crea un ReminderHive real en Hive a partir de las entidades
  /// detectadas por EntityParser (date, time, interval, task).
  static Future<ReminderHive> createReminderFromEntities(
    Map<String, dynamic> entities,
  ) async {
    final box = Hive.box<ReminderHive>('reminders');
    final now = DateTime.now();

    final DateTime? parsedDate = entities['date'] as DateTime?;
    final TimeOfDay? parsedTime = entities['time'] as TimeOfDay?;
    final Duration? interval = entities['interval'] as Duration?;
    String rawTask = (entities['task'] as String?)?.trim() ?? '';

    if (rawTask.isEmpty) {
      rawTask = "Recordatorio";
    }

    // -----------------------------
    // Resolver fecha/hora final
    // -----------------------------
    DateTime targetDateTime;

    if (parsedDate != null && parsedTime != null) {
      targetDateTime = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } else if (parsedDate != null) {
      targetDateTime = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        9,
        0,
      );
    } else if (interval != null) {
      targetDateTime = now.add(interval);
    } else {
      targetDateTime = now.add(const Duration(minutes: 5));
    }

    // Evitar crear recordatorios en el pasado
    if (targetDateTime.isBefore(now)) {
      targetDateTime = now.add(const Duration(minutes: 2));
    }

    final id = "${targetDateTime.toIso8601String()}_${rawTask.hashCode}";

    final payload = <String, dynamic>{
      "id": id,
      "title": rawTask,
      "date": targetDateTime.toIso8601String(),
      "repeats": "once",
      "tag": "voice",
      "isAuto": false,
      "source": "voice",
    };

    final reminder = ReminderHive(
      id: id,
      title: rawTask,
      dateIso: targetDateTime.toIso8601String(),
      repeats: "once",
      tag: "voice",
      isAuto: false,
      jsonPayload: jsonEncode(payload),
    );

    await box.put(id, reminder);
    return reminder;
  }

  // ============================================================
  // 3) FORMATEO PARA RESPUESTA DE AURI
  // ============================================================
  static String humanReadableDate(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    final d = two(dt.day);
    final m = two(dt.month);
    final h = two(dt.hour);
    final min = two(dt.minute);
    return "$d/$m a las $h:$min";
  }
}
