import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class AuriTtsStreamPlayer {
  AuriTtsStreamPlayer._();
  static final AuriTtsStreamPlayer instance = AuriTtsStreamPlayer._();

  final AudioPlayer _player = AudioPlayer();
  final List<int> _buffer = [];

  /// Agrega chunk MP3 desde WebSocket
  Future<void> addChunk(Uint8List data) async {
    _buffer.addAll(data);
  }

  /// Reproduce cuando el backend manda "tts_end"
  Future<void> finalize() async {
    if (_buffer.isEmpty) return;

    final bytes = Uint8List.fromList(_buffer);
    _buffer.clear();

    await _player.stop();

    await _player.play(BytesSource(bytes));
  }

  Future<void> stop() async {
    await _player.stop();
    _buffer.clear();
  }
}
