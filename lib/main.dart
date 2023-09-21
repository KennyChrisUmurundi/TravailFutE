import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/widgets/botom_nav.dart';
import 'package:travail_fute/widgets/foab.dart';
import 'screens/home_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
    return Scaffold(
      body: const HomePage(),
      appBar: AppBar(
        title: SizedBox(
            height: 30, child: Image.asset('assets/images/splash.png')),
        shadowColor: kWhiteColor,
        elevation: 0.3,
        backgroundColor: kWhiteColor,
      ),
      bottomNavigationBar: const BottomNavBar(),
      floatingActionButton: const MyCenteredFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
