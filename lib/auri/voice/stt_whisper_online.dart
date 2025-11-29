import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:auri_app/services/realtime/auri_realtime.dart';

class STTWhisperOnline {
  STTWhisperOnline._();
  static final STTWhisperOnline instance = STTWhisperOnline._();

  final FlutterSoundRecorder _rec = FlutterSoundRecorder();

  bool _ready = false;
  bool _recording = false;

  StreamSubscription? _ampStream;

  // 🔥 Amplitud
  double _lastAmp = 0.0;
  double get lastAmplitude => _lastAmp;

  final ValueNotifier<double> amplitude = ValueNotifier(0.0);

  // ------------------------------------------------------------
  Future<void> init() async {
    if (_ready) return;

    final mic = await Permission.microphone.request();
    if (!mic.isGranted) throw Exception("Micrófono denegado.");

    await _rec.openRecorder();
    await _rec.setSubscriptionDuration(const Duration(milliseconds: 90));

    _ready = true;
  }

  // ------------------------------------------------------------
  // ------------------------------------------------------------
  Future<void> startRecording() async {
    await init();
    if (_recording) return;

    _recording = true;
    _lastAmp = 0.0;
    amplitude.value = 0.0;

    print("🎙 Auri voice-state → listening");
    print("🎤 startRecorder() — streaming a WS");

    await _ampStream?.cancel();
    _ampStream = null;

    // 🔹 CORRECTO
    AuriRealtime.instance.startVoiceSession();
    await _rec.startRecorder(
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 16000,
      bufferSize: 2048, // ← requerido
      toStream: AuriRealtime.instance.micSink,
    );

    _ampStream = _rec.onProgress!.listen((event) {
      if (event.decibels != null) {
        double norm = ((event.decibels! + 60) / 60).clamp(0.0, 1.0);
        _lastAmp = norm;
        amplitude.value = norm;
      }
    });
  }

  Future<void> stopRecording() async {
    if (!_recording) return;
    _recording = false;

    print("🛑 stopRecorder() — end WS");

    await _rec.stopRecorder();
    await _ampStream?.cancel();
    _ampStream = null;

    amplitude.value = 0.0;

    // 🔹 Señal de FIN
    AuriRealtime.instance.endAudio();

    // 🔹 Señal de cerrar sesión
    AuriRealtime.instance.stopVoiceSession();
  }
}
