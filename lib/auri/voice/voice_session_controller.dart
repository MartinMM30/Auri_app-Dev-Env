// lib/auri/voice/voice_session_controller.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:auri_app/auri/mind/auri_mind_engine.dart';
import 'package:auri_app/auri/voice/stt_whisper_online.dart';
import 'package:auri_app/auri/voice/tts_engine.dart';
import 'package:auri_app/auri/voice/voice_visual_controller.dart';
import 'package:auri_app/auri/voice/slime_voice_state.dart';

class VoiceSessionController {
  static bool _isListening = false;
  static bool _isSpeaking = false;
  static bool _continuousMode = false;

  static Timer? _silenceTimer;

  static bool get isListening => _isListening;

  // Activar conversación continua
  static void enableContinuousMode() {
    _continuousMode = true;
  }

  // ---------------------------------------------------------
  // INICIAR GRABACIÓN
  // ---------------------------------------------------------
  static Future<void> startRecording() async {
    if (_isListening) return;

    _isListening = true;

    // Vibración ligera (SO compatible)
    HapticFeedback.lightImpact();

    // Animaciones
    VoiceVisualController.onStartListening();
    SlimeVoiceStates.listening();

    await STTWhisperOnline.startRecording();

    _startSilenceWatcher();
  }

  // ---------------------------------------------------------
  // DETENER GRABACIÓN
  // ---------------------------------------------------------
  static Future<void> stopRecording({bool cancelled = false}) async {
    if (!_isListening) return;

    _isListening = false;
    _silenceTimer?.cancel();
    VoiceVisualController.onStopListening();

    File? audio = await STTWhisperOnline.stopRecording();
    if (audio == null || cancelled) {
      await TTSEngine.speak("Grabación cancelada 💜");
      SlimeVoiceStates.idle();
      return;
    }

    SlimeVoiceStates.thinking();

    final text = await STTWhisperOnline.transcribe(audio);

    if (text.trim().isEmpty) {
      await TTSEngine.speak("No escuché nada 💜");
      SlimeVoiceStates.idle();
      return;
    }

    final reply = await AuriMindEngine.instance.processUserMessage(text);

    _isSpeaking = true;
    SlimeVoiceStates.talking();
    await TTSEngine.speak(reply.reply);

    _isSpeaking = false;
    SlimeVoiceStates.idle();

    if (_continuousMode) {
      await Future.delayed(const Duration(milliseconds: 350));
      return startRecording();
    }
  }

  // ---------------------------------------------------------
  // CANCELAR DOBLE TOQUE
  // ---------------------------------------------------------
  static void cancel() {
    if (_isListening) {
      stopRecording(cancelled: true);
    } else if (_isSpeaking) {
      TTSEngine.stop();
      SlimeVoiceStates.idle();
      VoiceVisualController.onStopListening();
    }
  }

  // ---------------------------------------------------------
  // DETECCIÓN DE SILENCIO
  // ---------------------------------------------------------
  static void _startSilenceWatcher() {
    _silenceTimer?.cancel();

    _silenceTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      final amp = STTWhisperOnline.lastAmplitude;

      if (amp < 0.01) {
        _silenceTimer?.cancel();
        stopRecording();
      }
    });
  }

  static Future<void> startVoiceSession() async {
    await startRecording();
  }
}
