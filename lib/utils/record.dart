import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class Recording {
  final logger = Logger();
  final record = Record();
  late final String audioPath;

  void startRecording() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${appDirectory.path}/audio_$timestamp.m4a';

    audioPath = filePath;

    if (await record.hasPermission()) {
      // Start recording
      await record.start(
        path: filePath,
        encoder: AudioEncoder.aacLc, // by default
        bitRate: 128000, // by default
        samplingRate: 44100, // by default
      );
      logger.d("recording started and is kept at $filePath");
    }
  }

  void stopRecording() async {
    logger.d("Stopping record function Check");
    await record.stop();
    //TODO: Send to Api, then reset the audiopath, eventually delete the record on the device so not to make it full?
  }

  Future<bool> checkRecordingStatus() async {
    bool isRecording = await record.isRecording();
    logger.d("Is recordign:::::; $isRecording");
    return isRecording;
  }
}
