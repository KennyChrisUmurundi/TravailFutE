import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:travail_fute/providers/user_provider.dart';
import 'package:travail_fute/screens/login.dart';
import 'package:travail_fute/utils/func.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:travail_fute/utils/logger.dart';

const String apiUrlLogin = "https://tfte.azurewebsites.net/api/credentials/login/";

String globalDeviceToken = '';

class CredentialService {
  Future<http.Response> login(BuildContext context, String phone, String pin) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlLogin),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'phone_number': phone,
          'pin': pin,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        globalDeviceToken = responseBody["device_token"];
        Provider.of<TokenProvider>(context, listen: false).saveToken(globalDeviceToken);
        Provider.of<UserProvider>(context, listen: false).saveUser(responseBody["user"]);
      } else {
        return response;
      }

      return response;
    } on SocketException catch (e) {
      logger.i('Network error: $e');
      return http.Response('Network error: $e', 500);
    } on http.ClientException catch (e) {
      logger.i('Client error: $e');
      return http.Response('Client error: $e', 400);
    } catch (e) {
      logger.i('Unexpected error: $e');
      return http.Response('Unexpected error: $e', 500);
    }
  }

  Future<String> getOpenAiKey() async {
    final response = await http.get(
      Uri.parse('https://tfte.azurewebsites.net/api/credentials/ai/key'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody["key"];
    } else {
      throw Exception('Failed to load OpenAI key');
    }
  }
  Future<http.Response> register(BuildContext context, String username, String phoneNumber, String pin) async {
  try {
    final response = await http.post(
      Uri.parse('https://tfte.azurewebsites.net/api/credentials/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'phone_number': phoneNumber,
        'pin': pin,
        'pin2': pin,
      }),
    );
    return response;
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

Future<http.Response> changePin(BuildContext context, String current_pin, String pin) async {
  try {
    final response = await http.put(
      Uri.parse('https://tfte.azurewebsites.net/api/credentials/change_pin/'),
      headers: {'Content-Type': 'application/json','Authorization': 'Token ${Provider.of<TokenProvider>(context, listen: false).token}'},
      body: jsonEncode({
        'current_pin': current_pin,
        'new_pin': pin,
        'new_pin2': pin,

      }),
    );
    return response;
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

  Future<http.Response> resetPin(BuildContext context, String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('https://tfte.azurewebsites.net/api/credentials/reset-pin/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );
      checkInvalidTokenOrUser(context, response);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
}

Future <http.Response> getUserInfo(BuildContext context) async {
   try {
      final response = await http.get(
        Uri.parse('https://tfte.azurewebsites.net/api/credentials/user/'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Token ${Provider.of<TokenProvider>(context, listen: false).token}'},
      );
      checkInvalidTokenOrUser(context, response);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
}

Future<http.Response> updateUserInfo(BuildContext context, Map<String, dynamic> data) async {
    final cleanedData = Map<String, dynamic>.from(data)
        ..removeWhere((key, value) => value == null || value.toString().trim().isEmpty);

      // Convert Map to JSON string
      final jsonBody = json.encode(cleanedData);
    try{
      final response = await http.post(
        Uri.parse('https://tfte.azurewebsites.net/api/credentials/user/'),
        headers: {'Content-Type': 'application/json','Authorization':'Token ${Provider.of<TokenProvider>(context, listen: false).token}'},
        body:jsonBody,
      );
      logger.i("Response Headers: ${data}");
      checkInvalidTokenOrUser(context, response);
      return response;
    }
    catch (e) {
      throw Exception('Network error: $e');
    }
}

  Future<void> logout(BuildContext context) async {
    globalDeviceToken = '';
    await Provider.of<TokenProvider>(context, listen: false).clearToken();
    await Provider.of<UserProvider>(context, listen: false).clearUser();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}
