import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:travail_fute/utils/record.dart';

class RecordFAB extends StatefulWidget {

  const RecordFAB({context,super.key});
  

  @override
  State<RecordFAB> createState() => _RecordFABState();
}

class _RecordFABState extends State<RecordFAB> {
  bool _isRecording = false;
  late final record;

  @override
  void initState() {
    super.initState();
    record = Recording(context);
  }
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: kTravailFuteMainColor,
      onPressed: () {
        setState(() {
          _isRecording = !_isRecording;
          if (_isRecording) {
            record.startRecording();
          } else {
            // _isRecording = !_isRecording;
            record.stopRecording();
          }
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
