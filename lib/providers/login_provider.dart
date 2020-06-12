import 'package:flutter/foundation.dart';

class LoginProvider with ChangeNotifier {
  String username;
  String pwd;
  bool _isAuth = false;
  String _message = 'SIGNING IN...';

  bool get isAuth => _isAuth;

  String get message => _message;

  set isAuth(bool isAuth) {
    _isAuth = isAuth;
    notifyListeners();
  }

  set message(String message) {
    _message = message;
    notifyListeners();
  }
}
