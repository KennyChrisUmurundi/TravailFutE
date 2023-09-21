import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/screens/home_page.dart';

class MainCard extends StatelessWidget {
  const MainCard({
    super.key,
    required this.label,
    required this.number,
    required this.icon,
    required this.value,
    required this.completed,
    this.onPress,
    this.addOption = true,
    this.cardColor = kCardColor,
    this.textColor = kTravailFuteSecondaryColor,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(10),
        // width: 162,
        height: 118,
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
                    ? const CustomRoundButton(
                        buttonIcon: Icons.add,
                        backgroundColor: kTravailFuteMainColor,
                        iconColor: kWhiteColor,
                      )
                    : Container(),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              number,
              style: kCardSmallTextStyle,
            ),
            Text(
              label,
              style: kCardBigTextStyle,
            ),
            const SizedBox(
              height: 5,
            ),
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
