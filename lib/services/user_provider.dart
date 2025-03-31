import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _token;

  String? get token => _token;

  set token(String? token) {
    _token = token;
    notifyListeners(); // Token değiştiğinde dinleyicilere bildirim gönder
  }
}
