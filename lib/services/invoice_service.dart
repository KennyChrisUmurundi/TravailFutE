import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:travail_fute/utils/func.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:travail_fute/utils/logger.dart';

const String apiUrl = "https://tfte.azurewebsites.net/api/invoice/estimates/";

class InvoiceService {
  Future<List<dynamic>> getInvoiceList(BuildContext context) async {
    final String token = Provider.of<TokenProvider>(context, listen: false).token;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
};

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      final responseData = json.decode(response.body);
      logger.i("Response Data: $responseData");
      checkInvalidTokenOrUser(context, response);
      // if (response.statusCode == 200) {
      //   final responseData = json.decode(response.body);
      //   logger.i("Response Data: $responseData");
      //   if (responseData["next"] != null) {
      //     final nextUrl = responseData["next"] as String;
      //     final nextPath = nextUrl.startsWith('http://') 
      //     ? nextUrl.replaceFirst('http://', 'https://') 
      //     : nextUrl;
      //     final nextResponse = await http.get(Uri.parse(nextPath), headers: headers);
      //     final nextData = json.decode(nextResponse.body);
      //     responseData['results'].addAll(nextData['results']);
      //   }
        return responseData;
      // } else {
      //   throw Exception('Failed to load invoices: ${response.reasonPhrase}');
      // }
    } catch (e) {
      throw Exception('Error in getInvoiceList: $e');
    }
  }

  Future<List<dynamic>> fetchEstimatesByClient(BuildContext context, {required String id})async{
    final String token = Provider.of<TokenProvider>(context, listen: false).token;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
  };
     try {
      final response = await http.get(Uri.parse('$apiUrl/by-client/$id'), headers: headers);
      checkInvalidTokenOrUser(context, response);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        logger.i("Response Data: $responseData");
        // if (responseData["next"] != null) {
        //   final nextUrl = responseData["next"];
        //   final nextPath = nextUrl.startsWith('http://') 
        //   ? nextUrl.replaceFirst('http://', 'https://') 
        //   : nextUrl;
        //   final nextResponse = await http.get(Uri.parse(nextPath), headers: headers);
        //   final nextData = json.decode(nextResponse.body);
        //   responseData['results'].addAll(nextData['results']);
        // }
        return responseData;
      } else {
        throw Exception('Failed to load invoices: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error in getInvoiceList: $e');
    }
}
}