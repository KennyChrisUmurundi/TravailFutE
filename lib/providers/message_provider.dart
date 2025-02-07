import 'package:flutter/material.dart';

class MessageProvider with ChangeNotifier {
  List<Map<String, String>> _messages = [];

  List<Map<String, String>> get messages => _messages;

  void setMessages(List<Map<String, String>> newMessages) {
    _messages = newMessages;
    notifyListeners();
  }
}