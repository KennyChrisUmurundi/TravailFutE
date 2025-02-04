import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:phone_state/phone_state.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:travail_fute/utils/provider.dart';
import 'package:travail_fute/utils/record.dart';
import 'package:travail_fute/utils/phone_state.dart';

class PhoneStateService {
  PhoneState status = PhoneState.nothing();
  final logger = Logger();
  late final Recording record; // Declare record without initialization
  String number = "00000";
  

  PhoneStateService(BuildContext context) {
    record = Recording(context); // Initialize record with deviceToken
  }

  void startListening() {
    setStream(handlePhoneState);
  }

  void handlePhoneState( event) async {
    // ignore: unnecessary_null_comparison
    if (event != null) {
      logger.d("CALL EVENT RECEIVED");
      status = event;
      if (status.status == PhoneStateStatus.CALL_INCOMING ||
          status.status == PhoneStateStatus.CALL_STARTED) {
        getNumber(status);
        // This is where i record the call
        if (status.status == PhoneStateStatus.CALL_STARTED) {
          record.startRecording();
        }
      }
    }
    if (status.status == PhoneStateStatus.CALL_ENDED) {
      bool isRecording = await record.checkRecordingStatus();
      if (isRecording) {
        record.stopRecording(number);
      }
    }
  }

  void getNumber(status) async {
    number = status.number;
    logger.d("CALL FROM: $number");
  }
}
