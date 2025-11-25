// lib/storage/reminder_storage.dart

import 'package:hive/hive.dart';
import 'package:auri_app/models/reminder_hive.dart';
import 'package:auri_app/models/reminder_hive_adapter.dart';

class ReminderStorage {
  // Nombre del box de Hive donde se guardan los recordatorios
  static const String boxName = 'reminders_v7';

  /// Abre (o devuelve) el box de recordatorios.
  static Future<Box<ReminderHive>> openBox() async {
    // Registrar el adapter si aún no está registrado
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ReminderAdapter());
    }

    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<ReminderHive>(boxName);
    }

    return await Hive.openBox<ReminderHive>(boxName);
  }

  /// Acceso directo si ya sabes que el box está abierto.
  static Box<ReminderHive> box() {
    return Hive.box<ReminderHive>(boxName);
  }
}
