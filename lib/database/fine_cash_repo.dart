import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
    print(allTxnEntries);
    txnProvider.setAccountList(
        allTxnEntries.map((e) => e.accountHead.toUpperCase()).toSet());
  }

  void fetchSubAccounts() async {
    List<Transaction> allTxnEntries = await this.allTxnEntries;
    txnProvider.setSubAccountList(
        allTxnEntries.map((e) => e.subAccountHead.toUpperCase()).toSet());
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

  @override
  int get schemaVersion => 1;

  Future<int> addTxn(TransactionsCompanion entry) async {
    var randomNumber = random.nextInt(icons.length);
    print(icons[randomNumber].codePoint);
    print(icons[randomNumber].fontFamily);
    print(icons[randomNumber].fontPackage);
    int result =
        await into(transactions).insert(entry, mode: InsertMode.insertOrFail);
    this.fetchAccounts();
    this.fetchSubAccounts();
    this.fetchAllTxns();
    print(entry.accountHead.value);
    if (metaDataProvider.getMetaData(entry.accountHead.value) == null)
      await addMetaData(MetaDatasCompanion.insert(
          accountHead: entry.accountHead.value.toUpperCase(),
          icon: json.encode({
            'codePoint': icons[randomNumber].codePoint,
            'fontFamily': icons[randomNumber].fontFamily
          }),
          color: randomColor.randomMaterialColor().value));
    return result;
  }

  Future<bool> updateTxn(TransactionsCompanion entry) async {
    bool result = await update(transactions).replace(entry);
    this.fetchAccounts();
    this.fetchSubAccounts();
    this.fetchAllTxns();
    this.fetchAllMetaDatas();
    return result;
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
