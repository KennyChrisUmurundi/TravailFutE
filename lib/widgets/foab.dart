import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';

class MyCenteredFAB extends StatelessWidget {
  const MyCenteredFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: kTravailFuteMainColor,
      onPressed: () {
        // Record voice like a Siri stuff
      },
      child: const Icon(Icons.mic_none),
    );
  }
}
