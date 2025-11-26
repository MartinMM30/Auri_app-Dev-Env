// lib/auri/mind/intents/auri_intent_engine.dart

import 'package:auri_app/auri/mind/intents/reminder_intents.dart';
import 'package:auri_app/auri/mind/intents/weather_intents.dart';
import 'package:auri_app/auri/mind/intents/outfit_intents.dart';

import 'package:auri_app/auri/mind/intents/smalltalk_intents.dart' as st;
import 'package:auri_app/auri/mind/intents/fallback_intents.dart' as fb;

class AuriIntentResult {
  final String intent;
  final Map<String, dynamic> entities;

  AuriIntentResult(this.intent, this.entities);
}

class AuriIntentEngine {
  static final AuriIntentEngine instance = AuriIntentEngine._internal();
  AuriIntentEngine._internal();

  AuriIntentResult detectIntent(String rawText) {
    final text = rawText.toLowerCase().trim();

    // 1) 🧠 Recordatorios
    final rem = ReminderIntents.detect(text);
    if (rem != null) return rem;

    // 2) ⛅ Clima
    final weather = WeatherIntents.detect(text);
    if (weather != null) return weather;

    // 3) 👕 Outfit
    final outfit = OutfitIntents.detect(text);
    if (outfit != null) return outfit;

    // 4) 💬 Smalltalk
    final talk = st.SmalltalkIntents.detect(text);
    if (talk != null) return talk;

    // 5) ❓ Fallback
    return fb.FallbackIntents.detect(text);
  }
}
