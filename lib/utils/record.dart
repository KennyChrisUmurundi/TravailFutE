import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:travail_fute/services/credential_service.dart';
import 'package:travail_fute/utils/openai.dart';

class Recording {
  final logger = Logger();
  final record =  AudioRecorder();
  final OpenAI openAI = OpenAI();
  final CredentialService credentialService = CredentialService();

  String audioPath = "";
  late final String number;
  late final String deviceToken; // Add deviceToken

  late final BuildContext context;
  Recording(this.context); // Add deviceToken to constructor

  String given_speech = "";
  List<Map<String, String>> messages = [];
  late Map<String, dynamic> response_message;

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

  Future<String> loadPrompt() async {
  return await rootBundle.loadString('assets/prompts/notification_prompt.txt');
}

  Future<String> stopRecording([String? number]) async {
    logger.d("Stopping record function Check");
    try {
      await record.stop();
    } catch (e) {
      logger.e("Error stopping recording: $e");
    }
    checkRecordingStatus();
    //TODO: Send to Api, then reset the audiopath
    logger.i("INITIALIZING UPLOAD RECORD FUNTION");
    
    try {
      given_speech = await openAI.transcribeAudio(audioPath);
    } catch (e) {
      logger.e("Error transcribing audio: $e");
    }
    // String promptTemplate = await loadPrompt();
    // promptTemplate.replaceAll("{USER_VOICE_TEXT}", given_speech);
    // messages = [
    //   {'role': 'developer', "content": promptTemplate},
    //   {'role': 'user', 'content': given_speech},
    // ];
    // Map<String, dynamic> response_message = await openAI.generateChatCompletion(messages);
    // Map<String, dynamic> notificationData = response_message["notification_data"];
    // print("THE RESPONSE MESSAGE  $response_message");
    // final outputFilePath = await openAI.getWritableFilePath('speech_${DateTime.now().millisecondsSinceEpoch}.mp3');
    // await openAI.textToSpeech(response_message["user_response"], outputFilePath);
    audioPath = "";
    //, eventually delete the record on the device so not to make it full?
    // final recordService = RecordingService(callNumber, callPath)
    return given_speech;
  }

  Future<bool> checkRecordingStatus() async {
    bool isRecording = await record.isRecording();
    logger.d("Is recordign:::::; $isRecording");
    return isRecording;
  }
}
