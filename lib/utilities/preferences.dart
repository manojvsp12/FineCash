import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Map<String, dynamic> preferences;

String _user;

String get user => _user ?? '';

Future<String> get _localPath async {
  if (Platform.isWindows) {
    final directories = await getApplicationDocumentsDirectory();
    return directories.path;
  } else {
    final directories = await getExternalStorageDirectory();
    return directories.path;
  }
}

Future<File> get _localFile async {
  final path = await _localPath;
  if (Platform.isWindows) {
    var dir = new Directory('$path\\FineCash');
    if (dir.existsSync())
      return File('$path\\FineCash\\application.properties');
    else {
      new Directory('$path\\FineCash').createSync();
      return File('$path\\FineCash\\application.properties');
    }
  } else
    return File('$path/application.properties');
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

