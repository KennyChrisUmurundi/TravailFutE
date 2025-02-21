import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';

// This Function is for the user to accept the phone state permission
Future<bool> requestPermission() async {
  var status = await Permission.phone.status;
  if (status.isDenied || status.isRestricted || status.isLimited || status.isPermanentlyDenied) {
    status = await Permission.phone.request();
  }

  switch (status) {
    case PermissionStatus.denied:
      return false;

    case PermissionStatus.granted:
      return true;

    case PermissionStatus.restricted:
      return false;

    case PermissionStatus.limited:
      return false;

    case PermissionStatus.permanentlyDenied:
      return false;

    case PermissionStatus.provisional:
      return false;
  }
}

void setStream(Function(PhoneState) callback) async {
  if (await requestPermission()) {
    PhoneState.stream.listen((event) {
      callback(event);
    });
  } else {
    print("Permission not granted.");
  }
}
