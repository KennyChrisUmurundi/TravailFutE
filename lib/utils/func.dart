import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travail_fute/screens/login.dart';
import 'package:travail_fute/utils/logger.dart';

void checkInvalidTokenOrUser(BuildContext context, http.Response response) {
  if (response.statusCode == 401 || response.statusCode == 403) {
    final responseData = json.decode(response.body);
    if (responseData['detail'] == "Invalid token or user not found.") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
}
String checkUtf8(String fullName) {
  logger.i('Original: $fullName');
  
  // UTF-8 bytes
  List<int> utf8Bytes = utf8.encode(fullName);
  logger.i('UTF-8 Bytes: $utf8Bytes');
  
  // Decode as UTF-8
  String utf8Decoded = utf8.decode(utf8Bytes);
  logger.i('UTF-8 Decoded: $utf8Decoded');
  
  // Simulate misdecoding as ISO-8859-1 (Latin-1)
  String latin1Decoded = latin1.decode(utf8Bytes);
  logger.i('Latin-1 Decoded: $latin1Decoded');
  logger.i('Original: $utf8Decoded');
  logger.i('Decoded: $latin1Decoded');
  logger.i('Bytes: $utf8Bytes');
  // Check if the original matches the decoded version
  return utf8Decoded;
  
}