// lib/services/notification_service.dart

import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:auri_app/models/reminder_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String androidChannelId = 'auri_channel';
  static const String androidChannelName = 'Auri Recordatorios';
  static const String androidChannelDesc =
      'Recordatorios automáticos y manuales de Auri';

  // ============================================================
  // INIT
  // ============================================================
  Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings();

    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    await _createAndroidChannel();
    await _requestPermissions();
  }

  // ============================================================
  // PERMISSIONS
  // ============================================================
  Future<void> _requestPermissions() async {
    // Firebase Messaging (Android 13+ / iOS)
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (_) {}

    // Local Notifications - iOS only
    try {
      final ios = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}
  }

  // ============================================================
  // ANDROID CHANNEL
  // ============================================================
  Future<void> _createAndroidChannel() async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      const channel = AndroidNotificationChannel(
        androidChannelId,
        androidChannelName,
        description: androidChannelDesc,
        importance: Importance.max,
      );
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  // ============================================================
  // TEST NOTIFICATION
  // ============================================================
  Future<void> showTestNotification() async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        androidChannelId,
        androidChannelName,
        channelDescription: androidChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      'Notificación de prueba',
      'Esto es una prueba de Auri 🟣',
      details,
    );
  }

  // ============================================================
  // SCHEDULE: Reminder Model
  // ============================================================
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        androidChannelId,
        androidChannelName,
        channelDescription: androidChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final tzDate = tz.TZDateTime.from(reminder.dateTime, tz.local);
    final id = reminder.id.hashCode & 0x7fffffff;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      reminder.title,
      reminder.description,
      tzDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ============================================================
  // SCHEDULE FROM JSON (AutoReminderService)
  // ============================================================
  Future<void> scheduleFromJson(Map<String, dynamic> jsonData) async {
    final id =
        jsonData['id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final title = jsonData['title'] ?? 'Recordatorio';
    final dateString = jsonData['date'];
    final repeats = (jsonData['repeats'] ?? 'once').toLowerCase();
    final body = jsonData['body'];

    if (dateString == null) return;

    final date = DateTime.tryParse(dateString);
    if (date == null) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        androidChannelId,
        androidChannelName,
        channelDescription: androidChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final internalId = id.hashCode & 0x7fffffff;

    if (repeats == 'daily') {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        internalId,
        title,
        body,
        _nextDaily(date),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return;
    }

    if (repeats == 'weekly') {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        internalId,
        title,
        body,
        _nextWeekly(date),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return;
    }

    if (repeats == 'monthly') {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        internalId,
        title,
        body,
        _nextMonthly(date),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return;
    }

    if (repeats == 'yearly') {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        internalId,
        title,
        body,
        _nextYearly(date),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return;
    }

    // No repeat
    await flutterLocalNotificationsPlugin.zonedSchedule(
      internalId,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ============================================================
  // REPEAT HELPERS
  // ============================================================
  tz.TZDateTime _nextDaily(DateTime d) {
    final now = tz.TZDateTime.now(tz.local);
    var date = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      d.hour,
      d.minute,
    );
    if (date.isBefore(now)) date = date.add(const Duration(days: 1));
    return date;
  }

  tz.TZDateTime _nextWeekly(DateTime d) {
    final now = tz.TZDateTime.now(tz.local);
    var date = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      d.hour,
      d.minute,
    );
    while (date.weekday != d.weekday || date.isBefore(now)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  tz.TZDateTime _nextMonthly(DateTime d) {
    final now = tz.TZDateTime.now(tz.local);
    int y = now.year;
    int m = now.month;
    int day = d.day;

    try {
      var date = tz.TZDateTime(tz.local, y, m, day, d.hour, d.minute);
      if (date.isBefore(now)) {
        date = tz.TZDateTime(tz.local, y, m + 1, day, d.hour, d.minute);
      }
      return date;
    } catch (_) {
      final last = DateTime(y, m + 1, 0).day;
      return tz.TZDateTime(tz.local, y, m, last, d.hour, d.minute);
    }
  }

  tz.TZDateTime _nextYearly(DateTime d) {
    final now = tz.TZDateTime.now(tz.local);
    var date = tz.TZDateTime(
      tz.local,
      now.year,
      d.month,
      d.day,
      d.hour,
      d.minute,
    );
    if (date.isBefore(now)) {
      date = tz.TZDateTime(
        tz.local,
        now.year + 1,
        d.month,
        d.day,
        d.hour,
        d.minute,
      );
    }
    return date;
  }

  // ============================================================
  // CANCEL
  // ============================================================
  Future<void> cancel(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleManualReminder(Reminder r) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        androidChannelId,
        androidChannelName,
        channelDescription: androidChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final id = r.id.hashCode & 0x7fffffff;
    final tzDate = tz.TZDateTime.from(r.dateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      r.title,
      r.description,
      tzDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
