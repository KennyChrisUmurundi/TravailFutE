import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:travail_fute/services/credential_service.dart';
import 'package:logger/logger.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class OpenAI {
  final String baseUrl;
  final CredentialService credentialService = CredentialService();
  final Logger logger = Logger();
  static String? _apiKey;
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();

  OpenAI({this.baseUrl = 'https://api.openai.com/v1'}) {
    logger.i('🔑 OpenAI API initialized');
    _initializeApiKey(); // Initialize API key in the constructor
  }

  Future<void> _initializeApiKey() async {
    if (_apiKey == null) {
      _apiKey = await credentialService.getOpenAiKey();
      logger.i('🔑 OpenAI API key initialized: $_apiKey');
    }
  }

  Future<String> transcribeAudio(String filePath) async {
    await _initializeApiKey();
    if (_apiKey == null || _apiKey!.isEmpty) throw Exception("❌ API key is not initialized");

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/audio/transcriptions'),
    );
    request.headers['Authorization'] = 'Bearer $_apiKey';
    request.headers['Content-Type'] = 'multipart/form-data';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    request.fields['model'] = 'whisper-1';
    request.fields['response_format'] = 'text';

    final response = await request.send();
    if (response.statusCode == 200) {
      logger.i('✅ Audio transcribed successfully');
      String responseBody = await response.stream.bytesToString();
      return responseBody;
    } else {
      throw Exception('❌ Error transcribing audio: ${response.statusCode}');
    }
  }

  Future<String> generateChatCompletion(List<Map<String, String>> messages) async {
    await _initializeApiKey();
    if (_apiKey == null || _apiKey!.isEmpty) throw Exception("❌ API key is not initialized");

    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': messages,
      }),
    );

    if (response.statusCode == 200) {
      logger.i('✅ Chat completion generated successfully');
      return jsonDecode(response.body)['choices'][0]['message']['content'];
    } else {
      throw Exception('❌ Error generating chat completion: ${response.statusCode}');
    }
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Future<void> textToSpeech(String inputText, String outputFilePath) async {
    await _initializeApiKey();
    if (_apiKey == null || _apiKey!.isEmpty) throw Exception("❌ API key is not initialized");

    final response = await http.post(
      Uri.parse('$baseUrl/audio/speech'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'tts-1',
        'input': inputText,
        'voice': 'nova',
      }),
    );

    if (response.statusCode == 200) {
      logger.i('✅ Text to speech conversion successful');
      final bytes = response.bodyBytes;
      final file = File(outputFilePath);
      await file.writeAsBytes(bytes);
      await playAudio(outputFilePath);
      await file.delete();
      logger.i('✅ Text to speech conversion successful, saved to $outputFilePath');
    } else {
      throw Exception('❌ Error converting text to speech: ${response.statusCode}');
    }
  }

  Future<void> playAudio(String filePath) async {
    await audioPlayer.play(DeviceFileSource(filePath));
    logger.i('✅ Audio playing successfully');
  }

  Future<String> getWritableFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }
}

void main() async {
  final openAI = OpenAI();

  // Example usage
  try {
    final messages = [
      {'role': 'system', 'content': 'You are a helpful assistant.'},
      {'role': 'user', 'content': 'Write a haiku about recursion in programming.'},
    ];
    final chatCompletion = await openAI.generateChatCompletion(messages);
    print(chatCompletion);

    // Play the generated text
    await openAI.speak(chatCompletion);

    // Convert text to speech and save to file
    final outputFilePath = await openAI.getWritableFilePath('speech.mp3');
    await openAI.textToSpeech(chatCompletion, outputFilePath);

    // Play the saved audio file
    await openAI.playAudio(outputFilePath);
  } catch (e) {
    print(e);
  }
}

