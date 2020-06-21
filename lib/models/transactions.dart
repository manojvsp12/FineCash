import 'package:fine_cash/utilities/preferences.dart';
import 'package:moor/moor.dart';

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get accountHead => text()();
  TextColumn get subAccountHead => text().nullable()();
  TextColumn get desc => text().nullable()();
  RealColumn get credit => real().nullable()();
  RealColumn get debit => real().nullable()();
  DateTimeColumn get createdDTime =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(Constant(false))();
  TextColumn get txnOwner => text().clientDefault(() => user)();
  BoolColumn get isUpdated => boolean().withDefault(Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(Constant(false))();
  DateTimeColumn get updatedDTime =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
