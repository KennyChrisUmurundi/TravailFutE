import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            color: kBackgroundColor.withOpacity(0.5),
          ),
        ),
        const Center(
          child: CircularProgressIndicator(backgroundColor: kTravailFuteMainColor,color: kProgressBarInactiveColor,),
        ),
      ],
    );
  }
}