// lib/auri/mind/intents/weather_intents.dart

import 'package:auri_app/auri/mind/intents/auri_intent_engine.dart';

class WeatherIntents {
  static AuriIntentResult? detect(String text) {
    if (text.contains("clima") ||
        text.contains("temperatura") ||
        text.contains("tiempo") ||
        text.contains("cómo está el día") ||
        text.contains("como esta el dia")) {
      return AuriIntentResult("get_weather", {});
    }
    return null;
  }
}
