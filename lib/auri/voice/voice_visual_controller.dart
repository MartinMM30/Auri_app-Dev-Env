import 'package:flutter/material.dart';

class VoiceVisualController {
  static final ValueNotifier<bool> isListening = ValueNotifier(false);

  static void onStartListening() {
    isListening.value = true;
  }

  static void onStopListening() {
    isListening.value = false;
  }
}
