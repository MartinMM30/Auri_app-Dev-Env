// lib/config/app_initializer.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:auri_app/models/reminder_hive.dart';
import 'package:auri_app/models/reminder_hive_adapter.dart';
import 'package:auri_app/pages/survey/storage/survey_storage.dart';

class AppInitializer {
  Future<bool> init() async {
    // 1. Inicializar Hive (solo una vez en toda la app)
    await Hive.initFlutter();

    // 2. Registrar adapter de ReminderHive (si aún no está registrado)
    if (!Hive.isAdapterRegistered(ReminderAdapter().typeId)) {
      Hive.registerAdapter(ReminderAdapter());
    }

    // 3. Asegurar que el box 'reminders' esté limpio y tipado correctamente
    if (Hive.isBoxOpen('reminders')) {
      await Hive.box('reminders').close();
    }

    await Hive.openBox<ReminderHive>('reminders');

    // 4. Cargar estado de la encuesta (puedes ajustar a tu implementación real)
    //    Usamos SurveyStorage.loadSurvey() porque ya lo usas en AutoReminderService.
    final survey = await SurveyStorage.loadSurvey();
    final isSurveyCompleted = survey != null;

    // (Opcional) Guarda el estado en SharedPreferences si quieres
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('survey_completed', isSurveyCompleted);

    return isSurveyCompleted;
  }
}
