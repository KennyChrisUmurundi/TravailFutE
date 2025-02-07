import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:travail_fute/utils/provider.dart';

const String apiUrlLogin = "https://tfte.azurewebsites.net/api/credentials/login/";

String globalDeviceToken = '';

class CredentialService {
  static const platform = MethodChannel('phone_channel');

  Future<String?> _getPhoneNumber() async {
    try {
      final String? phoneNumber = await platform.invokeMethod('getPhoneNumber');
      return phoneNumber;
    } on PlatformException catch (e) {
      print("Failed to get phone number: '${e.message}'.");
      return null;
    }
  }

  Future<http.Response> login(BuildContext context, String pin) async {
    final phone = await _getPhoneNumber();
    final permissionStatus = await platform.invokeMethod('checkPhoneStatePermission');
    if (permissionStatus != 'granted') {
      throw Exception('Phone state permission not granted');
    }
    print("The Phone number is: $phone");
    if (phone == null) {
      throw Exception('Unable to retrieve phone number');
    }

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
