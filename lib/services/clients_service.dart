import 'dart:convert';

import 'package:http/http.dart' as http;

const String apiUrl =
    "https://7d12-2a02-2788-1b8-69f-acfb-61a6-6bf2-5e13.ngrok-free.app/api/clients/";

class ClientService {
  Future<List<dynamic>> getClientList() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> clientList = json.decode(response.body);
        return clientList;
      } else {
        throw Exception('Failed to load client list');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
