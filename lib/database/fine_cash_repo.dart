import 'dart:io';
import 'dart:math';

import 'package:fine_cash/database/remote_db.dart';
import 'package:fine_cash/models/metadatas.dart';
import 'package:fine_cash/providers/fine_cash_repo_provider.dart';
import 'package:fine_cash/providers/metadata_provider.dart';
import 'package:fine_cash/providers/txn_provider.dart';
import 'package:fine_cash/utilities/preferences.dart';
import 'package:fine_cash/utilities/random_icon.dart';
import 'package:random_color/random_color.dart';

import '../models/transactions.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'fine_cash_repo.g.dart';

@UseMoor(tables: [Transactions, MetaDatas])
class FineCashRepository extends _$FineCashRepository {
  TxnProvider txnProvider;
  MetaDataProvider metaDataProvider;
  RandomColor randomColor = RandomColor();
  var random = Random();

  FineCashRepository(this.txnProvider, this.metaDataProvider)
      : super(_openConnection()) {
    _syncTxnsLocalToProvider();
  }

  Future _syncTxnsLocalToProvider() async {
    await this.fetchAccounts();
    await this.fetchSubAccounts();
    await this.fetchAllTxns();
    await this.fetchAllMetaDatas();
    return true;
  }

  Future fetchAccounts() async {
    List<Transaction> allTxnEntries = await this.allTxnEntries;
    txnProvider.setAccountList(allTxnEntries
        .where((e) => !e.isDeleted)
        .map((e) => e.accountHead.toUpperCase())
        .toSet());
    return true;
  }

  Future fetchSubAccounts() async {
    List<Transaction> allTxnEntries = await this.allTxnEntries;
    txnProvider.setSubAccountList(allTxnEntries
        .where((e) => !e.isDeleted)
        .map((e) => e.subAccountHead.toUpperCase())
        .toSet());
    return true;
  }

  Future fetchAllTxns() async {
    List<Transaction> allTxnEntries = await this.allTxnEntries;
    txnProvider.setAllTxns(allTxnEntries);
    return true;
  }

  Future fetchAllMetaDatas() async {
    List<MetaData> allMetaDataEntries = await this.loadMetaDatas;
    metaDataProvider.setAllTxns(allMetaDataEntries);
    return true;
  }

  Future clearDB() async {
    await delete(transactions).go();
    await delete(metaDatas).go();
    txns = [];
    return true;
  }

  Future<bool> syncData() async {
    if (txns.isNotEmpty)
      for (Transaction txn in txns) {
        var cacheDBTxn = txnProvider.allTxns
            .firstWhere((e) => e.id == txn.id, orElse: () => null);
        var entry = TransactionsCompanion(
          id: Value(txn.id),
          accountHead: Value(txn.accountHead),
          subAccountHead: Value(txn.subAccountHead),
          createdDTime: Value(txn.createdDTime),
          credit: Value(txn.credit),
          debit: Value(txn.debit),
          desc: Value(txn.desc),
          txnOwner: Value(txn.txnOwner),
          isDeleted: Value(txn.isDeleted),
          isUpdated: Value(false),
          isSynced: Value(true),
          updatedDTime: Value(txn.updatedDTime),
        );

        if (cacheDBTxn == null) {
          await into(transactions).insert(entry, mode: InsertMode.insertOrFail);
          await _syncTxnsLocalToProvider();
          await _createMetaData(entry);
        } else {
          await update(transactions).replace(entry);
          await _syncTxnsLocalToProvider();
          await _createMetaData(entry);
        }
      }
    var notSynced = txnProvider.allTxns.where((e) => !e.isSynced).toList();
    print('notsynced');
    print(notSynced);
    if (notSynced.isNotEmpty) {
      notSynced.forEach((txn) async {
        var entry = TransactionsCompanion(
          id: Value(txn.id),
          accountHead: Value(txn.accountHead),
          subAccountHead: Value(txn.subAccountHead),
          createdDTime: Value(txn.createdDTime),
          credit: Value(txn.credit),
          debit: Value(txn.debit),
          desc: Value(txn.desc),
          txnOwner: Value(txn.txnOwner),
          isDeleted: Value(txn.isDeleted),
          isUpdated: Value(true),
          isSynced: Value(true),
          updatedDTime: Value(DateTime.now()),
        );
        var status = await update(transactions).replace(entry);
        print(status);
      });
      await syncTxns(txnProvider, repo);
    }
    return true;
  }

