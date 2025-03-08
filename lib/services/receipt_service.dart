import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/utils/func.dart';
import 'package:travail_fute/utils/provider.dart';


class ReceiptService {
  Future<List<dynamic>> fetchReceipts(BuildContext context) async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
      final response = await http.get(
        Uri.parse("$apiUrl/bill/manage/"),
        headers: {'Authorization': 'Token $token'},
      );
    print("the response is ${response.body}");
    checkInvalidTokenOrUser(context, response);
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedResponse = json.decode(response.body);
      return decodedResponse['results'];
    } else {
      throw Exception('Failed to load receipts');
    }
  }
  Future<http.Response> fetchReceiptPdf(BuildContext context, String pk) async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    final response = await http.get(
      Uri.parse("$apiUrl/bill/$pk/pdf/"),
      headers: {'Authorization': 'Token $token'},
    );
    checkInvalidTokenOrUser(context, response);
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load receipt PDF');
    }
  }
}
