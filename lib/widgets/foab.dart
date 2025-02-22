import 'package:flutter/material.dart';
import 'package:travail_fute/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:travail_fute/utils/record.dart';

class RecordFAB extends StatefulWidget {
  final void Function(String) onPressed;

  const RecordFAB({required this.onPressed, super.key});

  @override
  State<RecordFAB> createState() => _RecordFABState();
}

class _RecordFABState extends State<RecordFAB> {
  bool _isRecording = false;
  bool _isloadding = false;
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
            record.stopRecording().then((output) async {
                setState(() {
                _isloadding = true;
                });
                final result = await output;
                setState(() {
                _isloadding = false;
                });
              widget.onPressed(result);
            });
          }
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isloadding
            ? const CircularProgressIndicator(
          color: Colors.white,
              )
            : _isRecording
          ? const SpinKitWave(
              color: Colors.white,
              size: 20.0,
            )
          : const Icon(Icons.mic_none, key: ValueKey<int>(1)),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
      ),
    );
  }
}
