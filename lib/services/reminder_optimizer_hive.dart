// lib/services/reminder_optimizer_hive.dart
import 'package:auri_app/models/reminder_hive.dart';

/// Optimiza la lista completa de recordatorios que se van a guardar en Hive.
///
/// - Elimina duplicados de recordatorios automáticos (mismo título/fecha/tag).
/// - Elimina recordatorios automáticos ya vencidos hace tiempo.
/// - Mantiene TODOS los manuales tal cual.
/// - Ordena por fecha ascendente.
class ReminderOptimizerHive {
  List<ReminderHive> optimize(List<ReminderHive> input) {
    final now = DateTime.now();

    final manual = <ReminderHive>[];
    final autoMap = <String, ReminderHive>{};

    for (final r in input) {
      final dt = DateTime.tryParse(r.dateIso);

      // Fecha inválida: dejamos manuales, descartamos autos viejos rotos.
      if (dt == null) {
        if (!r.isAuto) {
          manual.add(r);
        }
        continue;
      }

      // Si es automático y ya pasó hace más de 1 día → lo limpiamos
      if (r.isAuto && dt.isBefore(now.subtract(const Duration(days: 1)))) {
        continue;
      }

      if (!r.isAuto) {
        // Manual → se conserva siempre
        manual.add(r);
      } else {
        // Automático → deduplicar por (tag, titulo, fecha)
        final key = '${r.tag}__${r.title}__${r.dateIso}';
        // Si ya existe uno con misma clave, ignoramos el nuevo
        autoMap.putIfAbsent(key, () => r);
      }
    }

    final autos = autoMap.values.toList();

    final all = <ReminderHive>[];
    all.addAll(manual);
    all.addAll(autos);

    // Ordenar por fecha ascendente
    all.sort((a, b) {
      final da = DateTime.tryParse(a.dateIso) ?? now;
      final db = DateTime.tryParse(b.dateIso) ?? now;
      return da.compareTo(db);
    });

    return all;
  }
}
