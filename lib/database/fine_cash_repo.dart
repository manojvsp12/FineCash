import 'dart:io';

import 'package:fine_cash/models/metadatas.dart';
import 'package:fine_cash/providers/txn_provider.dart';
import 'package:fine_cash/utilities/preferences.dart';

import '../models/transactions.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'fine_cash_repo.g.dart';

@UseMoor(tables: [Transactions, MetaDatas])
class FineCashRepository extends _$FineCashRepository {
  TxnProvider txnProvider;

  FineCashRepository(this.txnProvider) : super(_openConnection()) {
    this.fetchAccounts();
    this.fetchSubAccounts();
    this.fetchAllTxns();
  }

  void fetchAccounts() async {
    List<Transaction> allTxnEntries = await this.allTxnEntries;
    print(allTxnEntries);
    txnProvider.setAccountList(allTxnEntries.map((e) => e.accountHead).toSet());
  }

  void fetchSubAccounts() async {
    List<Transaction> allTxnEntries = await this.allTxnEntries;
    txnProvider
        .setSubAccountList(allTxnEntries.map((e) => e.subAccountHead).toSet());
  }

  void fetchAllTxns() async {
    List<Transaction> allTxnEntries = await this.allTxnEntries;
    txnProvider.setAllTxns(allTxnEntries);
  }

  @override
  int get schemaVersion => 1;

  Future<int> addTxn(TransactionsCompanion entry) async {
    int result =
        await into(transactions).insert(entry, mode: InsertMode.insertOrFail);
    this.fetchAccounts();
    this.fetchSubAccounts();
    this.fetchAllTxns();
    return result;
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
    print(await _localPath);
    final file = File(p.join(await _localPath, 'db.sqlite'));
    return VmDatabase(file, logStatements: true);
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
