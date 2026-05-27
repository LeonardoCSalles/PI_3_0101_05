import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static String _musicaAtual = '';

  // Toca uma música em loop
  static Future<void> tocar(String arquivo) async {
    // Evita reiniciar a mesma música
    if (_musicaAtual == arquivo) return;

    _musicaAtual = arquivo;
    await _player.stop();
    await Future.delayed(const Duration(milliseconds: 200));
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('audio/$arquivo'));
  }

  // Para a música
  static Future<void> parar() async {
    _musicaAtual = '';
    await _player.stop();
  }

  // Ajusta o volume (0.0 a 1.0)
  static Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }
}