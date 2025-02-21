import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart'; // Import the constants file

// ignore: must_be_immutable
class WideButton extends StatefulWidget {
  WideButton({
    super.key,
    required this.title,
    required this.buttonColor,
    required this.textColor,
    required this.borderColor,
    this.onPress,
  });

  final String title;
  final Color buttonColor;
  final Color textColor;
  final Color borderColor;
  final void Function()? onPress;

  bool isPressed = false;

  @override
  State<WideButton> createState() => _WideButtonState();
}

class _WideButtonState extends State<WideButton> {
  Future<void> resetShaddow() async {
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        widget.isPressed = false; // Reset the tapped state
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPress;
        setState(() {
          widget.isPressed = true;
          resetShaddow();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width * 0.3, // Responsive width
        height: MediaQuery.of(context).size.height * 0.04, // Responsive height
        decoration: BoxDecoration(
          color: widget.buttonColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.borderColor,
            width: 1.0,
          ),
          boxShadow: widget.isPressed
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Set shadow color
                    spreadRadius: 2, // Set the spread radius
                    blurRadius: 5, // Set the blur radius
                    offset: const Offset(0, 3), // Set the shadow offset
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            widget.title,
            style: TextStyle(
              color: widget.textColor,
              fontSize: getResponsiveFontSize(context, 10), // Responsive font size
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
