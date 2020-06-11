import 'package:mysql1/mysql1.dart';

var connection;

Map<String, String> userDetails = {};

var settings = new ConnectionSettings(
    host: '81.16.28.154',
    port: 3306,
    user: 'u936125469_testdb',
    password: 'testdb',
    db: 'u936125469_testdb');

connectdb() async {
  connection = await MySqlConnection.connect(settings);
}

fetchUsers() async {
  var results = await connection.query('SELECT * FROM u936125469_testdb.user');
  for (var row in results) {
    userDetails.putIfAbsent(row[0], () => row[1]);
  }
  print(userDetails);
}
