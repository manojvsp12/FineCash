import 'dart:io';

import 'package:fine_cash/utilities/preferences.dart';

import '../models/transactions.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'fine_cash_repo.g.dart';

@UseMoor(tables: [Transactions])
class FineCashRepository extends _$FineCashRepository {
  static FineCashRepository _instance;

  Set<String> accountList;
  Set<String> get getAccountList => accountList;

  static setAccountList(Set<String> accountList) =>
      FineCashRepository.instance.accountList = accountList;

  FineCashRepository() : super(_openConnection());

  static FineCashRepository get instance => _getInstance();

  static _getInstance() {
    if (_instance == null) {
      _instance = new FineCashRepository();
      // fetchAccounts();
    }
    return _instance;
  }

  static void fetchAccounts() async {
    await _instance.allTxnEntries
        .then((txns) => setAccountList(txns.map((e) => e.accountHead).toSet()));
  }

  @override
  int get schemaVersion => 1;

  Future<int> addTxn(TransactionsCompanion entry) {
    return into(transactions).insert(entry);
  }

  Future<List<Transaction>> get allTxnEntries {
    return (select(transactions)
          ..where((tbl) => tbl.txnOwner.equals(user))
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
