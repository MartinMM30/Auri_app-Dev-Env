// lib/services/notification_service.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter_timezone/flutter_timezone.dart';

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

  bool _initialized = false;

  // ============================================================
  // INIT
  // ============================================================
  Future<void> init() async {
    if (_initialized) return;

    await _configureTimezone();
    await _initializeLocalNotifications();
    await _requestPermissions();
    await _createAndroidChannel();

    _initialized = true;
    debugPrint("🔔 NotificationService inicializado correctamente");
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) await init();
  }

  // ============================================================
  // TIMEZONE
  // ============================================================
  Future<void> _configureTimezone() async {
    tzdata.initializeTimeZones();

    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));

      debugPrint("🌎 Zona horaria configurada: $localTz");
    } catch (e) {
      debugPrint("⚠️ Error obteniendo zona horaria, usando UTC");
      tz.setLocalLocation(tz.getLocation("UTC"));
    }
  }

  // ============================================================
  // INITIALIZE LOCAL NOTIFICATIONS
  // ============================================================
  Future<void> _initializeLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("🔔 Notificación pulsada: ${details.payload}");
      },
    );
  }

  // ============================================================
  // PERMISSIONS
  // ============================================================
  Future<void> _requestPermissions() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (e) {
      debugPrint("⚠️ Error permiso FCM: $e");
    }

    if (Platform.isAndroid) {
      try {
        final android = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

        await android?.requestNotificationsPermission();
      } catch (e) {
        debugPrint("⚠️ Error permiso local Android: $e");
      }
    }

    if (Platform.isIOS) {
      try {
        final ios = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

        await ios?.requestPermissions(alert: true, badge: true, sound: true);
      } catch (e) {
        debugPrint("⚠️ Error permiso local iOS: $e");
      }
    }
  }

  // ============================================================
  // ANDROID CHANNEL
  // ============================================================
  Future<void> _createAndroidChannel() async {
    final android = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      const channel = AndroidNotificationChannel(
        androidChannelId,
        androidChannelName,
        description: androidChannelDesc,
        importance: Importance.max,
      );

      await android.createNotificationChannel(channel);
      debugPrint("📡 Canal de notificaciones creado");
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================
  int _internalIdFromString(String id) => id.hashCode & 0x7fffffff;

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        androidChannelId,
        androidChannelName,
        channelDescription: androidChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  tz.TZDateTime _normalize(DateTime dt) {
    final now = tz.TZDateTime.now(tz.local);
    var target = tz.TZDateTime.from(dt, tz.local);

    if (target.isBefore(now)) {
      target = now.add(const Duration(seconds: 5));
    }

    return target;
  }

  // ============================================================
  // SCHEDULE REMINDER
  // ============================================================
  Future<void> scheduleReminder(Reminder r) async {
    await _ensureInitialized();

    final date = _normalize(r.dateTime);
    final id = _internalIdFromString(r.id);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      r.title,
      r.description,
      date,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: r.id,
    );

    debugPrint("⏰ Recordatorio programado → ${r.title} @ $date");
  }

  // ============================================================
  // SCHEDULE FROM JSON
  // ============================================================
  Future<void> scheduleFromJson(Map<String, dynamic> json) async {
    await _ensureInitialized();

    final idStr =
        json["id"]?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final parsed = DateTime.tryParse(json["date"] ?? "");
    if (parsed == null) return;

    final title = json["title"] ?? "Recordatorio";
    final body = json["body"];
    final repeats = (json["repeats"] ?? "once").toLowerCase();

    final date = _normalize(parsed);
    final id = _internalIdFromString(idStr);

    DateTimeComponents? match;
    switch (repeats) {
      case "daily":
        match = DateTimeComponents.time;
        break;
      case "weekly":
        match = DateTimeComponents.dayOfWeekAndTime;
        break;
      case "monthly":
        match = DateTimeComponents.dayOfMonthAndTime;
        break;
      case "yearly":
        match = DateTimeComponents.dateAndTime;
        break;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      date,
      _details(),
      matchDateTimeComponents: match,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: idStr,
    );
  }

  // ============================================================
  // CANCEL
  // ============================================================
  Future<void> cancel(int id) async {
    await _ensureInitialized();
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelByStringId(String id) async =>
      cancel(_internalIdFromString(id));

  Future<void> cancelAll() async {
    await _ensureInitialized();
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
