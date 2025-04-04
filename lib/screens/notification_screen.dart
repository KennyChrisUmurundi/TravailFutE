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

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  List notifications = [];
  Set<String> deletingNotifications = {};
  Map<String, dynamic> client = {};
  final ClientService clientService = ClientService();
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    fetchNotifications();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void fetchNotifications() async {
    setState(() => isLoading = true);
    final token = Provider.of<TokenProvider>(context, listen: false).token;
    final NotificationService notificationService = NotificationService(deviceToken: token);
    try {
      final response = await notificationService.fetchNotifications(context);
      setState(() {
        notifications = response['results'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notifications: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kTravailFuteMainColor.withOpacity(0.15), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(size, width),
                  Expanded(child: _buildNotificationList(size, width)),
                ],
              ),
              if (isLoading) _buildLoadingOverlay(width),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kTravailFuteMainColor, kTravailFuteSecondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(width * 0.02),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kWhiteColor.withOpacity(0.2),
              ),
              child: Icon(Icons.arrow_back, color: kWhiteColor, size: width * 0.06),
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: FadeTransition(
              opacity: _animation,
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: kWhiteColor,
                  fontFamily: 'NotoSans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(Size size, double width) {
    return notifications.isEmpty
        ? _buildEmptyState(size, width)
        : ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              DateTime dueDate = DateTime.parse(notifications[index]['due_date']);
              return FadeTransition(
                opacity: _animation,
                child: _buildNotificationCard(size, width, index, dueDate),
              );
            },
          );
  }

  Widget _buildNotificationCard(Size size, double width, int index, DateTime dueDate) {
    return GestureDetector(
      onTap: () async {
        setState(() => isLoading = true);
        try {
          final result = await clientService.getClientByPhone(context, notifications[index]['title']);
          setState(() {
            client = result;
            isLoading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClientDetail(client: client, phoneNumber: notifications[index]['title']),
            ),
          );
        } catch (e) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load client: $e')),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: width * 0.015, horizontal: width * 0.04),
        padding: EdgeInsets.all(width * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: kTravailFuteMainColor.withOpacity(0.1),
              radius: width * 0.06,
              child: Icon(
                Icons.notifications,
                color: kTravailFuteMainColor,
                size: width * 0.06,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notifications[index]['title'].replaceFirst('+32', '0'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.045,
                      color: notifications[index]['is_read'] ? Colors.grey : Colors.black87,
                    ),
                  ),
                  SizedBox(height: width * 0.01),
                  Text(
                    notifications[index]['message'],
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: Colors.grey[600],
                      fontFamily: 'Roboto',
                    ),
                    locale: const Locale('fr', 'FR'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: width * 0.01),
                  Row(
                    children: [
                      Text(
                        'Heure: ${notifications[index]['due_time']}',
                        style: TextStyle(
                          fontSize: width * 0.03,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Text(
                        'Date: ${DateFormat('dd MMM').format(dueDate)}',
                        style: TextStyle(
                          fontSize: width * 0.03,
                          color: kTravailFuteMainColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: width * 0.02),
            deletingNotifications.contains(notifications[index]['id'].toString())
                ? SizedBox(
                    width: width * 0.05,
                    height: width * 0.05,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(kTravailFuteMainColor),
                    ),
                  )
                : GestureDetector(
                    onTap: () async {
                      setState(() => deletingNotifications.add(notifications[index]['id'].toString()));
                      final token = Provider.of<TokenProvider>(context, listen: false).token;
                      final notificationService = NotificationService(deviceToken: token);
                      try {
                        final response = await notificationService.deleteNotification(notifications[index]['id'].toString());
                        if (response['success']) {
                          setState(() {
                            deletingNotifications.remove(notifications[index]['id'].toString());
                            notifications.removeAt(index);
                          });
                        } else {
                          throw Exception('Failed to delete');
                        }
                      } catch (e) {
                        setState(() => deletingNotifications.remove(notifications[index]['id'].toString()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete notification: $e')),
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(width * 0.015),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: width * 0.05,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size size, double width) {
    return Center(
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          padding: EdgeInsets.all(width * 0.06),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_off,
                size: width * 0.15,
                color: Colors.grey[400],
              ),
              SizedBox(height: width * 0.04),
              Text(
                'Pas de notifications',
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: width * 0.02),
              Text(
                'Vous êtes à jour !',
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(double width) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kTravailFuteMainColor),
          ),
        ),
      ),
    );
  }
}