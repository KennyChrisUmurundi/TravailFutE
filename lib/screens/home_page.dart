import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smswatcher/smswatcher.dart';
import 'package:travail_fute/constants.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
// import 'package:travail_fute/screens/client_create.dart';
import 'package:travail_fute/widgets/botom_nav.dart';
import 'package:travail_fute/widgets/foab.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:audioplayers/audioplayers.dart';

import '../widgets/main_card.dart';
import '../widgets/wide_button.dart';
// import 'package:record/record.dart';
import 'package:logger/logger.dart';
import 'clients.dart';
import 'package:travail_fute/services/phone_state_service.dart';
import 'messages_screen.dart';
import 'package:flutter_sms_manager/flutter_sms_manager.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user; // Add user parameter
  final String deviceToken; // Add device token parameter
  

  HomePage({super.key, required this.user, required this.deviceToken}); // Update constructor

  @override
  State<HomePage> createState() => _HomePageState();
}

    
void waitPermission() async {
  await Permission.sms.request();
  await Permission.phone.request();
}

class _HomePageState extends State<HomePage> {
  PhoneState status = PhoneState.nothing();
  late PhoneStateService phoneStateService;
  final _smsListenerPlugin = Smswatcher();
  Future<List<Map<String, String>>?>? sms;
  List<Map<String, dynamic>> _smsList = [];
  bool _isLoading = false;
  String _errorMessage = '';

  

  @override
  void initState() {
    waitPermission();
    sms = _smsListenerPlugin.getAllSMS();
    _smsListenerPlugin.getStreamOfSMS();
    Logger.level = Level.debug;
    phoneStateService = PhoneStateService(context); // Initialize phoneStateService
    super.initState();
    phoneStateService.startListening();
    _fetchSms();
  }

  Future<void> _fetchSms() async {
    print("Fetching SMS");
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {

      print("Fetching SMS2");
      final smsList = await SmsManager.fetchSms();
      print("lissssssssssssssssssssssssst $smsList");
      setState(() {
        _smsList = smsList;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        print(_errorMessage);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;
    phoneStateService = PhoneStateService(context);

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
                      onPress: () => _fetchSms(),
                      title: 'Overview',
                      buttonColor: kTravailFuteMainColor,
                      textColor: kWhiteColor,
                      borderColor: kTravailFuteMainColor,
                    ),
                    SizedBox(width: width * 0.03),
                    WideButton(
                      onPress: () => _fetchSms(),
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
                
                // SizedBox(
                //   height: 10,
                // ),
                // Expanded(
                //   child: Container(
                //     margin: EdgeInsets.all(8),
                //     decoration: BoxDecoration(
                //         color: kTravailFuteMainColor,
                //         borderRadius: BorderRadius.circular(15)),
                //   ),
                // ),
                // const Text(
                //   "Important",
                //   style: kTitlePageTextStyle,
                // ),
                // Container(
                //   // height: 50,
                //   // // width: 200,
                //   decoration: BoxDecoration(
                //       border: Border.all(
                //         width: 1,
                //         color: kCardColor,
                //       ),
                //       borderRadius: BorderRadius.circular(10)),
                //   child: Column(
                //     children: [
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           WideButton(
                //             onPress: stopRecord,
                //             title: 'Details',
                //             buttonColor: kTravailFuteMainColor,
                //             textColor: kWhiteColor,
                //             borderColor: kTravailFuteMainColor,
                //           ),
                //           const Row(
                //             children: [
                //               Text(
                //                 '3 Appels',
                //                 style: kCardBigTextStyle,
                //               ),
                //               SizedBox(
                //                 width: 3,
                //               ),
                //               Icon(
                //                 Icons.call,
                //                 size: 12,
                //               ),
                //             ],
                //           )
                //         ],
                //       )
                //     ],
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(onMenuPressed: () {  },),
      // floatingActionButton: MyCenteredFAB(),
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
    // this.onPress,
  });
  final IconData buttonIcon;
  final Color backgroundColor;
  final Color iconColor;
  // final void Function()? onPress;
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
