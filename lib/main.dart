import 'dart:io';

import 'package:fine_cash/database/fine_cash_db.dart';
import 'package:flutter/material.dart';
import 'package:moor/moor.dart';
import 'package:window_size/window_size.dart';
import './screens/login_screen.dart';
import 'database/remote_db.dart';
import 'utilities/preferences.dart';
import 'utilities/security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Future.delayed(Duration.zero).then((finish) async {
    if (Platform.isWindows) {
      PlatformWindow window = await getWindowInfo();
      setWindowFrame(Rect.fromLTWH(
          0, 0, window.screen.frame.width, window.screen.frame.height));
    }
  });
  await loadPreferences();
  // await connectdb();
  // await fetchUsers();
  // FineCashDatabase.instance.addTxn(TransactionsCompanion(accountHead: Value('acct3')));
  print(await FineCashDatabase.instance.allTxnEntries);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login UI',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => preferences?.containsKey('isAuth') ?? false
            ? preferences['isAuth'] ? HomeScreen() : LoginScreen(onLogin)
            : LoginScreen(onLogin),
        '/loginscreen': (_) => LoginScreen(onLogin),
        '/homescreen': (_) => HomeScreen(),
      },
    );
  }
}

onLogin(context, username, pwd) {
  var userHash = hash(username, pwd);
  var pwdHash = hash(pwd, username);
  print(userHash);
  print(userDetails.containsKey(userHash));
  if (userDetails.containsKey(userHash) && pwdHash == userDetails[userHash]) {
    write({"isAuth": true});
    Navigator.popAndPushNamed(context, '/homescreen');
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      child: Scaffold(
        body: Center(
            child: RaisedButton(
          onPressed: () {
            write({"isAuth": false});
            Navigator.popAndPushNamed(context, '/loginscreen');
          },
          child: Text('log out'),
        )),
      ),
    );
  }
}
