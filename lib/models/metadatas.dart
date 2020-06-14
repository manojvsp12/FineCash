import 'package:moor/moor.dart';

class MetaDatas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountHead => text()();
  TextColumn get icon => text()();
  TextColumn get color => text()();
}