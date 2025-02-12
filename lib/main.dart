import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/providers/message_provider.dart';
import 'package:travail_fute/screens/login.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/services.dart';
import 'utils/provider.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(
    MultiProvider(
      providers: [
      ChangeNotifierProvider(create: (_) => TokenProvider()),
      ChangeNotifierProvider(create: (context) => MessageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// TODO: I NEED TO GET THE DEVICE ID OR SERIAL NUMBER FIRST
// Future<String?> getAndroidDeviceId() async {
//   String? deviceId;
//   try {
//     deviceId =
//         await const MethodChannel('your_channel_name').invokeMethod('getDeviceId');
//   } on PlatformException catch (e) {
//     print('Error getting Android device ID: $e');
//   }
//   return deviceId;
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('sms_channel');
  final logger = Logger();

  Future<void> fetchSms() async {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);

    try {
      final List<dynamic> result = await platform.invokeMethod('getSms');

      // Convert to List<Map<String, dynamic>> safely
      final List<Map<String, dynamic>> messages = result.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();

      // Convert all values to strings
      final List<Map<String, String>> stringMessages = messages.map((message) {
        return message.map((key, value) => MapEntry(key, value.toString()));
      }).toList();

      messageProvider.setMessages(stringMessages);
    } on PlatformException catch (e) {
      messageProvider.setMessages([]);
      logger.e("Failed to get SMS: '${e.message}'.");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSms();
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
      body: LoginScreen(),
      // bottomNavigationBar: const BottomNavBar(),
      // floatingActionButton: const MyCenteredFAB(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// Navigator(
//         onGenerateRoute: (settings) {
//           return MaterialPageRoute(
//             builder: (context) {
//               return const HomePage();
//             },
//           );
//         },
//       ),