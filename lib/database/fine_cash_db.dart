import 'dart:io';

import '../models/transactions.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'fine_cash_db.g.dart';

@UseMoor(tables: [Transactions])
class FineCashDatabase extends _$FineCashDatabase {
  static FineCashDatabase _instance;

  FineCashDatabase() : super(_openConnection());

  static FineCashDatabase get instance => _getInstance();

  static _getInstance() {
    if (_instance == null) {
      _instance = new FineCashDatabase();
    }
    return _instance;
  }

  @override
  int get schemaVersion => 1;

  Future<int> addTxn(TransactionsCompanion entry) {
    return into(transactions).insert(entry);
  }

  Future<List<Transaction>> get allTxnEntries {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdDTime)]))
        .get();
  }
}

LazyDatabase _openConnection() {
  // if (Platform.isWindows)
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final file = File(p.join(await _localPath, 'db.sqlite'));
    return VmDatabase(file);
  });
}

Future<String> get _localPath async {
  if (Platform.isWindows) {
    final directories = await getApplicationDocumentsDirectory();
    var dir = new Directory(directories.path + '\\FineCash');
    if (dir.existsSync())
      return directories.path + '\\FineCash';
    else {
      new Directory(directories.path + '\\FineCash').createSync();
      return directories.path + '\\FineCash';
    }
  } else {
    final directories = await getExternalStorageDirectory();
    return directories.path;
  }
}
