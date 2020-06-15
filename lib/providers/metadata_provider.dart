import 'package:fine_cash/database/fine_cash_repo.dart' as repo;
import 'package:flutter/widgets.dart';

class MetaDataProvider extends ChangeNotifier {
  List<repo.MetaData> allMetaData = [];

  List<repo.MetaData> get getAllMetaData => allMetaData;

  setAllTxns(List<repo.MetaData> allMetaData) {
    this.allMetaData = allMetaData;
    notifyListeners();
  }

  repo.MetaData getMetaData(String accountHead) {
    return getAllMetaData.firstWhere(
        (element) => element.accountHead == accountHead,
        orElse: () => null);
  }
}
