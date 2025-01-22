import 'dart:convert';

import 'package:http/http.dart' as http;

const String apiUrl =
    "https://tfte.azurewebsites.net/api/clients/";

class ClientService {
  Future<Map<String, dynamic>> getClientList(String deviceToken, {String? url}) async { // Add optional url parameter
    final headers = {
      'Authorization': 'Token $deviceToken',
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
}
