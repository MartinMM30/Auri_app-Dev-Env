// lib/services/reminder_optimizer.dart
import 'package:auri_app/models/reminder_model.dart';

class ReminderOptimizer {
  /// Optimiza la lista de recordatorios automáticos:
  /// - Elimina pasados
  /// - Elimina duplicados (mismo título + misma fecha)
  /// - Ordena por fecha ascendente
  static List<Reminder> optimize(List<Reminder> autoReminders, DateTime now) {
    // 1) Solo futuro
    final future = autoReminders.where((r) => r.dateTime.isAfter(now)).toList();

    // 2) De-duplicar por (title + dateTime)
    final Map<String, Reminder> unique = {};
    for (final r in future) {
      final key = '${r.title}_${r.dateTime.toIso8601String()}';
      if (!unique.containsKey(key)) {
        unique[key] = r;
      }
    }

    // 3) Ordenar
    final result = unique.values.toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return result;
  }
}
