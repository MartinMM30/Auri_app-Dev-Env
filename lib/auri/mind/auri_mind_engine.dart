// lib/auri/mind/auri_mind_engine.dart

import 'package:shared_preferences/shared_preferences.dart';

import 'package:auri_app/auri/mind/intents/auri_intent_engine.dart';
import 'package:auri_app/auri/mind/intents/reminder_intents.dart';
import 'package:auri_app/auri/mind/reply/auri_reply_engine.dart';

import 'package:auri_app/services/weather_service.dart';
import 'package:auri_app/models/weather_model.dart';

class AuriReply {
  final String reply;
  final String intent;
  final Map<String, dynamic> data;

  AuriReply(this.reply, {required this.intent, required this.data});
}

class AuriMindEngine {
  static final AuriMindEngine instance = AuriMindEngine._internal();
  AuriMindEngine._internal();

  // ============================================================
  // UTILIDAD: Obtener ciudad del usuario
  // ============================================================
  Future<String> _getUserCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userCity') ?? 'San José';
  }

  // ============================================================
  // NÚCLEO: Procesar mensaje del usuario
  // ============================================================
  Future<AuriReply> processUserMessage(String text) async {
    final intentResult = AuriIntentEngine.instance.detectIntent(text);

    switch (intentResult.intent) {
      // ============================================================
      // ☁️ CLIMA
      // ============================================================
      case "get_weather":
        return await _handleWeatherIntent();

      // ============================================================
      // 👕 OUTFIT
      // ============================================================
      case "get_outfit":
        return await _handleOutfitIntent();

      // ============================================================
      // ⏰ CREAR RECORDATORIO (YA CON ReminderIntents)
      // ============================================================
      case "add_reminder":
        return await _handleAddReminder(intentResult.entities);

      // ============================================================
      // 🗣 SMALLTALK
      // ============================================================
      case "smalltalk_greeting":
        return AuriReply(
          "¡Hola! 💜 ¿En qué puedo ayudarte hoy?",
          intent: "smalltalk_greeting",
          data: {},
        );

      case "smalltalk_thanks":
        return AuriReply(
          "¡Con gusto! ✨ ¿Necesitas algo más?",
          intent: "smalltalk_thanks",
          data: {},
        );

      case "smalltalk_identity":
        return AuriReply(
          "Soy Auri 💜, tu asistente personal inteligente. Te ayudo con tus recordatorios, clima, outfits y más.",
          intent: "smalltalk_identity",
          data: {},
        );

      // ============================================================
      // 🔁 FALLBACK
      // ============================================================
      default:
        final fallback = AuriReplyEngine.instance.generate(intentResult, text);

        return AuriReply(
          fallback,
          intent: intentResult.intent,
          data: intentResult.entities,
        );
    }
  }

  // ============================================================
  // HANDLERS
  // ============================================================

  // ☁️ CLIMA
  Future<AuriReply> _handleWeatherIntent() async {
    final city = await _getUserCity();
    final WeatherModel weather = await WeatherService().getWeather(city);

    final reply =
        "En ${weather.cityName} la temperatura es de ${weather.temperature.toStringAsFixed(1)}°C "
        "con ${weather.description} ${weather.emoji}.";

    return AuriReply(reply, intent: "get_weather", data: {"weather": weather});
  }

  // 👕 OUTFIT
  Future<AuriReply> _handleOutfitIntent() async {
    final city = await _getUserCity();
    final WeatherModel weather = await WeatherService().getWeather(city);

    final suggestion = weather.outfitSuggestion;

    final reply =
        "Con el clima actual de ${weather.temperature.toStringAsFixed(1)}°C en ${weather.cityName}, "
        "lo ideal sería: $suggestion 👕";

    return AuriReply(
      reply,
      intent: "get_outfit",
      data: {"weather": weather, "suggestion": suggestion},
    );
  }

  // ⏰ CREAR RECORDATORIO (NUEVO SISTEMA)
  Future<AuriReply> _handleAddReminder(Map<String, dynamic> entities) async {
    final reminder = await ReminderIntents.createReminderFromEntities(entities);

    final dt = DateTime.tryParse(reminder.dateIso);
    final when = dt != null
        ? ReminderIntents.humanReadableDate(dt)
        : "la fecha indicada";

    final reply =
        "Perfecto 💜. Creé un recordatorio para \"${reminder.title}\" el $when.";

    return AuriReply(
      reply,
      intent: "add_reminder",
      data: {...entities, "reminderId": reminder.id, "saved": true},
    );
  }
}
