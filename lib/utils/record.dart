import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:travail_fute/services/recording_service.dart';

class Recording {
  final logger = Logger();
  final record =  AudioRecorder();

  String audioPath = "";
  late final String number;

  void startRecording() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${appDirectory.path}/audio_$timestamp.m4a';

    audioPath = filePath;

    if (await record.hasPermission()) {
      // Start recording
      await record.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc, // updated enum name
          bitRate: 128000, // now specified through RecordConfig
          sampleRate: 44100, // renamed from samplingRate
        ), path: filePath,
      );
      logger.d("recording started and is kept at $filePath");
    }
  }

  Future<void> stopRecording(number) async {
    logger.d("Stopping record function Check");
    await record.stop();
    //TODO: Send to Api, then reset the audiopath
    logger.i("INITIALIZING UPLOAD RECORD FUNTION");

    try {
      final recordingService = RecordingService(number, audioPath);
      recordingService.uploadRecording();
    } catch (e) {
      logger.d(e);
    }

    audioPath = "";
    //, eventually delete the record on the device so not to make it full?
    // final recordService = RecordingService(callNumber, callPath)
  }

  Future<bool> checkRecordingStatus() async {
    bool isRecording = await record.isRecording();
    logger.d("Is recordign:::::; $isRecording");
    return isRecording;
  }
}
