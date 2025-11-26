// lib/auri/mind/intents/outfit_intents.dart

import 'package:auri_app/auri/mind/intents/auri_intent_engine.dart';

class OutfitIntents {
  static AuriIntentResult? detect(String text) {
    if (text.contains("qué me pongo") ||
        text.contains("que me pongo") ||
        text.contains("outfit") ||
        text.contains("ropa") ||
        text.contains("cómo debo vestirme") ||
        text.contains("como debo vestirme")) {
      return AuriIntentResult("get_outfit", {});
    }
    return null;
  }
}
