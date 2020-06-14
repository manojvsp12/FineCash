import 'package:fine_cash/database/fine_cash_repo.dart';
import 'package:flutter/foundation.dart';

class TxnProvider with ChangeNotifier {
  Set<String> accountList = {};
  Set<String> subAccountList = {};
  List<Transaction> allTxns = [];

  Set<String> get getAccountList => accountList;

  setAccountList(Set<String> accountList) {
    this.accountList = accountList;
    notifyListeners();
  }

  Set<String> get getSubAccountList => accountList;

  setSubAccountList(Set<String> _subAccountList) {
    this.subAccountList = _subAccountList;
    notifyListeners();
  }

  List<Transaction> get getAllTxns => allTxns;

  setAllTxns(List<Transaction> allTxns) {
    this.allTxns = allTxns;
    notifyListeners();
  }
}
