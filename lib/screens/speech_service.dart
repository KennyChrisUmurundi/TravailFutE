import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:travail_fute/utils/logger.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Check and request microphone permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        logger.i('Microphone permission denied');
        return false;
      }

      _isAvailable = await _speech.initialize(
        onStatus: (status) => logger.i('Speech status: $status'),
        onError: (error) => logger.e('Speech error: $error'),
      );
      
      _isInitialized = true;
      return _isAvailable;
    } catch (e) {
      logger.e('Failed to initialize speech: $e');
      return false;
    }
  }

  Future<String?> listen({String locale = 'fr_FR'}) async {
    if (!_isInitialized && !await initialize()) {
      return null;
    }

    String? recognizedText;
    await _speech.listen(
      onResult: (result) => recognizedText = result.recognizedWords,
      localeId: locale,
      listenMode: stt.ListenMode.dictation,
      cancelOnError: true,
      partialResults: true,
    );

    return recognizedText;
  }

  Future<void> stop() async {
    if (_isInitialized) {
      await _speech.stop();
    }
  }

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isAvailable;
}