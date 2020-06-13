import 'dart:io';

import 'package:fine_cash/database/fine_cash_repo.dart';
import 'package:fine_cash/database/remote_db.dart';
import 'package:fine_cash/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moor/moor.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import './screens/login_page.dart';
import 'constants/constants.dart';
import 'providers/login_provider.dart';
import 'utilities/preferences.dart';
import 'utilities/security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Future.delayed(Duration.zero).then((finish) async {
    if (Platform.isWindows) {
      PlatformWindow window = await getWindowInfo();
      print(window.screen.frame.height);
      setWindowFrame(Rect.fromLTWH(
          0, 0, window.screen.frame.width, window.screen.frame.height - 80));
    }
  });
  await loadPreferences();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => LoginProvider(),
        builder: (context, child) {
          return MaterialApp(
            title: 'Flutter Login UI',
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (_) => preferences?.containsKey('isAuth') ?? false
                  ? preferences['isAuth'] ? HomePage() : LoginPage(onLogin)
                  : LoginPage(onLogin),
              '/loginscreen': (_) => LoginPage(onLogin),
              '/homescreen': (_) => HomePage(),
            },
          );
        });
  }
}

onLogin(context, key, username, pwd) async {
  // await FineCashRepository.instance.addTxn(
  //     TransactionsCompanion.insert(accountHead: 'acct8', debit: Value(10)));
  // print(await FineCashRepository.instance.allTxnEntries);
  var auth = Provider.of<LoginProvider>(context, listen: false);
  try {
    auth.isAuth = true;
    auth.username = username;
    auth.pwd = pwd;
    await connectdb();
    await fetchUsers();
    auth.message = 'SIGNING IN...';
    auth.isAuth = authenticate(auth.username, auth.pwd);
    if (auth.isAuth) {
      auth.message = 'SYNCING TRANSACTIONS...';
      await syncTxns();
      Navigator.popAndPushNamed(context, '/homescreen');
    } else {
      key.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Failed to Sign in.')));
    }
  } catch (e) {
    auth.isAuth = false;
    key.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Failed to connect to DB.')));
  }
}
