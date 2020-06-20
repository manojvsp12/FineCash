import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:fine_cash/database/fine_cash_repo.dart';
import 'package:fine_cash/providers/txn_provider.dart';
import 'package:fine_cash/utilities/preferences.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:mysql1/mysql1.dart';

MySqlConnection connection;

Map<String, String> userDetails = {};

List<Transaction> txns = [];

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

Future<bool> syncTxns(TxnProvider txnProvider, repo) async {
  if (await DataConnectionChecker().hasConnection) {
    if (connection == null) await connectdb();
    txnProvider.allTxns.forEach((Transaction txn) async {
      try {
        if (!txn.isUpdated && !txn.isSynced)
          try {
            if (connection == null) await connectdb();
            String query = 'insert into u936125469_testdb.transactions values' +
                '(\'${txn.id}\', \'${txn.accountHead}\', \'${txn.subAccountHead}\', \'${txn.desc}\', ${txn.credit}, ${txn.debit}, \'${txn.createdDTime}\',' +
                ' \'${user}\', ${txn.isDeleted == null ? false : txn.isDeleted});';
            Results result = await connection.query(query);
            return true;
          } catch (e) {
            print('add sync');
            print(e);
            if (e.toString() ==
                'Bad state: Cannot write to socket, it is closed') {
              await connectdb();
              await syncTxns(txnProvider, user);
            }
            return false;
          }
        if (txn.isUpdated) {
          String dateTime =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(txn.createdDTime);
          var sql = 'update u936125469_testdb.transactions set ' +
              'account_head = \'${txn.accountHead}\'' +
              ',sub_account_head= \'${txn.subAccountHead}\'' +
              ',u936125469_testdb.transactions.desc=\'${txn.desc}\'' +
              ',credit = ' +
              ((txn.credit == null)
                  ? null.toString()
                  : txn.credit.toStringAsFixed(2)) +
              ',debit = ' +
              ((txn.debit == null)
                  ? null.toString()
                  : txn.debit.toStringAsFixed(2)) +
              ',createdDTime = \'${dateTime}\'' +
              ',txn_owner = \'${user}\'' +
              ',is_deleted = ' +
              (txn.isDeleted == null ? false : txn.isDeleted.toString()) +
              ' where id = \'${txn.id}\' and txn_owner = \'' +
              user +
              '\'';
          await connection.query(sql);
        }
        if (txn.isDeleted) {
          var sql = 'update u936125469_testdb.transactions set' +
              ' is_deleted = true where id = \'${txn.id}\' and txn_owner = \'${user}\';';
          await connection.query(sql);
        }
      } catch (e) {
        if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
          await connectdb();
          await syncTxns(txnProvider, repo);
        } else
          throw e;
      }
    });

    if (connection == null)
      connection = await MySqlConnection.connect(settings);
    await _fetchRecords();
    return repo.syncData();
  } else {
    return false;
  }
}

Future _fetchRecords() async {
  try {
    if (connection == null) await connectdb();
    var results = await connection.query(
        'SELECT * FROM u936125469_testdb.transactions t where t.txn_owner = \'' +
            user +
            '\'');
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
      ));
    }
  } catch (e) {
    if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
      await connectdb();
      await _fetchRecords();
    }
  }
}

Future<bool> addRemoteTxn(TransactionsCompanion entry, String user) async {
  try {
    if (connection == null) await connectdb();
    String query = 'insert into u936125469_testdb.transactions values' +
        '(\'${entry.id.value}\', \'${entry.accountHead.value}\', \'${entry.subAccountHead.value}\', \'${entry.desc.value}\', ${entry.credit.value}, ${entry.debit.value}, \'${entry.createdDTime.value}\',' +
        ' \'${user}\', ${entry.isDeleted.value == null ? false : entry.isDeleted.value});';
    Results result = await connection.query(query);
    return true;
  } catch (e) {
    print('add');
    print(e);
    if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
      await connectdb();
      await addRemoteTxn(entry, user);
    }
    return false;
  }
}

Future<bool> updateRemoteTxn(TransactionsCompanion entry, String user) async {
  try {
    if (connection == null) await connectdb();
    String query = 'update u936125469_testdb.transactions set ' +
        'account_head = \'${entry.accountHead.value}\', sub_account_head = \'${entry.subAccountHead.value}\', u936125469_testdb.transactions.desc = \'${entry.desc.value}\', credit = ${entry.credit.value}, debit = ${entry.debit.value}, createdDTime = \'${entry.createdDTime.value}\',' +
        ' is_deleted = ${entry.isDeleted.value == null ? false : entry.isDeleted.value} where id = \'${entry.id.value}\' and txn_owner = \'${user}\';';
    Results result = await connection.query(query);
    return true;
  } catch (e) {
    print('update');
    print(e);
    if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
      await connectdb();
      await updateRemoteTxn(entry, user);
    }
    return false;
  }
}

Future<bool> deleteRemoteTxn(id, user) async {
  try {
    if (connection == null) await connectdb();
    String query = 'update u936125469_testdb.transactions set' +
        ' is_deleted = true where id = \'${id}\' and txn_owner = \'${user}\';';
    Results result = await connection.query(query);
    return true;
  } catch (e) {
    if (e.toString() == 'Bad state: Cannot write to socket, it is closed') {
      await connectdb();
      await deleteRemoteTxn(id, user);
    }
    return false;
  }
}
