import 'package:auri_app/services/slime_mood_engine.dart';

class SlimeVoiceStates {
  static void listening() => SlimeMoodEngine.setVoiceState("listening");

  static void thinking() => SlimeMoodEngine.setVoiceState("thinking");

  static void talking() => SlimeMoodEngine.setVoiceState("talking");

  static void idle() => SlimeMoodEngine.setVoiceState("idle");
}
