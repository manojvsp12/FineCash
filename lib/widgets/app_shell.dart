import 'package:fine_cash/constants/constants.dart';
import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final String title;
  final Widget child;
  const AppShell({Key key, this.title, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: child,
    );
  }
}
