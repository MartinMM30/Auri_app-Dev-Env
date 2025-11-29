import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';

class TtsPlayerPCM {
  static final TtsPlayerPCM instance = TtsPlayerPCM._();
  TtsPlayerPCM._();

  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;

    await _player.openPlayer();
    await _player.startPlayerFromStream(
      codec: Codec.pcm16,
      sampleRate: 16000,
      numChannels: 1,
      interleaved: true, // obligatorio
      bufferSize: 2048, // obligatorio
    );

    _ready = true;
  }

  Future<void> feed(Uint8List bytes) async {
    await init();
    await _player.feedFromStream(bytes);
  }
}
