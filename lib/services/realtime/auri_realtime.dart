import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:auri_app/auri/voice/tts_player_pcm.dart';

class AuriRealtime {
  static final AuriRealtime instance = AuriRealtime._();
  AuriRealtime._();

  WebSocketChannel? _ch;
  bool _connected = false;
  bool _connecting = false;

  Timer? _retryTimer;
  Timer? _heartbeatTimer;

  final StreamController<Uint8List> _micStream =
      StreamController<Uint8List>.broadcast();

  StreamSink<Uint8List> get micSink => _micStream.sink;

  final List<void Function(String)> _onPartial = [];
  final List<void Function(String)> _onFinal = [];
  final List<void Function(bool)> _onThinking = [];
  final List<void Function(double)> _onLip = [];
  final List<void Function(Map<String, dynamic>)> _onAction = [];
  final List<void Function(Uint8List)> _onAudio = [];

  void addOnPartial(void Function(String) f) => _onPartial.add(f);
  void addOnFinal(void Function(String) f) => _onFinal.add(f);
  void addOnThinking(void Function(bool) f) => _onThinking.add(f);
  void addOnLip(void Function(double) f) => _onLip.add(f);
  void addOnAction(void Function(Map<String, dynamic>) f) => _onAction.add(f);

  Future<void> ensureConnected() async {
    if (_connected || _connecting) return;
    return connect();
  }

  Future<void> connect() async {
    if (_connected || _connecting) return;

    const url = "wss://auri-backend-whisper.onrender.com/realtime";
    print("🔌 Conectando → $url");

    _connecting = true;

    try {
      _ch = WebSocketChannel.connect(Uri.parse(url));
      _connected = true;
      _connecting = false;

      print("🟢 WS conectado");

      _sendJsonSafe({
        "type": "client_hello",
        "client": "auri_app",
        "version": "1.0.0-v4",
      });

      _micStream.stream.listen((bytes) {
        try {
          _ch?.sink.add(bytes);
        } catch (_) {}
      });

      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        _sendJsonSafe({"type": "ping"});
      });

      _ch!.stream.listen(
        (data) {
          // AUDIO PCM16 DEL BACKEND
          if (data is Uint8List) {
            TtsPlayerPCM.instance.feed(data); // ← TTS en vivo
            return;
          }
          _handleMessage(data);
        },
        onDone: () {
          print("🔌 WS cerrado");
          _connected = false;
          _scheduleReconnect();
        },
        onError: (err) {
          print("❌ WS error: $err");
          _connected = false;
          _scheduleReconnect();
        },
      );
    } catch (e) {
      print("❌ Falló conexión WS: $e");
      _connected = false;
      _connecting = false;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_retryTimer != null) return;

    _retryTimer = Timer(const Duration(seconds: 3), () {
      print("🔄 Reintentando conexión…");
      _retryTimer = null;
      connect();
    });
  }

  void _sendJsonSafe(Map<String, dynamic> payload) {
    if (!_connected) return;
    try {
      _ch?.sink.add(jsonEncode(payload));
    } catch (_) {}
  }

  void startVoiceSession() {
    _sendJsonSafe({"type": "start_session"});
  }

  void stopVoiceSession() {
    _sendJsonSafe({"type": "stop_session"});
  }

  void endAudio() {
    _sendJsonSafe({"type": "audio_end"});
  }

  void sendText(String text) {
    _sendJsonSafe({"type": "text_command", "text": text});
  }

  void _handleMessage(dynamic data) {
    Map<String, dynamic> msg;

    try {
      msg = Map<String, dynamic>.from(jsonDecode(data));
    } catch (_) {
      print("⚠ No es JSON: $data");
      return;
    }

    switch (msg["type"]) {
      case "stt_partial":
      case "reply_partial":
        for (final f in _onPartial) f(msg["text"] ?? "");
        break;

      case "stt_final":
      case "reply_final":
        for (final f in _onFinal) f(msg["text"] ?? "");
        break;

      case "thinking":
        for (final f in _onThinking) f(msg["state"] == true);
        break;

      case "lip_sync":
        final e = (msg["energy"] ?? 0).toDouble();
        for (final f in _onLip) f(e);
        break;

      case "action":
      case "action_create_reminder":
        for (final f in _onAction) f(msg);
        break;

      default:
        print("ℹ Evento desconocido: $msg");
    }
  }

  Future<void> close() async {
    await _ch?.sink.close();
    await _micStream.close();
    _connected = false;
    _heartbeatTimer?.cancel();
  }
}
