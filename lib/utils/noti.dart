import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Noti {
  final FlutterLocalNotificationsPlugin notification = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  Logger logger = Logger();

  bool get isInitialized => _isInitialized;
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'channel id', // id
  'channel name', // name
  description: 'channel description', // description
  importance: Importance.max,
);

  // Initialize the notifications and timezone data
  Future<void> initNotification() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: initializationSettingsAndroid);
    await notification.initialize(initSettings);

    await notification.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
    _isInitialized = true;
  }

  // Notification details for Android
  NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'channel id',
      'channel name',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  // Show notification immediately
  Future<void> showNotification(String title, String body) async {
    await notification.show(0, title, body, notificationDetails);
  }

  // Schedule a notification for a specific date and time
  Future scheduleNotification(DateTime scheduledDateTime, String title, String body) async {
    if (await Permission.scheduleExactAlarm.request().isGranted) {
      logger.i('before the time is $scheduledDateTime');
      final tzDateTime = tz.TZDateTime.local(
        scheduledDateTime.year,
        scheduledDateTime.month,
        scheduledDateTime.day,
        scheduledDateTime.hour,
        scheduledDateTime.minute,
        scheduledDateTime.second,
      );

      // Schedule the notification
      logger.i("After conversion, tzDateTime (local): $tzDateTime");
      final now = tz.TZDateTime.now(tz.local);
      logger.i("Current time: $now");
      if (tzDateTime.isBefore(now)) {
        logger.i("Scheduled time $tzDateTime is before current time $now. Notification will not be scheduled.");
        return;
      }
      try {
      notification.zonedSchedule(
        0,
        title,
        body,
        // substractin one hour since its giving me utc errors
        tzDateTime.subtract(Duration(hours: 1)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
      } catch (e) {
        logger.i("Error scheduling notification: $e");
      }
    }}
    
    
  
}
