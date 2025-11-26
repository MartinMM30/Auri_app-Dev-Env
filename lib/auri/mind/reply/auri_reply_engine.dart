// lib/auri/mind/auri_reply_engine.dart

import 'dart:math';

import 'package:auri_app/auri/mind/intents/auri_intent_engine.dart';

/// Motor de respuestas genéricas:
/// - Fallback cuando no se reconoce bien el intent
/// - Comentarios suaves cuando Auri no puede hacer algo todavía
class AuriReplyEngine {
  static final AuriReplyEngine instance = AuriReplyEngine._internal();
  AuriReplyEngine._internal();

  final _rand = Random();

  String generate(AuriIntentResult intentResult, String originalText) {
    switch (intentResult.intent) {
      case 'fallback':
        return _fallbackReply(originalText);

      default:
        // Para intents no mapeados explícitamente todavía
        return _genericUnknownIntentReply(originalText, intentResult.intent);
    }
  }

  // ============================================================
  // FALLBACKS
  // ============================================================
  String _fallbackReply(String text) {
    final options = <String>[
      "Todavía estoy aprendiendo 💜. No estoy segura de cómo ayudarte con eso, pero podemos probar con un recordatorio, clima u outfit.",
      "Mmm, creo que no entendí bien 🧠. ¿Puedes decirlo de otra forma o pedirme algo como 'recuérdame...' o 'qué clima hace'?",
      "Por ahora entiendo mejor cosas como recordatorios, clima y outfit 👕. ¿Quieres que lo intentemos por ahí?",
      "No estoy 100% segura de eso todavía 😅, pero si quieres puedo ayudarte con recordatorios, clima u organización de tu día.",
    ];

    return options[_rand.nextInt(options.length)];
  }

  String _genericUnknownIntentReply(String text, String intent) {
    final options = <String>[
      "He detectado algo como '$intent', pero aún no tengo una acción programada para eso 🤖. Podemos configurarlo en el futuro.",
      "Sé que quisiste algo de tipo '$intent', pero esa habilidad todavía no está lista 💜. Puedo ayudarte mientras con tus recordatorios o el clima.",
      "Anoto mentalmente que quieres que haga '$intent' 👀. Por ahora, sigo especializada en recordatorios, clima y outfits.",
    ];
    return options[_rand.nextInt(options.length)];
  }
}
