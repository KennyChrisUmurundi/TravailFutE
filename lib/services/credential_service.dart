import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/utils/provider.dart';

const String apiUrlLogin = "https://tfte.azurewebsites.net/api/credentials/login/";

String globalDeviceToken = '';

class CredentialService {
  Future<http.Response> login(BuildContext context, String phone, String pin) async {
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
      Provider.of<TokenProvider>(context, listen: false).setToken(globalDeviceToken);
    }

    return response;
  }
}
