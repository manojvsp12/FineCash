import 'package:flutter/widgets.dart';

class FilterProvider extends ChangeNotifier {
  List<String> _acctFilter = [];
  List<String> _subAcctFilter = [];

  List<String> get acctFilter => _acctFilter;

  set acctFilter(List<String> value) {
    _acctFilter = value;
    notifyListeners();
  }

  List<String> get subAcctFilter => _subAcctFilter;

  set subAcctFilter(List<String> value) {
    _subAcctFilter = value;
    notifyListeners();
  }
}
