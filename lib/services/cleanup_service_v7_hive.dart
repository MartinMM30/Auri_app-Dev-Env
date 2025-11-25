// lib/services/cleanup_service_v7_hive.dart

import 'package:auri_app/models/reminder_hive.dart';

class CleanupServiceHiveV7 {
  /// Limpieza profunda estilo V7.5 (portada del CleanupServiceV7 original).
  static List<ReminderHive> clean(List<ReminderHive> input, DateTime now) {
    final output = <ReminderHive>[];

    // -------------------------------------------------------
    // 1) eliminar vencidos
    // -------------------------------------------------------
    final noPast = input.where((r) {
      DateTime? date;
      try {
        date = DateTime.parse(r.dateIso);
      } catch (_) {
        return false;
      }
      return date.isAfter(now);
    }).toList();

    // -------------------------------------------------------
    // 2) evitar duplicados exactos (misma fecha + título)
    // -------------------------------------------------------
    final byKey = <String, ReminderHive>{};

    for (final r in noPast) {
      final key = "${r.title.trim()}_${r.dateIso}_${r.tag}";
      byKey[key] = r; // conserva el último
    }

    final unique = byKey.values.toList();

    // -------------------------------------------------------
    // 3) normalización (port de _normalize(original))
    // -------------------------------------------------------
    final normalized = <ReminderHive>[];

    for (final r in unique) {
      normalized.add(_normalize(r));
    }

    // -------------------------------------------------------
    // 4) eliminar PRONTO incorrectos
    // -------------------------------------------------------
    normalized.removeWhere((r) {
      final titleLower = r.title.toLowerCase();
      if (!titleLower.startsWith("pronto")) return false;

      final originalTitle = r.title.replaceFirst("Pronto: ", "");

      return !normalized.any(
        (x) => x.title == originalTitle && _date(x).isAfter(_date(r)),
      );
    });

    // -------------------------------------------------------
    // 5) eliminar pagos generados dos veces (mismo mes)
    // -------------------------------------------------------
    final seenPayments = <String, ReminderHive>{};

    normalized.removeWhere((r) {
      if (r.tag != "payment") return false;

      final d = _date(r);
      final key = "${r.title}_${d.year}_${d.month}";

      if (seenPayments.containsKey(key)) return true;

      seenPayments[key] = r;
      return false;
    });

    // -------------------------------------------------------
    // 6) eliminar cumpleaños duplicados (mismo año)
    // -------------------------------------------------------
    final seenBirthdays = <String, ReminderHive>{};

    normalized.removeWhere((r) {
      if (r.tag != "birthday") return false;

      final d = _date(r);
      final key = "${r.title}_${d.year}";

      if (seenBirthdays.containsKey(key)) return true;

      seenBirthdays[key] = r;
      return false;
    });

    // -------------------------------------------------------
    // 7) ordenar por fecha
    // -------------------------------------------------------
    normalized.sort((a, b) {
      return _date(a).compareTo(_date(b));
    });

    return normalized;
  }

  /// Normalización basada en _normalize del CleanupServiceV7
  static ReminderHive _normalize(ReminderHive r) {
    String title = r.title.trim();

    // 1. Corregir “Pago Pago agua”
    title = title.replaceAll("Pago Pago", "Pago");

    // 2. Corregir “Cumpleaños pronto: Usuario”
    title = title.replaceAll("Cumpleaños pronto:", "Pronto: Cumpleaños:");

    // 3. Normalizar “Pronto: Pronto”
    if (title.startsWith("Pronto: Pronto")) {
      title = title.replaceFirst("Pronto: Pronto:", "Pronto:");
    }

    return ReminderHive(
      id: r.id,
      title: title,
      dateIso: r.dateIso,
      repeats: r.repeats,
      tag: r.tag,
      isAuto: r.isAuto,
      jsonPayload: r.jsonPayload,
    );
  }

  static DateTime _date(ReminderHive r) => DateTime.parse(r.dateIso).toLocal();
}