  Future _createMetaData(TransactionsCompanion entry) async {
    if (metaDataProvider.getMetaData(entry.accountHead.value) == null)
      await addMetaData(MetaDatasCompanion.insert(
          accountHead: entry.accountHead.value.toUpperCase(),
          icon: icons[random.nextInt(icons.length)],
          color: randomColor.randomMaterialColor().value));
    return true;
  }

  @override
  int get schemaVersion => 1;

  Future<int> addTxn(TransactionsCompanion entry) async {
    int rowId =
        await into(transactions).insert(entry, mode: InsertMode.insertOrFail);
    await _createMetaData(entry);
    await _syncTxnsLocalToProvider();
    var status = addRemoteTxn(entry, user);
    status.then((value) async {
      if (value)
        await update(transactions)
            .replace(entry.copyWith(isSynced: Value(true)));
      await _createMetaData(entry);
      await _syncTxnsLocalToProvider();
    });
    return rowId;
  }

  Future<bool> updateTxn(TransactionsCompanion entry) async {
    bool result = await update(transactions).replace(entry);
    await _syncTxnsLocalToProvider();
    var status = updateRemoteTxn(entry, user);
    status.then((value) async {
      print(value);
      if (value) {
        await update(transactions)
            .replace(entry.copyWith(isSynced: Value(true)));
        await _syncTxnsLocalToProvider();
      }
    });
    return result;
  }

  void deleteTxn(Set<String> ids) async {
    ids.forEach((id) async {
      var txn = txnProvider.allTxns.firstWhere((e) => e.id == id);
      await updateTxn(TransactionsCompanion.insert(
        isDeleted: Value(true),
        isUpdated: Value(false),
        id: txn.id,
        createdDTime: Value(txn.createdDTime),
        accountHead: txn.accountHead,
        subAccountHead: Value(txn.subAccountHead),
        credit: txn.credit != null ? Value(txn.credit) : Value(null),
        debit: txn.debit != null ? Value(txn.debit) : Value(null),
        desc: Value(txn.desc),
      ));
      var status = deleteRemoteTxn(id, user);
      status.then((value) async {
        if (value)
          await updateTxn(TransactionsCompanion.insert(
            isDeleted: Value(true),
            isUpdated: Value(false),
            id: txn.id,
            isSynced: Value(true),
            createdDTime: Value(txn.createdDTime),
            accountHead: txn.accountHead,
            subAccountHead: Value(txn.subAccountHead),
            credit: txn.credit != null ? Value(txn.credit) : Value(null),
            debit: txn.debit != null ? Value(txn.debit) : Value(null),
            desc: Value(txn.desc),
          ));
        await _syncTxnsLocalToProvider();
      });
    });
  }

  Future addMetaData(MetaDatasCompanion data) async {
    int result =
        await into(metaDatas).insert(data, mode: InsertMode.insertOrFail);
    this.fetchAllMetaDatas();
    return result;
  }

  Future<List<MetaData>> get loadMetaDatas async {
    return (select(metaDatas).get());
  }

  Future<List<Transaction>> get allTxnEntries {
    return (select(transactions)
          ..where((tbl) => tbl.txnOwner.equals(user))
          ..orderBy([(t) => OrderingTerm.desc(t.createdDTime)]))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = File(p.join(await _localPath, 'db.sqlite'));
    return VmDatabase(file, logStatements: false);
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
