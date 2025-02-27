import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/providers/message_provider.dart';
import 'package:travail_fute/providers/user_provider.dart';
import 'package:travail_fute/screens/login.dart';
import 'package:travail_fute/screens/home_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'utils/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
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
Future<void> requestPermissions(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  final statuses = await [
    Permission.phone,
    Permission.sms,
    Permission.microphone,
    Permission.storage,
  ].request();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  
  statuses.forEach((permission, status) {
    if (status.isDenied) {
      // Handle the case when the permission is denied
      print('$permission is denied.');
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
    // fetchSms();
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
        // Define your theme here
        primaryColor: kTravailFuteMainColor,
        hintColor: kTravailFuteSecondaryColor,
        fontFamily: 'Poppins',
      ),
      home: const RootScaffold(),
    );
  }
}

class RootScaffold extends StatelessWidget {
  const RootScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: SizedBox(
          height: 30,
          child: Image.asset('assets/images/splash.png'),
        ),
        shadowColor: Colors.white,
        elevation: 0.3,
        backgroundColor: Colors.white,
      ),
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