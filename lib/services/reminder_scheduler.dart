// lib/services/reminder_scheduler.dart

import 'package:auri_app/models/reminder_hive.dart';
import 'package:auri_app/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:auri_app/models/reminder_model.dart';

class ReminderScheduler {
  static final _notifier = NotificationService();

  static int _notificationIdFor(ReminderHive r) {
    // Mismo mapping que ya usabas
    return r.id.hashCode & 0x7fffffff;
  }

  static int _notificationIdForId(String reminderId) {
    return reminderId.hashCode & 0x7fffffff;
  }

  static Future<void> schedule(ReminderHive r) async {
    final id = _notificationIdFor(r);
    await _notifier.cancel(id);

    final date = DateTime.tryParse(r.dateIso);
    if (date == null) return;

    final model = Reminder(
      id: r.id,
      title: r.title,
      dateTime: date,
      description: r.tag.isEmpty ? null : r.tag,
      isAuto: r.isAuto,
    );

    await _notifier.scheduleReminderNotification(model);
  }

  static Future<void> scheduleAll(List<ReminderHive> list) async {
    for (final r in list) {
      await schedule(r);
    }
  }

  /// Cancela la notificación asociada a un recordatorio específico.
  static Future<void> cancel(ReminderHive r) async {
    final id = _notificationIdFor(r);
    await _notifier.cancel(id);
  }

  /// Cancela la notificación a partir del ID lógico (string) del recordatorio.
  static Future<void> cancelById(String reminderId) async {
    final id = _notificationIdForId(reminderId);
    await _notifier.cancel(id);
  }

  /// Cancela todas las notificaciones asociadas a una lista de recordatorios.
  static Future<void> cancelAllFor(List<ReminderHive> list) async {
    for (final r in list) {
      await cancel(r);
    }
  }
}
