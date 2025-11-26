import 'package:flutter_tts/flutter_tts.dart';

class TTSEngine {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> speak(String text) async {
    await _tts.setLanguage("es-ES");
    await _tts.setSpeechRate(0.9);
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }
}
