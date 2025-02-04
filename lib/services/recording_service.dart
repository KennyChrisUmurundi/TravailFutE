import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/utils/provider.dart';

const String apiUrl =
    "https://tfte.azurewebsites.net/api/voice_processor/call_record/";

class RecordingService {
  String callNumber;
  final String callPath;
  BuildContext context;
  final logger = Logger();
  RecordingService(
    BuildContext context,
    this.callNumber,
      this.callPath,
    ) : context = context;
    
  

  Future<bool> uploadRecording() async {
    final file = File(callPath);
    final deviceToken = Provider.of<TokenProvider>(context, listen: false).token;
    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add the 'call_file' file part
      request.files.add(http.MultipartFile(
        'call_file',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: basename(file.path),
      ));
      

      // Set default number if callNumber is null or empty
      if (callNumber.isEmpty) {
        logger.d('Call number is null or empty, setting default number');
        callNumber = '+32471972986';
      }
      request.fields['incoming_number'] = callNumber;

      // Add headers
      request.headers['Authorization'] = 'Token $deviceToken';

      print("the request: $request");

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
