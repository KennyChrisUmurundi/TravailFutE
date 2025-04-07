import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/providers/message_provider.dart';
import 'package:travail_fute/providers/user_provider.dart';
import 'package:travail_fute/screens/login.dart';
import 'package:travail_fute/screens/home_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travail_fute/services/notification_service.dart';
import 'package:travail_fute/widgets/dialog.dart';
import 'package:travail_fute/widgets/foab.dart';
import 'utils/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:travail_fute/utils/logger.dart';
import 'package:travail_fute/utils/noti.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final tokenProvider = TokenProvider();
  final userProvider = UserProvider();
  tz.initializeTimeZones();
  Noti().initNotification();
  await initializeDateFormatting('fr_FR', null); // Initialize French locale

  await tokenProvider.loadToken();
  await userProvider.loadUser();

  await requestPermissions(flutterLocalNotificationsPlugin); // Request permissions

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => tokenProvider),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
        ChangeNotifierProvider(create: (context) => userProvider),
      ],
      child: const MyApp(),
    ),
  );
}

const platform = MethodChannel('sms_channel');

Future<void> requestPermissions(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  final statuses = await [
    Permission.phone,
    Permission.sms,
    Permission.microphone,
    Permission.storage,
  ].request();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  statuses.forEach((permission, status) {
    if (status.isDenied) {
      logger.i('$permission is denied.');
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // No MethodChannel handler here; moved to RootScaffold
  }

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return const MaterialApp(
      title: 'TravailFuté',
      home: MainPageSettings(),
    );
  }
}

class MainPageSettings extends StatelessWidget {
  const MainPageSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: kTravailFuteMainColor,
        hintColor: kTravailFuteSecondaryColor,
        fontFamily: 'Poppins',
      ),
      home: const RootScaffold(),
    );
  }
}

class RootScaffold extends StatefulWidget {
  
  const RootScaffold({super.key});

  @override
  _RootScaffoldState createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
   bool isShared = false;
  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onSmsShared') {
        if(mounted){
          setState(() {
            isShared= true;
          });
        }
        final smsData = call.arguments as Map;
        final phoneNumber = smsData['phoneNumber'] as String;
        final messageBody = smsData['body'] as String;

        logger.i("phone is $phoneNumber and body is $messageBody");

        // Update MessageProvider with shared SMS
        // final messageProvider = Provider.of<MessageProvider>(context, listen: false);
        // messageProvider.setSharedSms(phoneNumber, messageBody);

        // Show reminder dialog
        var textEditingController = TextEditingController(text: "💥💥");
        DateTime selectedDateTime = DateTime.now().add(Duration(seconds: 10));
        final token = Provider.of<TokenProvider>(context, listen: false).token;
        final notificationService = NotificationService(deviceToken: token);
        final notification = Noti();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          showReminderDialog(
            context: context,
            textController: textEditingController,
            selectedDateTime: selectedDateTime,
            sender: phoneNumber,
            notificationService: notificationService,
            notification: notification,
          );
        });
        RecordFAB(onPressed: (String result) {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Consumer2<TokenProvider, UserProvider>(
        builder: (context, tokenProvider, userProvider, child) {
          if (tokenProvider.token.isEmpty || userProvider.user == null) {
            return const LoginScreen();
          }
          return HomePage(
            deviceToken: tokenProvider.token,
            user: userProvider.user!,
          );
        },
      ),
    );
  }
}