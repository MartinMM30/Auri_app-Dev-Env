// lib/services/auto_reminder_service.dart
// (en tu comentario lo llamaste auto_reminder_service_v7.dart, pero ReminderGeneratorV7
// ya lo importa como auto_reminder_service.dart, así que mantengo ese nombre)

class AutoReminderServiceV7 {
  static List<ReminderAuto> generateAll({
    required MonthlyPayments payments,
    required BirthdayData birthdays,
    required ReminderSettings settings,
    required List<UserTask> tasks,
    required DateTime now,
  }) {
    final list = <ReminderAuto>[];

    // 1. Pagos mensuales
    list.addAll(_generateMonthly(payments, settings.anticipationDays, now));

    // 2. Cumpleaños
    list.addAll(_generateBirthdays(birthdays, settings.anticipationDays, now));

    // 3. Agenda semanal (Opción C)
    list.add(_generateWeeklyAgenda(tasks, now));

    return list;
  }

  // -------------------------- PAGOS --------------------------
  static List<ReminderAuto> _generateMonthly(
    MonthlyPayments p,
    int anticipation,
    DateTime now,
  ) {
    final out = <ReminderAuto>[];

    final items = {
      "Pago agua": p.waterDay,
      "Pago luz": p.lightDay,
      "Pago internet": p.internetDay,
      "Pago teléfono": p.phoneDay,
      "Pago renta": p.rentDay,
    };

    items.forEach((title, day) {
      if (day <= 0) return;

      final thisMonth = _safeDate(now.year, now.month, day);
      final nextMonth = _safeDate(
        now.month == 12 ? now.year + 1 : now.year,
        now.month == 12 ? 1 : now.month + 1,
        day,
      );

      // Este mes
      if (thisMonth.isAfter(now)) {
        out.add(ReminderAuto(title, thisMonth, isPayment: true));

        if (anticipation > 0) {
          final soon = thisMonth.subtract(Duration(days: anticipation));
          if (soon.isAfter(now)) {
            out.add(ReminderAuto("Pronto: $title", soon, isPayment: true));
          }
        }
      }

      // Próximo mes
      if (nextMonth.isAfter(now)) {
        out.add(ReminderAuto(title, nextMonth, isPayment: true));

        if (anticipation > 0) {
          final soon = nextMonth.subtract(Duration(days: anticipation));
          if (soon.isAfter(now)) {
            out.add(ReminderAuto("Pronto: $title", soon, isPayment: true));
          }
        }
      }
    });

    return out;
  }

  // -------------------------- CUMPLEAÑOS --------------------------
  static List<ReminderAuto> _generateBirthdays(
    BirthdayData b,
    int anticipation,
    DateTime now,
  ) {
    final out = <ReminderAuto>[];

    final data = {
      "Cumpleaños: Usuario": b.userBirthday,
      "Cumpleaños: Pareja": b.partnerBirthday,
    };

    data.forEach((title, date) {
      if (date == null) return;

      final next = _nextAnnual(date, now);
      out.add(ReminderAuto(title, next, isBirthday: true));

      if (anticipation > 0) {
        final soon = next.subtract(Duration(days: anticipation));
        if (soon.isAfter(now)) {
          out.add(ReminderAuto("Pronto: $title", soon, isBirthday: true));
        }
      }
    });

    return out;
  }

  // -------------------------- AGENDA SEMANAL --------------------------
  static ReminderAuto _generateWeeklyAgenda(
    List<UserTask> tasks,
    DateTime now,
  ) {
    if (tasks.isEmpty) {
      final next = _nextWeekday(now, DateTime.monday, hour: 8);
      return ReminderAuto("Revisión semanal automática", next);
    }

    tasks.sort((a, b) => a.date.compareTo(b.date));

    return ReminderAuto("Revisión semanal automática", tasks.first.date);
  }

  // -------------------------- HELPERS --------------------------
  static DateTime _nextAnnual(DateTime birth, DateTime now) {
    final thisYear = DateTime(now.year, birth.month, birth.day, 9);
    if (thisYear.isAfter(now)) return thisYear;

    return DateTime(now.year + 1, birth.month, birth.day, 9);
  }

  static DateTime _nextWeekday(
    DateTime from,
    int weekday, {
    int hour = 9,
    int minute = 0,
  }) {
    var diff = (weekday - from.weekday) % 7;
    if (diff == 0) diff = 7;
    return DateTime(from.year, from.month, from.day + diff, hour, minute);
  }

  static DateTime _safeDate(int year, int month, int day) {
    final max = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day > max ? max : day, 9);
  }
}

// ---------------------------------------------------------------------------
// MODELOS (tal como los tenías, los dejo igual)
// ---------------------------------------------------------------------------

class ReminderAuto {
  final String title;
  final DateTime date;
  final bool isPayment;
  final bool isBirthday;

  ReminderAuto(
    this.title,
    this.date, {
    this.isPayment = false,
    this.isBirthday = false,
  });
}

class MonthlyPayments {
  final int waterDay, lightDay, internetDay, phoneDay, rentDay;

  MonthlyPayments({
    required this.waterDay,
    required this.lightDay,
    required this.internetDay,
    required this.phoneDay,
    required this.rentDay,
  });

  factory MonthlyPayments.empty() => MonthlyPayments(
    waterDay: 0,
    lightDay: 0,
    internetDay: 0,
    phoneDay: 0,
    rentDay: 0,
  );
}

class BirthdayData {
  final DateTime? userBirthday;
  final DateTime? partnerBirthday;

  BirthdayData({required this.userBirthday, required this.partnerBirthday});
}

class ReminderSettings {
  final int anticipationDays;

  ReminderSettings({required this.anticipationDays});
}

class UserTask {
  final DateTime date;

  UserTask(this.date);
}
