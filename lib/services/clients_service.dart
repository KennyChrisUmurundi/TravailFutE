import 'dart:convert';

import 'package:http/http.dart' as http;

class ClientService {
  final String apiUrl;

  ClientService(this.apiUrl);

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
