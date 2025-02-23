import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/client_detail.dart';
import 'package:travail_fute/services/clients_service.dart';
import 'package:travail_fute/services/notification_service.dart';
import 'package:travail_fute/utils/provider.dart';



class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List notifications = [];
  Set<String> deletingNotifications = {};
  Map<String, dynamic> client = {};
  final ClientService clientService = ClientService();
  bool isLoading = false; // Add loading state

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    
  }

  void fetchNotifications() async {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    final NotificationService notificationService = NotificationService(deviceToken: token);
    final response = await notificationService.fetchNotifications(context);
    setState(() {
      notifications = response['results'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: kWhiteColor)),
        backgroundColor: kTravailFuteMainColor,
      ),
      body: isLoading // Show loading indicator if loading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                    child: Text("Pas de Notifications"),
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    DateTime dueDate = DateTime.parse(notifications[index]['due_date']);
                    DateTime now = DateTime.now();
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isLoading = true; // Set loading state to true
                          });
                          clientService.getClientByPhone(context, notifications[index]['title']).then((result) {
                            client = result;
                            setState(() {
                              isLoading = false; // Set loading state to false
                            });
                          });
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => ClientDetail(client:client,phoneNumber: notifications[index]['title'],)),
                            );
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.notifications,
                            color: kTravailFuteMainColor,
                            size: 25,
                          ),
                          title: Text(
                            notifications[index]['title'].replaceFirst('+32', '0'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: notifications[index]['is_read'] ? Colors.grey : Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notifications[index]['message'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Heure: ${notifications[index]['due_time']}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Date: ${DateFormat('dd MMM').format(dueDate)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: kTravailFuteMainColor,
                                ),
                              ),
                            ],
                          ),
                          trailing: deletingNotifications.contains(notifications[index]['id'].toString())
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      deletingNotifications.add(notifications[index]['id'].toString());
                                    });
                                    final token = Provider.of<TokenProvider>(context, listen: false).token;
                                    final NotificationService notificationService = NotificationService(deviceToken: token);
                                    final response = await notificationService.deleteNotification(notifications[index]['id'].toString());
                                    if (response['success']) {
                                      setState(() {
                                        deletingNotifications.remove(notifications[index]['id'].toString());
                                        notifications.removeAt(index);
                                      });
                                    } else {
                                      setState(() {
                                        deletingNotifications.remove(notifications[index]['id'].toString());
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to delete notification')),
                                      );
                                    }
                                  },
                                ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}