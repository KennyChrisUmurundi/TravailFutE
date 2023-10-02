import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:travail_fute/utils/audio_player.dart';
import 'package:travail_fute/utils/phone_state.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:audioplayers/audioplayers.dart';

import '../widgets/main_card.dart';
import '../widgets/wide_button.dart';
// import 'package:record/record.dart';
import 'package:logger/logger.dart';
import 'package:travail_fute/utils/record.dart';
import 'clients.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PhoneState status = PhoneState.nothing();
  final logger = Logger();
  final record = Recording();
  final player = AudioPlayerManager();
  // ignore: non_constant_identifier_names
  // late final String audioPath;

  void handlePhoneState(PhoneState event) async {
    setState(() {
      // ignore: unnecessary_null_comparison
      if (event != null) {
        logger.d("CALL EVENT RECEIVED");
        status = event;
        if (status.status == PhoneStateStatus.CALL_INCOMING ||
            status.status == PhoneStateStatus.CALL_STARTED) {
          final number = status.number;
          logger.d("CALL FROM: $number");
          // This is where i record the call
          if (status.status == PhoneStateStatus.CALL_STARTED) {
            record.startRecording();
            // record.checkRecordingStatus();
          }
        }
      }
    });
    if (status.status == PhoneStateStatus.CALL_ENDED) {
      bool isRecording = await record.checkRecordingStatus();
      if (isRecording) {
        record.stopRecording();
      }
    }
  }

  @override
  void initState() {
    Logger.level = Level.debug;

    super.initState();
    setStream(handlePhoneState);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bonjour, Chris!',
              style: kWelcomePageTextStyle,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                WideButton(
                  // onPress: record.stopRecord,
                  title: 'Overview',
                  buttonColor: kTravailFuteMainColor,
                  textColor: kWhiteColor,
                  borderColor: kTravailFuteMainColor,
                ),
                const SizedBox(
                  width: 10,
                ),
                WideButton(
                  // onPress: playRecord,
                  title: 'Chantiers',
                  buttonColor: kWhiteColor,
                  textColor: kTravailFuteSecondaryColor,
                  borderColor: kTravailFuteSecondaryColor,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: MainCard(
                    // onPress: playRecord,
                    label: 'Chantiers',
                    number: '5 Nouveaux',
                    icon: Icons.construction,
                    value: 1,
                    completed: 5,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: MainCard(
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ClientsList()),
                        );
                      },
                      label: 'Clients',
                      number: '15',
                      icon: Icons.people,
                      value: 89,
                      completed: 89),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            const Row(
              children: [
                Expanded(
                  child: MainCard(
                    label: 'Devis',
                    number: '5 Nouveaux',
                    icon: Icons.euro,
                    value: 1,
                    completed: 5,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: MainCard(
                      label: 'Taches',
                      number: '15',
                      icon: Icons.task,
                      value: 89,
                      completed: 89),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            const Row(
              children: [
                Expanded(
                  child: MainCard(
                    label: 'Factures',
                    number: '5 Nouveaux',
                    icon: Icons.payment,
                    value: 1,
                    completed: 5,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: MainCard(
                      label: 'Notifications',
                      number: '15',
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
