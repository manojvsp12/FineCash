import 'dart:convert';

import 'package:crypto/crypto.dart';

String hash(data1, data2) {
  var key = utf8.encode(data1);
  var bytes = utf8.encode(data2);

  var hmacSha256 = new Hmac(sha256, key);
  var digest = hmacSha256.convert(bytes);

  print("HMAC digest as hex string: $digest");
  return digest.toString();
}
