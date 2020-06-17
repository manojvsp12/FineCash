import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Map<String, dynamic> preferences;

String localPath;

String _user;

String get user => _user ?? '';

set user(String user) {
  _user = user;
}

Future<String> get _localPath async {
  if (Platform.isWindows) {
    final directories = await getApplicationDocumentsDirectory();
    localPath = directories.path;
    return localPath;
  } else {
    final directories = await getExternalStorageDirectory();
    localPath = directories.path;
    return localPath;
  }
}

Future<File> get _localFile async {
  localPath = await _localPath;
  if (Platform.isWindows) {
    var dir = new Directory('$localPath\\FineCash');
    if (dir.existsSync())
      return File('$localPath\\FineCash\\application.properties');
    else {
      new Directory('$localPath\\FineCash').createSync();
      return File('$localPath\\FineCash\\application.properties');
    }
  } else
    return File('$localPath/application.properties');
}

write(Map<String, dynamic> contents) async {
  final file = await _localFile;
  await file.writeAsString(jsonEncode(contents));
}

Future<Map<String, dynamic>> loadPreferences() async {
  try {
    final file = await _localFile;
    String contents = await file.readAsString();
    preferences = jsonDecode(contents);
    _user = preferences['username'];
    return Future.value(preferences);
  } catch (e) {
    write({"isAuth": false});
    _user = null;
    return loadPreferences();
  }
}
