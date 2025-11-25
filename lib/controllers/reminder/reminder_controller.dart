// lib/controllers/reminder/reminder_controller.dart

import 'package:hive/hive.dart';
import 'package:auri_app/models/reminder_hive.dart';
import 'package:auri_app/services/cleanup_service_v7_hive.dart';
import 'package:auri_app/services/reminder_scheduler.dart';
import 'package:auri_app/services/auto_reminder_service.dart';
import 'package:auri_app/services/reminder_generator.dart';

class ReminderController {
  static const String boxName = "remindersBox";

  static Future<Box<ReminderHive>> _open() async {
    return await Hive.openBox<ReminderHive>(boxName);
  }

  /// Obtiene todos los recordatorios limpios (sin modificar Hive).
  static Future<List<ReminderHive>> getAll() async {
    final box = await _open();
    final list = box.values.toList();
    final cleaned = CleanupServiceHiveV7.clean(list, DateTime.now());
    return cleaned;
  }

  /// Guarda un recordatorio manual y programa su notificación.
  static Future<void> save(ReminderHive r) async {
    final box = await _open();
    await box.put(r.id, r);
    await ReminderScheduler.schedule(r);
  }

  /// Reescribe toda la caja después de auto-generación
  /// 1) cancela notificaciones viejas
  /// 2) limpia la caja
  /// 3) guarda y reprograma todas las nuevas.
  static Future<void> overwriteAll(List<ReminderHive> list) async {
    final box = await _open();

    // Cancelar notificaciones de los recordatorios anteriores
    final oldList = box.values.toList();
    await ReminderScheduler.cancelAllFor(oldList);

    await box.clear();

    for (final r in list) {
      await box.put(r.id, r);
      await ReminderScheduler.schedule(r);
    }
  }

  /// Elimina un recordatorio por ID y cancela su notificación.
  static Future<void> delete(String id) async {
    final box = await _open();
    final r = box.get(id);
    if (r != null) {
      await ReminderScheduler.cancel(r);
    }
    await box.delete(id);
  }

  /// Orquestador de recordatorios automáticos:
  /// - recibe los modelos lógicos (pagos, cumpleaños, settings, tareas)
  /// - genera ReminderAuto
  /// - convierte a ReminderHive
  /// - limpia duplicados/antiguos
  /// - sobrescribe Hive y reprograma todo.
  static Future<void> regenerateAutoReminders({
    required MonthlyPayments payments,
    required BirthdayData birthdays,
    required ReminderSettings settings,
    required List<UserTask> tasks,
    DateTime? now,
  }) async {
    final currentNow = now ?? DateTime.now();

    // 1. Generar lógica de auto recordatorios (pagos, cumpleaños, agenda semanal)
    final autoList = AutoReminderServiceV7.generateAll(
      payments: payments,
      birthdays: birthdays,
      settings: settings,
      tasks: tasks,
      now: currentNow,
    );

    // 2. Convertir a modelos Hive
    final hiveList = ReminderGeneratorV7.convert(autoList);

    // 3. Limpieza final (duplicados/antiguos según tu CleanupServiceHiveV7)
    final cleaned = CleanupServiceHiveV7.clean(hiveList, currentNow);

    // 4. Sobrescribir caja + reprogramar notificaciones
    await overwriteAll(cleaned);
  }
}
