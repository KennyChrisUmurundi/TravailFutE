import 'package:flutter/foundation.dart';

class TokenProvider with ChangeNotifier {
  late String _token;

  String get token => _token;

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }
}