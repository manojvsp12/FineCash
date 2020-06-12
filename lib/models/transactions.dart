import 'package:moor/moor.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountHead => text().nullable()();
  TextColumn get subAccountHead => text().nullable()();
  TextColumn get desc => text().nullable()();
  RealColumn get credit => real().nullable()();
  RealColumn get debit => real().nullable()();
  DateTimeColumn get createdDTime =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(Constant(false))();
}
