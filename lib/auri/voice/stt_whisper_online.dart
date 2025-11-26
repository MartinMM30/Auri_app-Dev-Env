import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_sound/flutter_sound.dart';

class STTWhisperOnline {
  static final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  static bool _ready = false;

  static const String whisperUrl = "http://10.0.2.2:8000/transcribe";

  /// amplitud normalizada (0–1)
  static double lastAmplitude = 0.0;

  static StreamSubscription? _progressSub;

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------
  static Future<void> init() async {
    if (_ready) return;

    await _recorder.openRecorder();

    // Permitir que el recorder emita progreso
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));

    _ready = true;
  }

  // ------------------------------------------------------------
  // START RECORDING
  // ------------------------------------------------------------
  static Future<void> startRecording() async {
    await init();

    lastAmplitude = 0.0;

    await _recorder.startRecorder(
      toFile: "auri_voice.wav",
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
      numChannels: 1,
    );

    // ---- LECTURA DE AMPLITUD MEDIANTE EL STREAM OFICIAL ----
    _progressSub?.cancel();
    _progressSub = _recorder.onProgress?.listen((event) {
      if (event == null) return;

      double db = event.decibels ?? -60;
      double amp = ((db + 60) / 60).clamp(0.0, 1.0);

      lastAmplitude = amp;
    });
  }

  // ------------------------------------------------------------
  // STOP RECORDING
  // ------------------------------------------------------------
  static Future<File?> stopRecording() async {
    if (!_ready) return null;

    final path = await _recorder.stopRecorder();

    await _progressSub?.cancel();
    _progressSub = null;

    lastAmplitude = 0.0;

    if (path == null) return null;

    return File(path);
  }

  // ------------------------------------------------------------
  // TRANSCRIBIR VIA WHISPER
  // ------------------------------------------------------------
  static Future<String> transcribe(File audioFile) async {
    try {
      final dio = Dio();

      final form = FormData.fromMap({
        "file": await MultipartFile.fromFile(audioFile.path),
      });

      final response = await dio.post(
        whisperUrl,
        data: form,
        options: Options(
          contentType: "multipart/form-data",
          receiveTimeout: const Duration(seconds: 120),
        ),
      );

      return response.data["text"] ?? "";
    } catch (e) {
      return "Error conectando a Whisper: $e";
    }
  }

  // ------------------------------------------------------------
  // AMPLITUD PUBLICA
  // ------------------------------------------------------------
  static double getAmplitude() => lastAmplitude;
}
