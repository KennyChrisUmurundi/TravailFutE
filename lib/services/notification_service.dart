import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:travail_fute/screens/login.dart';

const String apiUrl = "https://tfte.azurewebsites.net/api/";

class NotificationService {
  final String deviceToken;
  final Logger logger = Logger();
  List notifications = [];

  NotificationService({ required this.deviceToken});

  Future<void> sendNotification(String title, String message, {String? dueDate, String? dueTime}) async {
    final url = Uri.parse('$apiUrl/notification/manage/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $deviceToken',
    };
    final body = jsonEncode({
      'title': title,
      'message': message,
      'due_date': dueDate,
      'due_time': dueTime,
    });
    logger.i("the body is $body");
    final response = await http.post(url, headers: headers, body: body);
    logger.i("Notification response: ${response.body}");

    if (response.statusCode == 201) {
      logger.i('Notification sent successfully');
    } else {
      logger.i('Failed to send notification: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchNotifications(BuildContext context) async {
  final url = Uri.parse('$apiUrl/notification/manage/');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Token $deviceToken',
  };

  final response = await http.get(url, headers: headers);
  logger.i("Response: ${response.statusCode} - ${response.body}");

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } 

  if (response.statusCode == 403) {
    try {
      final decodedResponse = json.decode(response.body);
      if (decodedResponse["detail"] == 'Invalid token or user not found.') {
        logger.e("Invalid token. Redirecting to login.");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        throw Exception('Invalid token. Redirecting to login.');
      }
    } catch (e) {
      logger.e("Failed to parse error response: $e");
    }
  }

  throw Exception('Failed to load notifications: ${response.body}');
}


      

  Future<Map<String, dynamic>> deleteNotification(String id) async {
    final url = Uri.parse('$apiUrl/notification/manage/$id/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $deviceToken',
    };
    final response = await http.delete(url, headers: headers);
    logger.i("Delete notification response: ${response.body}");

    if (response.statusCode == 204) {
      logger.i('Notification deleted successfully');
      return {'success': true};
    } else {
      logger.i('Failed to delete notification: ${response.statusCode}');
      return {'success': false};
    }
  }
  void _redirectToLogin(BuildContext context) {
  if (!context.mounted) return; // Prevent navigation if the context is not active

  Future.microtask(() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  });
}

}
