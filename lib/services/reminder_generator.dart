// lib/services/reminder_generator.dart

import 'package:uuid/uuid.dart';
import 'package:auri_app/models/reminder_hive.dart';
import 'auto_reminder_service.dart';

class ReminderGeneratorV7 {
  static final _uuid = const Uuid();

  static List<ReminderHive> convert(List<ReminderAuto> list) {
    final out = <ReminderHive>[];

    for (final r in list) {
      out.add(
        ReminderHive(
          id: _uuid.v4(),
          title: r.title,
          dateIso: r.date.toIso8601String(),
          repeats: "once",
          tag: r.isPayment
              ? "payment"
              : r.isBirthday
              ? "birthday"
              : "",
          isAuto: true,
          jsonPayload: "{}",
        ),
      );
    }

    return out;
  }
}
