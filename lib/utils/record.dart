import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:travail_fute/services/recording_service.dart';

class Recording {
  final logger = Logger();
  final record =  AudioRecorder();

  String audioPath = "";
  late final String number;
  late final String deviceToken; // Add deviceToken

  late final BuildContext context;
  Recording(this.context); // Add deviceToken to constructor

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

  Future<void> stopRecording([String? number]) async {
    logger.d("Stopping record function Check");
    logger.d("number: $number");
    await record.stop();
    //TODO: Send to Api, then reset the audiopath
    logger.i("INITIALIZING UPLOAD RECORD FUNTION");

    try {
      print("SENDING REQUEST TO UPLOAD RECORDING");
      final recordingService = RecordingService(context, number ?? '', audioPath); // Pass context, deviceToken and handle default number
  // Pass context, deviceToken and handle default number
      recordingService.uploadRecording();
    } catch (e) {
      logger.d("FAILED TO UPLOAD RECORDING $e");
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
