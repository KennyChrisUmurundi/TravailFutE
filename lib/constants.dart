import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// Function to get responsive font size
double getResponsiveFontSize(BuildContext context, double fontSize) {
  return fontSize * MediaQuery.of(context).size.width / 375;
}

const kTravailFuteMainColor = Color(0xFFe29a32);
const kTravailFuteSecondaryColor = Color(0xFF1d1d1f);
const kProgressBarInactiveColor = Color(0xFFF2e2cd);

TextStyle kWelcomePageTextStyle(BuildContext context) {
  return TextStyle(
    fontFamily: 'Poppins',
    fontSize: getResponsiveFontSize(context, 30),
    fontWeight: FontWeight.w500,
    color: kTravailFuteSecondaryColor,
  );
}

TextStyle kTitlePageTextStyle(BuildContext context) {
  return TextStyle(
    fontFamily: 'Poppins',
    fontSize: getResponsiveFontSize(context, 20),
    fontWeight: FontWeight.w500,
    color: kTravailFuteSecondaryColor,
  );
}

TextStyle kCardSmallTextStyle(BuildContext context) {
  return TextStyle(
    fontFamily: 'Poppins',
    fontSize: getResponsiveFontSize(context, 10),
    fontWeight: FontWeight.w500,
    color: kTravailFuteSecondaryColor,
  );
}

TextStyle kCardBigTextStyle(BuildContext context) {
  return TextStyle(
    fontFamily: 'Poppins',
    fontSize: getResponsiveFontSize(context, 14), // Adjusted font size
    fontWeight: FontWeight.bold,
    color: kTravailFuteSecondaryColor,
  );
}

const kWhiteColor = Color(0xFFFFFFFF);

const kBackgroundColor = Color.fromARGB(255, 250, 248, 248);
