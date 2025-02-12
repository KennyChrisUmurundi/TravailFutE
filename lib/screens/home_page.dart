import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:phone_state/phone_state.dart';
import 'package:travail_fute/widgets/botom_nav.dart';
import 'package:travail_fute/widgets/foab.dart';
import 'package:logger/logger.dart';
import 'clients.dart';
import 'package:travail_fute/services/phone_state_service.dart';
import 'messages_screen.dart';
import '../widgets/main_card.dart';
import '../widgets/wide_button.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user; // Add user parameter
  final String deviceToken; // Add device token parameter

  HomePage({super.key, required this.user, required this.deviceToken}); // Update constructor

  @override
  State<HomePage> createState() => _HomePageState();
}

// void waitPermission() async {
//   await Permission.sms.request();
//   await Permission.phone.request();
// }

class _HomePageState extends State<HomePage> {
  PhoneState status = PhoneState.nothing();
  late PhoneStateService phoneStateService;
  Future<List<Map<String, String>>?>? sms;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // waitPermission();
    Logger.level = Level.debug;
    phoneStateService = PhoneStateService(context); // Initialize phoneStateService
    phoneStateService.startListening();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: SizedBox(
          height: height * 0.05,
          child: Image.asset('assets/images/splash.png'),
        ),
        shadowColor: Colors.white,
        elevation: 0.3,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(width * 0.04, 0, width * 0.04, width * 0.04),
            margin: EdgeInsets.symmetric(horizontal: width * 0.04),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${widget.user['username']}!', // Display user's name
                  style: kWelcomePageTextStyle(context),
                ),
                SizedBox(height: height * 0.02),
                Row(
                  children: [
                    WideButton(
                      onPress: () => {},
                      title: 'Overview',
                      buttonColor: kTravailFuteMainColor,
                      textColor: kWhiteColor,
                      borderColor: kTravailFuteMainColor,
                    ),
                    SizedBox(width: width * 0.03),
                    WideButton(
                      onPress: () => () => {},
                      title: 'Chantiers',
                      buttonColor: kWhiteColor,
                      textColor: kTravailFuteSecondaryColor,
                      borderColor: kTravailFuteSecondaryColor,
                    ),
                  ],
                ),
                SizedBox(height: height * 0.03),
                Row(
                  children: [
                    const Expanded(
                      child: MainCard(
                        // onPress: playRecord,
                        label: 'Chantiers',
                        icon: Icons.construction,
                        value: 1,
                        completed: 5,
                      ),
                    ),
                    SizedBox(width: width * 0.015),
                    Expanded(
                      child: MainCard(
                          onPress: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClientsList(deviceToken: widget.deviceToken), // Pass device token
                              ),
                            );
                          },
                          label: 'Clients',
                          icon: Icons.people,
                          value: 89,
                          completed: 89),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.01),
                Row(
                  children: [
                    Expanded(
                      child: MainCard(
                        label: 'Messages',
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessagesScreen(),
                            ),
                          );
                        },
                        icon: Icons.euro,
                        value: 1,
                        completed: 5,
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: MainCard(
                          label: 'Tâches',
                          icon: Icons.task,
                          value: 89,
                          completed: 89),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.01),
                const Row(
                  children: [
                    Expanded(
                      child: MainCard(
                        label: 'Factures',
                        icon: Icons.receipt,
                        value: 1,
                        completed: 5,
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: MainCard(
                          label: 'Notifications',
                          cardColor: kTravailFuteMainColor,
                          addOption: false,
                          icon: Icons.notifications,
                          value: 89,
                          textColor: kWhiteColor,
                          completed: 89),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
      floatingActionButton: RecordFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class CustomRoundButton extends StatelessWidget {
  const CustomRoundButton({
    super.key,
    required this.buttonIcon,
    required this.backgroundColor,
    required this.iconColor,
  });
  final IconData buttonIcon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 33,
      width: 33,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor,
        border: Border.all(
          color: iconColor,
          width: 1.0,
        ),
      ),
      child: Center(
        child: IconButton(
          onPressed: () {},
          icon: Icon(
            buttonIcon,
            color: iconColor,
            size: 18,
          ),
        ),
      ),
    );
  }
}
