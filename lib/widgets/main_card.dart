import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';

class MainCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final int completed;
  final VoidCallback onPress;
  final bool addOption;
  final VoidCallback? onAddPress;
  final Color? cardColor;
  final Color? textColor;
  final bool isLoading;

  const MainCard(Size size, {
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.completed,
    required this.onPress,
    this.addOption = false,
    this.onAddPress,
    this.cardColor,
    this.textColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return isLoading 
      ? Expanded(
        child: Container(
        padding: EdgeInsets.all(size.width * 0.07),
        decoration: BoxDecoration(
          color: cardColor ?? Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
          ],
        ),
        child: Center(
          child: CircularProgressIndicator(
          color: textColor ?? kTravailFuteMainColor,
          ),
        ),
        ),
      )
      : Expanded(
        child: GestureDetector(
        onTap: onPress,
        child: ScaleTransition(
          scale: AlwaysStoppedAnimation(1.0),
          child: Container(
          padding: EdgeInsets.all(size.width * 0.07),
          decoration: BoxDecoration(
            color: cardColor ?? Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Icon(icon, color: textColor ?? kTravailFuteMainColor, size: size.width * 0.07),
              if (addOption)
                GestureDetector(
                onTap: onAddPress,
                child: Icon(Icons.add_circle_outline, color: kTravailFuteSecondaryColor),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              label,
              style: TextStyle(
              color: textColor ?? Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.04,
              ),
            ),
            // Uncomment if needed
            // Text(
            //   '$value/$completed',
            //   style: TextStyle(
            //     color: textColor?.withOpacity(0.7) ?? Colors.grey[600],
            //     fontSize: size.width * 0.035,
            //   ),
            // ),
            ],
          ),
          ),
        ),
        ),
      );
  }
}