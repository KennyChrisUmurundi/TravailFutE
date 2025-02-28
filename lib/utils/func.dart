import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travail_fute/screens/login.dart';

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