import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyCenteredFAB extends StatefulWidget {
  const MyCenteredFAB({super.key});

  @override
  State<MyCenteredFAB> createState() => _MyCenteredFABState();
}

class _MyCenteredFABState extends State<MyCenteredFAB> {
  bool _isRecording = false;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: kTravailFuteMainColor,
      onPressed: () {
        setState(() {
          _isRecording = !_isRecording;
          if (_isRecording) {
            // Record voice like a Siri stuff
          } else {}
        });
        //
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isRecording
            ? const SpinKitWave(
                color: Colors.white,
                size: 20.0,
              )
            : const Icon(Icons.mic_none,
                key:
                    ValueKey<int>(1)), // Use a unique key to trigger the switch
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
      ),
    );
    // );
  }
}
