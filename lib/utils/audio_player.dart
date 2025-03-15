import 'package:audioplayers/audioplayers.dart';
import 'package:travail_fute/utils/logger.dart';

class AudioPlayerManager {
  final AudioPlayer player = AudioPlayer();

  void play(String source, String audioPath) {
    final sourceFunctions = {
      'device': () => _playDeviceAudio(audioPath),
      'url': () => _playUrlAudio(audioPath),
      'asset': () => _playAssetAudio(audioPath),
    };

    final playFunction = sourceFunctions[source];

    if (playFunction != null) {
      playFunction();
    } else {
      logger.d('Unknown source: $source');
    }
  }

  void stop() async {
    logger.d('stop Playing function');
    await player.stop();
  }

  void pause() async {
    logger.d('pause Playing function');
    await player.pause();
  }

  void resume() async {
    logger.d('resume Playing function');
    await player.stop();
  }

  void _playDeviceAudio(String audioPath) {
    player.play(DeviceFileSource(audioPath));
  }

  void _playUrlAudio(String audioPath) {
    player.play(UrlSource(audioPath));
  }

  void _playAssetAudio(String audioPath) {
    player.play(AssetSource(audioPath));
  }
}
