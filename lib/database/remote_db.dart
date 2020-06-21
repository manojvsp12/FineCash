import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:fine_cash/database/fine_cash_repo.dart';
import 'package:fine_cash/providers/txn_provider.dart';
import 'package:fine_cash/utilities/preferences.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:mysql1/mysql1.dart';

MySqlConnection connection;

Map<String, String> userDetails = {};

List<Transaction> txns = [];

bool _isSyncing = false;

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
  if (connection == null) await connectdb();
  try {
    var results =
        await connection.query('SELECT * FROM u936125469_testdb.user');
    for (var row in results) {
      userDetails.putIfAbsent(row[0], () => row[1]);
    }
  } catch (e) {
    print(e);
    if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
      await connectdb();
      fetchUsers();
    }
  }
}

Future<bool> syncTxns(TxnProvider txnProvider, FineCashRepository repo) async {
  if (!_isSyncing) {
    print('sync');
    _isSyncing = true;
    if (await DataConnectionChecker().hasConnection) {
      if (connection == null) await connectdb();
      try {
        await _syncLocalToRemoteTxns(txnProvider, repo);
      } catch (e) {
        print('_syncLocalToRemoteTxns');
        print(e);
      }
      if (connection == null) connectdb();
      try {
        await _fetchRecords(txnProvider);
      } catch (e) {
        print('_fetchRecords');
        print(e);
      }
      try {
        var syncData = await repo.syncData();
        _isSyncing = false;
        return syncData;
      } catch (e) {
        print('syncData');
        print(e);
      }
    } else {
      _isSyncing = false;
      return false;
    }
  } else {
    // return true;
  }
}

Future _syncLocalToRemoteTxns(TxnProvider txnProvider, repo) async {
  txnProvider.allTxns.forEach((Transaction txn) async {
    try {
      if (!txn.isUpdated && !txn.isSynced) await _insertLocalToRemoteTxns(txn);
      if (txn.isUpdated && !txn.isSynced) await _updateLocalToRemoteTxns(txn);
      if (txn.isDeleted && !txn.isSynced) await _deleteLocalToRemoteTxns(txn);
    } catch (e) {
      if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
        await connectdb();
        await _syncLocalToRemoteTxns(txnProvider, repo);
      } else
        throw e;
    }
  });
}

_insertLocalToRemoteTxns(Transaction txn) async {
  Results result;
  try {
    if (connection == null) await connectdb();
    String query = 'insert into u936125469_testdb.transactions values' +
        '(\'${txn.id}\', \'${txn.accountHead}\', \'${txn.subAccountHead}\', \'${txn.desc}\', ${txn.credit}, ${txn.debit}, \'${txn.createdDTime}\',' +
        ' \'${user}\', ${txn.isDeleted == null ? false : txn.isDeleted}, \'${txn.updatedDTime}\');';
    result = await connection.query(query);
    return true;
  } catch (e) {
    print('_insertLocalToRemoteTxns sync');
    print(e);
    if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
      await connectdb();
      await _insertLocalToRemoteTxns(txn);
    }
    if (result == null)
      return false;
    else
      return true;
  }
}

_updateLocalToRemoteTxns(Transaction txn) async {
  Results result;
  try {
    var sql = 'update u936125469_testdb.transactions set ' +
        'account_head = \'${txn.accountHead}\'' +
        ',sub_account_head= \'${txn.subAccountHead}\'' +
        ',u936125469_testdb.transactions.desc=\'${txn.desc}\'' +
        ',credit = ' +
        ((txn.credit == null)
            ? null.toString()
            : txn.credit.toStringAsFixed(2)) +
        ',debit = ' +
        ((txn.debit == null) ? null.toString() : txn.debit.toStringAsFixed(2)) +
        ',createdDTime = \'${txn.createdDTime}\'' +
        ',updatedDTime = \'${txn.updatedDTime}\'' +
        ',is_deleted = ' +
        (txn.isDeleted == null ? false : txn.isDeleted.toString()) +
        ' where id = \'${txn.id}\' and txn_owner = \'' +
        user +
        '\'';
    result = await connection.query(sql);
    return true;
  } catch (e) {
    print('_updateLocalToRemoteTxns sync');
    print(e);
    if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
      await connectdb();
      await _updateLocalToRemoteTxns(txn);
    }
    if (result == null)
      return false;
    else
      return true;
  }
}

