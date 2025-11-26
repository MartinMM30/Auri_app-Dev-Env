import 'package:auri_app/services/slime_mood_engine.dart';

/// Extensión emocional avanzada.
/// Combinará clima, agenda, hábitos y estado del usuario.
class AuriEmotionEngine {
  static String moodDescription(SlimeMood mood) {
    return mood.label;
  }
}
