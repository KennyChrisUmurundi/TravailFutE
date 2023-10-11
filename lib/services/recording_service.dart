import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path/path.dart';

const String apiUrl =
    "https://857d-2a02-2788-1b8-69f-acfb-61a6-6bf2-5e13.ngrok-free.app/api/voice_processor/call_record/";

class RecordingService {
  final String callNumber;
  final String callPath;
  final logger = Logger();
  RecordingService(
    this.callNumber,
    this.callPath,
  );

  Future<bool> uploadRecording() async {
    // final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    final file = File(callPath);
    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add the 'call_file' file part
      request.files.add(http.MultipartFile(
        'call_file',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: basename(file.path),
      ));

      // Add other fields as needed
      request.fields['incoming_number'] = callNumber;

      // Send the request
      final response = await request.send();

      if (response.statusCode == 201) {
        print('Call recording uploaded successfully');
        return true;
      } else {
        logger.d(
            'Failed to upload call recording: ${await response.stream.bytesToString()}');
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }
}
