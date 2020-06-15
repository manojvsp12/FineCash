import 'dart:io';

import 'package:fine_cash/database/remote_db.dart';
import 'package:fine_cash/providers/filter_provider.dart';
import 'package:fine_cash/providers/metadata_provider.dart';
import 'package:fine_cash/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import './screens/login_page.dart';
import 'providers/login_provider.dart';
import 'providers/txn_provider.dart';
import 'utilities/preferences.dart';
import 'utilities/security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Future.delayed(Duration.zero).then((finish) async {
    if (Platform.isWindows) {
      PlatformWindow window = await getWindowInfo();
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
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginProvider()),
          ChangeNotifierProvider(create: (_) => TxnProvider()),
          ChangeNotifierProvider(create: (_) => MetaDataProvider()),
          ChangeNotifierProvider(create: (_) => FilterProvider()),
        ],
        child: MaterialApp(
          title: 'Flutter Login UI',
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (_) => preferences?.containsKey('isAuth') ?? false
                ? preferences['isAuth']
                    ? HomePage(onLogout)
                    : LoginPage(onLogin)
                : LoginPage(onLogin),
            '/loginscreen': (_) => LoginPage(onLogin),
            '/homescreen': (_) => HomePage(onLogout),
          },
        ));
  }
}

onLogout(context) {
  Navigator.popAndPushNamed(context, '/loginscreen');
  var auth = Provider.of<LoginProvider>(context, listen: false);
  auth.isAuth = false;
  auth.username = '';
  auth.pwd = '';
  write({"isAuth": false});
}

onLogin(context, key, username, pwd) async {
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
