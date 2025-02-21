import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:travail_fute/screens/login.dart';

const String apiUrl = "https://tfte.azurewebsites.net/api/clients/";

class ClientService {
  Future<Map<String, dynamic>> getClientList(BuildContext context, {String? url}) async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    try {
      print("THE HEADERS $headers");
      final response = await http.get(
        Uri.parse(url ?? apiUrl), // Use the provided URL or the default API URL
        headers: headers,
      );
      print("Response Headers: ${response.headers}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        final responseData = json.decode(response.body);
        if (responseData['detail'] == 'Invalid token or user not found.') {
          _redirectToLogin(context);
        }
        throw Exception('Failed to load client list: ${response.body}');
      } else {
        throw Exception('Failed to load client list: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> createClient(BuildContext context, Map<String, dynamic> data) async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    final bodyData = jsonEncode({
      "first_name": data["Nom"],
      "last_name": data["Prenom"],
      "address": data["Addresse"],
      "phone_number": data["Telephone"],
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: bodyData,
      );
      print("Response Headers: ${response.body}");
      final responseData = json.decode(response.body);
      if (response.statusCode == 201) {
        return responseData['id'].toString();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (responseData['detail'] == 'Invalid token or user not found.') {
          _redirectToLogin(context);
        }
        throw Exception('Failed to create client: ${response.body}');
      } else {
        throw Exception('Failed to create client: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getClientByPhone(BuildContext context, String phoneNumber) async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final url = "$apiUrl/phone/?phone_number=$phoneNumber";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else if (response.statusCode == 401 || response.statusCode == 403 || response.statusCode == 500) {
        final responseData = json.decode(response.body);
        if (responseData['detail'] == 'Invalid token or user not found.') {
          _redirectToLogin(context);
        }
        throw Exception('Failed to load client: ${response.body}');
      } else {
        throw Exception('Failed to load client: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> updateClient(BuildContext context, String clientId, Map<String, dynamic> data) async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    final bodyData = jsonEncode(data);

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/manage/$clientId/'),
        headers: headers,
        body: bodyData,
      );
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print('Client updated successfully');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        final responseData = json.decode(response.body);
        if (responseData['detail'] == 'Invalid token or user not found.') {
          _redirectToLogin(context);
        }
        throw Exception('Failed to update client: ${response.body}');
      } else {
        throw Exception('Failed to update client: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void _redirectToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
