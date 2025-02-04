import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/utils/provider.dart';

const String apiUrl =
    "https://tfte.azurewebsites.net/api/clients/";

class ClientService {
  Future<Map<String, dynamic>> getClientList(context, {String? url}) async { // Add optional url parameter
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    print("CLIEEETNNNNNNNNNNNNNNNTTTTT::::::::::$token");
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
      } else {
        throw Exception('Failed to load client list: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> createClient(String deviceToken, Map<String, dynamic> data) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $deviceToken',
    };

    final bodyData = jsonEncode({
      "first_name": data["Nom"],
      "last_name": data["Prenom"],
      "address": data["Addresse"],
      "phone_number": data["Telephone"],
    });

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: bodyData,
    );
    print("Response Headers: ${response.body}");
    final responseData = json.decode(response.body);
    if (response.statusCode == 201) {
      return responseData['id'].toString();
    } else {
      // Handle API error
     return responseData;
    }
  }
}
