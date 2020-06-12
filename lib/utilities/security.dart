import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fine_cash/database/remote_db.dart';
import 'package:fine_cash/utilities/preferences.dart';

String hash(data1, data2) {
  var key = utf8.encode(data1);
  var bytes = utf8.encode(data2);

  var hmacSha256 = new Hmac(sha256, key);
  var digest = hmacSha256.convert(bytes);

  print("HMAC digest as hex string: $digest");
  return digest.toString();
}

bool authenticate(String username, String pwd) {
  var userHash = hash(username, pwd);
  var pwdHash = hash(pwd, username);
  print(userDetails);
  if (userDetails.containsKey(userHash) && pwdHash == userDetails[userHash]) {
    write({"isAuth": true});
    return true;
  } else {
    return false;
  }
}
