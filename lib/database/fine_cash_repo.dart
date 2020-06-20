import 'dart:io';
import 'dart:math';

import 'package:fine_cash/database/remote_db.dart';
import 'package:fine_cash/models/metadatas.dart';
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
    this.fetchAccounts();
    this.fetchSubAccounts();
    this.fetchAllTxns();
    this.fetchAllMetaDatas();
  }

  void fetchAccounts() async {
    List<Transaction> allTxnEntries = await this.allTxnEntries;
    txnProvider.setAccountList(allTxnEntries
        .where((e) => !e.isDeleted)
        .map((e) => e.accountHead.toUpperCase())
        .toSet());
  }

  void fetchSubAccounts() async {
    List<Transaction> allTxnEntries = await this.allTxnEntries;
    txnProvider.setSubAccountList(allTxnEntries
        .where((e) => !e.isDeleted)
        .map((e) => e.subAccountHead.toUpperCase())
        .toSet());
  }

  void fetchAllTxns() async {
    List<Transaction> allTxnEntries = await this.allTxnEntries;
    txnProvider.setAllTxns(allTxnEntries);
  }

  void fetchAllMetaDatas() async {
    List<MetaData> allMetaDataEntries = await this.loadMetaDatas;
    metaDataProvider.setAllTxns(allMetaDataEntries);
  }

  void clearDB() async {
    await delete(transactions).go();
    await delete(metaDatas).go();
  }

  Future<bool> syncData() async {
    txns.forEach((txn) {
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
      );

      if (cacheDBTxn == null) {
        addTxn(entry);
        if (metaDataProvider.getMetaData(entry.accountHead.value) == null)
          addMetaData(MetaDatasCompanion.insert(
              accountHead: entry.accountHead.value.toUpperCase(),
              icon: icons[random.nextInt(icons.length)],
              color: randomColor.randomMaterialColor().value));
      } else {
        updateTxn(entry);
        if (metaDataProvider.getMetaData(entry.accountHead.value) == null)
          addMetaData(MetaDatasCompanion.insert(
              accountHead: entry.accountHead.value.toUpperCase(),
              icon: icons[random.nextInt(icons.length)],
              color: randomColor.randomMaterialColor().value));
      }
    });
    return true;
  }

  @override
  int get schemaVersion => 1;

  Future<int> addTxn(TransactionsCompanion entry) async {
    var randomNumber = random.nextInt(icons.length);
    int rowId =
        await into(transactions).insert(entry, mode: InsertMode.insertOrFail);
    this.fetchAccounts();
    this.fetchSubAccounts();
    this.fetchAllTxns();
    if (metaDataProvider.getMetaData(entry.accountHead.value) == null)
      await addMetaData(MetaDatasCompanion.insert(
          accountHead: entry.accountHead.value.toUpperCase(),
          icon: icons[randomNumber],
          color: randomColor.randomMaterialColor().value));
    var status = addRemoteTxn(entry, user);
    status.then((value) async {
      if (value)
        await update(transactions)
            .replace(entry.copyWith(isSynced: Value(true)));
      this.fetchAccounts();
      this.fetchSubAccounts();
      this.fetchAllTxns();
      this.fetchAllMetaDatas();
    });
    return rowId;
  }

  Future<bool> updateTxn(TransactionsCompanion entry) async {
    bool result = await update(transactions).replace(entry);
    this.fetchAccounts();
    this.fetchSubAccounts();
    this.fetchAllTxns();
    this.fetchAllMetaDatas();
    var status = updateRemoteTxn(entry, user);
    status.then((value) async {
      if (value)
        await update(transactions)
            .replace(entry.copyWith(isSynced: Value(true)));
      this.fetchAccounts();
      this.fetchSubAccounts();
      this.fetchAllTxns();
      this.fetchAllMetaDatas();
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
        this.fetchAccounts();
        this.fetchSubAccounts();
        this.fetchAllTxns();
        this.fetchAllMetaDatas();
      });
    });
  }

  addMetaData(MetaDatasCompanion data) async {
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