_deleteLocalToRemoteTxns(Transaction txn) async {
  Results result;
  try {
    if (connection == null) await connectdb();
    var sql = 'update u936125469_testdb.transactions set' +
        ' is_deleted = true where id = \'${txn.id}\' and txn_owner = \'${user}\';';
    result = await connection.query(sql);
    return true;
  } catch (e) {
    print('_deleteLocalToRemoteTxns sync');
    print(e);
    if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
      await connectdb();
      await _deleteLocalToRemoteTxns(txn);
    }
    if (result == null)
      return false;
    else
      return true;
  }
}

Future _fetchRecords(TxnProvider txnProvider) async {
  try {
    var results;
    if (connection == null) await connectdb();
    if (txnProvider.allTxns.where((e) => e.txnOwner == user).isEmpty) {
      var sql =
          'SELECT * FROM u936125469_testdb.transactions t where t.txn_owner = \'' +
              user +
              '\'';
      print(sql);
      results = await connection.query(sql);
    } else {
      var allTxns = txnProvider.allTxns;
      allTxns.sort((a, b) => b.updatedDTime.compareTo(a.updatedDTime));
      print(
          'SELECT * FROM u936125469_testdb.transactions t where updatedDTime > \'${allTxns.first.updatedDTime}\' and t.txn_owner = \'' +
              user +
              '\'');
      results = await connection.query(
          'SELECT * FROM u936125469_testdb.transactions t where updatedDTime >= \'${allTxns.first.updatedDTime}\' and t.txn_owner = \'' +
              user +
              '\'');
    }
    if (results != null)
      for (var row in results) {
        txns.add(Transaction(
          id: row[0],
          accountHead: row[1],
          subAccountHead: row[2],
          desc: row[3],
          credit: row[4],
          debit: row[5],
          createdDTime: row[6],
          txnOwner: row[7],
          isSynced: true,
          isDeleted: row[8] == 1 ? true : false,
          isUpdated: false,
          updatedDTime: row[9],
        ));
      }
  } catch (e) {
    if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
      await connectdb();
      await _fetchRecords(txnProvider);
    }
  }
}

Future<bool> addRemoteTxn(TransactionsCompanion entry, String user) async {
  Results result;
  try {
    print(entry.id.value);
    if (connection == null) await connectdb();
    String query = 'insert into u936125469_testdb.transactions values' +
        '(\'${entry.id.value}\', \'${entry.accountHead.value}\', \'${entry.subAccountHead.value}\', \'${entry.desc.value}\', ${entry.credit.value}, ${entry.debit.value}, \'${entry.createdDTime.value}\',' +
        ' \'${user}\', ${entry.isDeleted.value == null ? false : entry.isDeleted.value}, \'${entry.updatedDTime.value}\');';
    print(query);
    result = await connection.query(query);
    return true;
  } catch (e) {
    print('add');
    print(e);
    if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
      await connectdb();
      await addRemoteTxn(entry, user);
    }
  }
  if (result == null)
    return false;
  else
    return true;
}

Future<bool> updateRemoteTxn(TransactionsCompanion entry, String user) async {
  Results result;
  try {
    if (connection == null) await connectdb();
    String dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String query = 'update u936125469_testdb.transactions set ' +
        'account_head = \'${entry.accountHead.value}\', sub_account_head = \'${entry.subAccountHead.value}\', u936125469_testdb.transactions.desc = \'${entry.desc.value}\', credit = ${entry.credit.value}, debit = ${entry.debit.value}, createdDTime = \'${entry.createdDTime.value}\',' +
        ' is_deleted = ${entry.isDeleted.value == null ? false : entry.isDeleted.value}, updatedDTime = \'${dateTime}\' where id = \'${entry.id.value}\' and txn_owner = \'${user}\';';
    print(query);
    result = await connection.query(query);
    return true;
  } catch (e) {
    print('update');
    print(e);
    if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
      await connectdb();
      await updateRemoteTxn(entry, user);
    }
  }
  if (result == null)
    return false;
  else
    return true;
}

Future<bool> deleteRemoteTxn(id, user) async {
  Results result;
  try {
    if (connection == null) await connectdb();
    String dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String query = 'update u936125469_testdb.transactions set' +
        ' is_deleted = true, updatedDTime = \'${dateTime}\' where id = \'${id}\' and txn_owner = \'${user}\';';
    print(query);
    result = await connection.query(query);
    return true;
  } catch (e) {
    if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
      await connectdb();
      await deleteRemoteTxn(id, user);
    }
  }
  if (result == null)
    return false;
  else
    return true;
}
