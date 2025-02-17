import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

const String apiUrl = "https://tfte.azurewebsites.net/api/";

class NotificationService {
  final String deviceToken;
  final Logger logger = Logger();
  List notifications = [];

  NotificationService({ required this.deviceToken});

  Future<void> sendNotification(String title, String message, {String? dueDate, String? dueTime}) async {
    final url = Uri.parse('$apiUrl/notification/');
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

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      logger.i('Notification sent successfully');
    } else {
      logger.i('Failed to send notification: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchNotifications() async {
    final url = Uri.parse('$apiUrl/notification');
    final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Token $deviceToken',
      };
    final response = await http.get(url, headers: headers);
    print("Response: ${response.body}");
      if (response.statusCode == 200) {
          final decodedResponse = json.decode(response.body);
          return decodedResponse;
      } else {
          throw Exception('Failed to load notifications');
        }
      }
    }
