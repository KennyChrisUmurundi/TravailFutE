import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/home_page.dart';
import 'package:travail_fute/screens/home_page.dart';

class MainCard extends StatelessWidget {
  const MainCard({
    super.key,
    required this.label,
    this.number='',
    required this.icon,
    required this.value,
    required this.completed,
    this.onPress,
    this.addOption = false,
    this.cardColor = kWhiteColor,
    this.textColor = kTravailFuteSecondaryColor,
    this.onAddPress,
  });

  final String label;
  final String number;
  final IconData icon;
  final int value;
  final int completed;
  final void Function()? onPress;
  final bool addOption;
  final Color cardColor;
  final Color textColor;
  final void Function()? onAddPress;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height; // Get screen height

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(10),
        height: height * 0.16, // Set height based on screen height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: cardColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: textColor,
                ),
                addOption
                    ? GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onAddPress,
                        child: IconButton(
                          icon: Icon(Icons.add, color: kWhiteColor),
                          onPressed: onAddPress,
                          color: kTravailFuteMainColor,
                        ),
                      )
                    : Container(),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              number,
              style: kCardSmallTextStyle(context),
            ),
            Text(
              label,
              style: kCardBigTextStyle(context),
            ),
            // const SizedBox(
            //   height: 5,
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     SizedBox(
            //       width: 80,
            //       child: LinearProgressIndicator(
            //         borderRadius: BorderRadius.circular(10),
            //         value: value / completed,
            //         backgroundColor: kProgressBarInactiveColor,
            //         color: kTravailFuteMainColor,
            //       ),
            //     ),
            //     Container(
            //       decoration: BoxDecoration(
            //           color: kTravailFuteMainColor,
            //           borderRadius: BorderRadius.circular(10)),
            //       child: const Padding(
            //         padding: EdgeInsets.all(4.0),
            //         child: Text(
            //           '5/7',
            //           style: TextStyle(
            //             color: kWhiteColor,
            //             fontFamily: 'Poppins',
            //             fontWeight: FontWeight.bold,
            //             fontSize: 12,
            //           ),
            //         ),
            //       ),
            //     )
            //   ],
            // ),
            // const SizedBox(
            //   width: 5,
            // ),
            // const SizedBox(
            //   height: 5,
            // ),
            // // const Center(
            // //   child: CustomRoundButton(
            // //     buttonIcon: Icons.record_voice_over,
            // //     backgroundColor: kCardColor,
            // //     iconColor: kTravailFuteMainColor,
            // //   ),
            // // )
          ],
        ),
      ),
    );
  }
}
