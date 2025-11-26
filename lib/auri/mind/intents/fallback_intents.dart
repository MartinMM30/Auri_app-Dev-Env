// lib/auri/mind/intents/smalltalk_intents.dart

import 'package:auri_app/auri/mind/intents/auri_intent_engine.dart';

class SmalltalkIntents {
  static AuriIntentResult? detect(String text) {
    if (text.contains("hola") || text.contains("buenos días")) {
      return AuriIntentResult("smalltalk_greeting", {});
    }

    if (text.contains("gracias") || text.contains("te lo agradezco")) {
      return AuriIntentResult("smalltalk_thanks", {});
    }

    if (text.contains("quién eres") ||
        text.contains("que eres") ||
        text.contains("qué eres")) {
      return AuriIntentResult("smalltalk_identity", {});
    }

    return null;
  }
}

class FallbackIntents {
  static AuriIntentResult detect(String text) {
    return AuriIntentResult("fallback", {});
  }
}
