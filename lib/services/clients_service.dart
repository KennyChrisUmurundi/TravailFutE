import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:travail_fute/utils/func.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:travail_fute/utils/logger.dart';

const String apiUrl = "https://tfte.azurewebsites.net/api/clients/";

class ClientService {
  Future<List<dynamic>> getClientList(BuildContext context, {required String token}) async {
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    try {
      // Ensure HTTPS for all URLs
      final requestUrl = apiUrl.startsWith('http://') 
          ? apiUrl.replaceFirst('http://', 'https://') 
          : apiUrl;
      final response = await http.get(Uri.parse(requestUrl), headers: headers);
      checkInvalidTokenOrUser(context, response);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        logger.i("Response Data: $responseData");
        if (responseData["next"] != null) {
          final nextUrl = responseData["next"];
          final nextPath = nextUrl.startsWith('http://') 
          ? nextUrl.replaceFirst('http://', 'https://') 
          : nextUrl;
          final nextResponse = await http.get(Uri.parse(nextPath), headers: headers);
          final nextData = json.decode(nextResponse.body);
          responseData['results'].addAll(nextData['results']);
        }
        return responseData['results'];
      } else {
        throw Exception('Failed to load clients: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error in getClientList: $e');
    }
  }

  Future<String> createClient(BuildContext context, Map<String, dynamic> data) async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    // final bodyData = jsonEncode({
    //   "first_name": data["Nom"],
    //   "last_name": data["Prenom"],
    //   "email": data["email"],
    //   "address_street": data["Rue"],
    //   "address_town": data["Ville"],
    //   "postal_code": data["Code Postal"],
    //   "phone_number": data["phone_number"],
    // });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(data),
      );
      logger.i("Response Headers: ${response.body}");
      final responseData = json.decode(response.body);
      if (response.statusCode == 201) {
        return responseData['id'].toString();
      } else {
        checkInvalidTokenOrUser(context, response);
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
      } else {
        checkInvalidTokenOrUser(context, response); // Use the utility function
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
      logger.i("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        logger.i('Client updated successfully');
      } else {
        checkInvalidTokenOrUser(context, response); // Use the utility function
        throw Exception('Failed to update client: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
