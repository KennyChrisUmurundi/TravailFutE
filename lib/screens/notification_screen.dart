import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/services/notification_service.dart';
import 'dart:convert';
import 'package:travail_fute/utils/provider.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  void fetchNotifications() async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    final NotificationService notificationService = NotificationService(deviceToken: token);
    final response = await notificationService.fetchNotifications();
    setState(() {
      notifications = response['results'];
    });
  }

  void showNotificationMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification',style:TextStyle(fontSize: 12)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications',style:TextStyle(fontSize: 14) ,),
        
      ),
      body: notifications.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                  
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: kTravailFuteMainColor,
                      size: 40,
                    ),
                    title: Text(
                      notifications[index]['title'],
                        style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: notifications[index]['is_read'] ? Colors.grey : Colors.black,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: kTravailFuteMainColor,
                    ),
                    onTap: () {
                      showNotificationMessage(context, notifications[index]['message']);
                    },
                  ),
                );
              },
            ),
    );
  }
}