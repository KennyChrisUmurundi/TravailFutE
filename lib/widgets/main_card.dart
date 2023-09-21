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
  });

  final String label;
  final String number;
  final IconData icon;
  final int value;
  final int completed;
  final void Function()? onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 162,
        height: 148,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: kCardColor,
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
                  color: kTravailFuteSecondaryColor,
                ),
                const CustomRoundButton(
                  buttonIcon: Icons.add,
                  backgroundColor: kTravailFuteMainColor,
                  iconColor: kWhiteColor,
                ),
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
            LinearProgressIndicator(
              value: value / completed,
              backgroundColor: kProgressBarInactiveColor,
              color: kTravailFuteMainColor,
            ),
            const SizedBox(
              height: 5,
            ),
            const Center(
              child: CustomRoundButton(
                buttonIcon: Icons.record_voice_over,
                backgroundColor: kCardColor,
                iconColor: kTravailFuteMainColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
