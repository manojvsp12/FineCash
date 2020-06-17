import 'dart:io';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:easy_permission_validator/easy_permission_validator.dart';
import 'package:excel/excel.dart';
import 'package:fine_cash/constants/constants.dart';
import 'package:fine_cash/database/fine_cash_repo.dart';
import 'package:fine_cash/models/account_summary.dart';
import 'package:fine_cash/providers/filter_provider.dart';
import 'package:fine_cash/providers/metadata_provider.dart';
import 'package:fine_cash/providers/txn_provider.dart';
import 'package:fine_cash/widgets/account_summary_card.dart';
import 'package:fine_cash/widgets/accounts_card.dart';
import 'package:fine_cash/widgets/process_transaction.dart';
import 'package:fine_cash/widgets/sub_accounts_list.dart';
import 'package:fine_cash/widgets/txn_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:icons_helper/icons_helper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

ValueNotifier<int> currentIndex = ValueNotifier(0);
final Set<int> selected = {};
GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

void changePage(int index) {
  currentIndex.value = index;
}

class HomePage extends StatefulWidget {
  final Function onLogout;

  HomePage(this.onLogout, {Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TxnProvider txnProvider;
  MetaDataProvider metaDataProvider;
  FineCashRepository repo;
  var titles = ['Accounts', 'Transactions', 'Report', 'Sync'];

  @override
  void initState() {
    super.initState();
    _permissionRequest();
    if (txnProvider == null)
      txnProvider = Provider.of<TxnProvider>(context, listen: false);
    if (metaDataProvider == null)
      metaDataProvider = Provider.of<MetaDataProvider>(context, listen: false);
    if (repo == null) repo = FineCashRepository(txnProvider, metaDataProvider);
  }

  _permissionRequest() async {
    final permissionValidator = EasyPermissionValidator(
      context: context,
      appName: 'Easy Permission Validator',
    );
    var result = await permissionValidator.storage();
    if (result) {
      print(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentIndex,
      builder: (context, index, child) => Scaffold(
        key: _scaffoldKey,
        appBar: buildAppBar(context, titles[index]),
        backgroundColor: kPrimaryColor,
        body: AccountSummaryPage(currentIndex: index, repo: repo),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: _buildFloatingActionButton(context),
        bottomNavigationBar: _buildNavBar(index, context),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton(context) {
    return FloatingActionButton(
      backgroundColor: Colors.amberAccent,
      foregroundColor: Colors.black,
      child: Icon(Icons.add),
      onPressed: () {
        slideDialog.showSlideDialog(
          context: context,
          child: ProcessTransaction(
            context: context,
            repo: repo,
            txnProvider: txnProvider,
          ),
          barrierColor: Colors.grey,
          pillColor: Colors.amberAccent,
          backgroundColor: Colors.white,
        );
      },
    );
  }

  BubbleBottomBar _buildNavBar(int index, context) {
    FilterProvider filter = Provider.of<FilterProvider>(context);
    return BubbleBottomBar(
      backgroundColor: Colors.white,
      opacity: .2,
      currentIndex: index,
      onTap: (index) {
        filter.acctFilter = [];
        filter.subAcctFilter = [];
        selected.clear();
        repo.fetchSubAccounts();
        changePage(index);
      },
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      elevation: 8,
      fabLocation: BubbleBottomBarFabLocation.end,
      hasNotch: true,
      hasInk: true,
      inkColor: Colors.black12,
      items: <BubbleBottomBarItem>[
        BubbleBottomBarItem(
            backgroundColor: Colors.red,
            icon: Icon(
              Icons.dashboard,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.dashboard,
              color: Colors.red,
            ),
            title: Text(titles[index])),
        BubbleBottomBarItem(
            backgroundColor: Colors.deepPurple,
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.menu,
              color: Colors.deepPurple,
            ),
            title: Text(titles[index])),
        BubbleBottomBarItem(
            backgroundColor: Colors.indigo,
            icon: Icon(
              Icons.folder_open,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.folder_open,
              color: Colors.indigo,
            ),
            title: Text(titles[index])),
        BubbleBottomBarItem(
            backgroundColor: Colors.green,
            icon: Icon(
              Icons.sync,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.sync,
              color: Colors.green,
            ),
            title: Text(titles[index]))
      ],
    );
  }

  AppBar buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: kBackgroundColor,
      elevation: 0,
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 150),
        child: Center(
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      ),
      actions: [
        IconButton(
          color: Colors.deepPurple,
          icon: Icon(MdiIcons.sigma),
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      content: Builder(
                        builder: (context) {
                          double total = 0;
                          try {
                            total += txnProvider.allTxns
                                .where((txn) =>
                                    selected.contains(txn.id) &&
                                    txn.credit != null)
                                .map((e) => e.credit)
                                .reduce((a, b) => a + b);
                            total -= txnProvider.allTxns
                                .where((txn) =>
                                    selected.contains(txn.id) &&
                                    txn.debit != null)
                                .map((e) => e.debit)
                                .reduce((a, b) => a + b);
                          } on StateError {}
                          return Container(
                            height: MediaQuery.of(context).size.height / 5,
                            width: MediaQuery.of(context).size.width / 5,
                            child: Center(
                              child: Text(
                                total.toStringAsFixed(0),
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 50,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ));
          },
        ),
        IconButton(
          color: Colors.redAccent,
          icon: Icon(Icons.delete_forever),
          onPressed: () {
            repo.deleteTxn(selected);
            selected.clear();
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text('Transaction(s) deleted.'),
              ),
            );
          },
        ),
        IconButton(
          color: kPrimaryColor,
          icon: Icon(Icons.exit_to_app),
          onPressed: () {
            widget.onLogout(context);
            repo.clearDB();
          },
        ),
      ],
    );
  }
}

class AccountSummaryPage extends StatelessWidget {
  final int currentIndex;
  final FineCashRepository repo;
  AccountSummaryPage({Key key, this.currentIndex, this.repo}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    TxnProvider txnProvider = Provider.of<TxnProvider>(context);
    FilterProvider filter = Provider.of<FilterProvider>(context);
    return Column(
      children: <Widget>[
        // SearchBox(onChanged: (value) {}),
        if (currentIndex == 1 && txnProvider.getSubAccountList.length > 1)
          SubAccountsList(
            categories: txnProvider.getSubAccountList.toList(),
            onPressed: (index) {
              if (txnProvider.getSubAccountList.elementAt(index) == 'ALL')
                filter.subAcctFilter = [];
              else
                filter.subAcctFilter = [
                  txnProvider.getSubAccountList.elementAt(index)
                ];
            },
          )
        else
          SizedBox(height: 50),
        Expanded(
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 70),
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
              _buildAccountSummaryDetails(currentIndex, context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSummaryDetails(index, context) {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AccountSummaryCard(
              itemIndex: 0,
              accountSummary: AccountSummary('0', '0', '0'),
              press: () {},
            ),
            SizedBox(
              height: 30,
            ),
            _getPageDetails(index, context),
          ],
        ),
      ),
    );
  }

  Widget _getPageDetails(index, context) {
    switch (index) {
      case 0:
        return _buildAccounts(context);
        break;
      case 1:
        return _buildTxnDetails(context);
        break;
      case 2:
        return _buildReports(context);
        break;
      case 3:
      default:
        return Container();
    }
  }

  Widget _buildAccounts(context) {
    TxnProvider txnProvider = Provider.of<TxnProvider>(context);
    FilterProvider filter = Provider.of<FilterProvider>(context);
    MetaDataProvider metaDataProvider = Provider.of<MetaDataProvider>(context);
    ScreenScaler scaler = ScreenScaler()..init(context);
    return SizedBox(
      height: Platform.isWindows
          ? MediaQuery.of(context).size.height * .62
          : scaler.getHeight(55),
      child: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 30.0,
          children: <Widget>[
            if (txnProvider.accountList.isEmpty)
              Center(
                child: Text('Press \'+\' to add a new Account'),
              ),
            if (txnProvider.accountList.isNotEmpty)
              ...txnProvider.accountList.map((e) {
                return AccountsCard(
                  icon: getIconGuessFavorMaterial(
                      name: metaDataProvider.getMetaData(e).icon),
                  color: Color(metaDataProvider.getMetaData(e).color),
                  title: e.toUpperCase(),
                  onPressed: () {
                    filter.acctFilter = [];
                    filter.acctFilter = [e];
                    changePage(1);
                  },
                );
              }).toList()
          ],
        ),
      ),
    );
  }

  Widget _buildTxnDetails(context) {
    TxnProvider txnProvider = Provider.of<TxnProvider>(context);
    FilterProvider filter = Provider.of<FilterProvider>(context);
    ScreenScaler scaler = ScreenScaler()..init(context);
    List<Transaction> getAllTxns() {
      var allTxns = txnProvider.allTxns;
      if (filter.acctFilter.isNotEmpty && filter.subAcctFilter.isEmpty) {
        return allTxns.where((element) {
          return filter.acctFilter.contains(element.accountHead.toUpperCase());
        }).toList();
      }
      if (filter.acctFilter.isEmpty && filter.subAcctFilter.isNotEmpty)
        return allTxns.where((element) {
          return filter.subAcctFilter
              .contains(element.subAccountHead.toUpperCase());
        }).toList();
      if (filter.acctFilter.isNotEmpty && filter.subAcctFilter.isNotEmpty)
        return allTxns.where((element) {
          return filter.acctFilter
                  .contains(element.accountHead.toUpperCase()) &&
              filter.subAcctFilter
                  .contains(element.subAccountHead.toUpperCase());
        }).toList();
      return allTxns;
    }

    return SizedBox(
      height: Platform.isWindows
          ? MediaQuery.of(context).size.height * .62
          : scaler.getHeight(55),
      child: txnProvider.allTxns.isEmpty
          ? Center(
              child: Text('Press \'+\' to add new Transaction'),
            )
          : ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: getAllTxns().length,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) => TransactionCard(
                txn: getAllTxns()[index],
                onSelected: () {
                  selected.add(getAllTxns()[index].id);
                },
                onDeselected: () {
                  selected.remove(getAllTxns()[index].id);
                },
                press: () {
                  slideDialog.showSlideDialog(
                    context: context,
                    child: ProcessTransaction(
                      context: context,
                      repo: repo,
                      txnProvider: txnProvider,
                      txnIndex: index,
                    ),
                    barrierColor: Colors.grey,
                    pillColor: Colors.amberAccent,
                    backgroundColor: Colors.white,
                  );
                },
              ),
            ),
    );
  }

  Widget _buildReports(context) {
    final FocusNode accountText = FocusNode();
    final FocusNode subAccountText = FocusNode();
    TxnProvider txnProvider = Provider.of<TxnProvider>(context);
    ScreenScaler scaler = ScreenScaler()..init(context);
    return BlocProvider(
      create: (_) => _ReportFormBloc(txnProvider),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: SizedBox(
          width: 400,
          height: Platform.isWindows
              ? MediaQuery.of(context).size.height * .62
              : scaler.getHeight(55),
          child: Builder(
            builder: (context) {
              final formBloc = BlocProvider.of<_ReportFormBloc>(context);
              return FormBlocListener<_ReportFormBloc, String, String>(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextFieldBlocBuilder(
                        autofocus: Platform.isWindows ? true : false,
                        focusNode: accountText,
                        nextFocusNode: subAccountText,
                        suggestionsAnimationDuration:
                            const Duration(milliseconds: 0),
                        maxLength: 10,
                        hideOnEmptySuggestions: true,
                        hideOnLoadingSuggestions: true,
                        showSuggestionsWhenIsEmpty: false,
                        clearTextIcon: Icon(Icons.clear),
                        textFieldBloc: formBloc.accountText,
                        decoration: InputDecoration(
                          labelText: 'Account',
                          helperText: 'Account Head Name',
                          prefixIcon: Icon(Icons.text_fields),
                        ),
                      ),
                      TextFieldBlocBuilder(
                        focusNode: subAccountText,
                        suggestionsAnimationDuration:
                            const Duration(milliseconds: 0),
                        maxLength: 10,
                        hideOnEmptySuggestions: true,
                        hideOnLoadingSuggestions: true,
                        showSuggestionsWhenIsEmpty: false,
                        clearTextIcon: Icon(Icons.clear),
                        textFieldBloc: formBloc.subAccountText,
                        decoration: InputDecoration(
                          labelText: 'Sub Account',
                          helperText: 'Sub Account Name',
                          prefixIcon: Icon(Icons.text_fields),
                        ),
                      ),
                      DateTimeFieldBlocBuilder(
                        clearIcon: Icon(Icons.clear),
                        dateTimeFieldBloc: formBloc.startDate,
                        canSelectTime: false,
                        format: DateFormat('dd-MM-yyyy'),
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          prefixIcon:
                              Icon(Icons.date_range, color: Colors.blue),
                          helperText: 'Report Start Date',
                        ),
                      ),
                      DateTimeFieldBlocBuilder(
                        clearIcon: Icon(Icons.clear),
                        dateTimeFieldBloc: formBloc.endDate,
                        canSelectTime: false,
                        format: DateFormat('dd-MM-yyyy'),
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          prefixIcon:
                              Icon(Icons.date_range, color: Colors.blue),
                          helperText: 'Report End Date',
                        ),
                      ),
                      _buildLoginBtn(formBloc.submit),
                      Container(),
                      Container(),
                      Container(),
                      Container(),
                      Container(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ReportFormBloc extends FormBloc<String, String> {
  InputFieldBloc<DateTime, Object> startDate;
  InputFieldBloc<DateTime, Object> endDate;
  TextFieldBloc accountText;
  TextFieldBloc subAccountText;
  final TxnProvider txnProvider;

  _ReportFormBloc(this.txnProvider) {
    accountText = TextFieldBloc(
      suggestions: (pattern) => Future.value(txnProvider.accountList
          .where((element) =>
              element.toUpperCase().contains(pattern.toUpperCase()))
          .toList()),
    );
    subAccountText = TextFieldBloc(
      suggestions: (pattern) {
        var subAccountList = txnProvider.subAccountList;
        subAccountList.remove('ALL');
        return Future.value(subAccountList
            .where((element) =>
                element.toUpperCase().contains(pattern.toUpperCase()))
            .toList());
      },
    );
    startDate = InputFieldBloc<DateTime, Object>(initialValue: DateTime(1900));
    endDate = InputFieldBloc<DateTime, Object>(initialValue: DateTime.now());
    addFieldBlocs(
        fieldBlocs: [accountText, subAccountText, startDate, endDate]);
  }

  @override
  void onSubmitting() {
    var isError = false;
    if (startDate == null || startDate.value == null) {
      startDate.addError('Start Date is required');
      isError = true;
    }
    if (endDate == null || endDate.value == null) {
      endDate.addError('End Date is required');
      isError = true;
    }

    if (!isError && startDate.value != null && endDate.value != null) {
      if (startDate.value.isAfter(endDate.value))
        startDate.addError('Start Date cannot be greater than End Date');
      if (endDate.value.isBefore(startDate.value))
        endDate.addError('End Date cannot be less than Start Date');
    }
    if (accountText.value != null &&
        accountText.value.isNotEmpty &&
        txnProvider.allTxns.firstWhere(
                (e) =>
                    e.accountHead.toUpperCase() ==
                    accountText.value.toUpperCase(),
                orElse: () => null) ==
            null) {
      accountText.addError('Account not found');
      isError = true;
    }
    if (subAccountText.value != null &&
        subAccountText.value.isNotEmpty &&
        txnProvider.allTxns.firstWhere(
                (e) =>
                    e.subAccountHead.toUpperCase() ==
                    subAccountText.value.toUpperCase(),
                orElse: () => null) ==
            null) {
      subAccountText.addError('Sub Account not found');
      isError = true;
    }

    if (isError)
      emitFailure();
    else {
      _generateReport();
      emitSuccess(canSubmitAgain: true);
    }
  }

  void _generateReport() {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Report'];
      List<String> headings = [
        "DATE",
        "ACCOUNT HEAD",
        "SUB ACCOUNT HEAD",
        "DESCRIPTION",
        "CREDIT",
        "DEBIT",
      ];
      CellStyle style =
          CellStyle(fontFamily: getFontFamily(FontFamily.Calibri), bold: true);
      for (var i = 0; i < headings.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i))
            .cellStyle = style;
      }
      sheet.insertRowIterables(headings, 0);
      var filteredTxns = txnProvider.allTxns.where(
        (e) =>
            ((e.createdDTime.year == startDate.value.year &&
                        e.createdDTime.month == startDate.value.month &&
                        e.createdDTime.day == startDate.value.day ||
                    e.createdDTime.isAfter(startDate.value)) ||
                (e.createdDTime.year == endDate.value.year &&
                        e.createdDTime.month == endDate.value.month &&
                        e.createdDTime.day == endDate.value.day ||
                    e.createdDTime.isBefore(startDate.value))) &&
            ((accountText.value != null && accountText.value.isNotEmpty)
                ? e.accountHead.toUpperCase() == accountText.value.toUpperCase()
                : true) &&
            ((subAccountText.value != null && subAccountText.value.isNotEmpty)
                ? e.subAccountHead.toUpperCase() ==
                    subAccountText.value.toUpperCase()
                : true),
      );
      List<List<String>> reportList = filteredTxns
          .map((e) => [
                DateFormat('dd-MM-yyyy  hh:mm a').format(e.createdDTime),
                e.accountHead.toUpperCase(),
                e.subAccountHead.toUpperCase(),
                e.desc,
                e.credit != null ? e.credit.toStringAsFixed(2) : '',
                e.debit != null ? e.debit.toStringAsFixed(2) : '',
              ])
          .toList();
      for (var i = 0; i < reportList.length; i++) {
        sheet.insertRowIterables(reportList.elementAt(i), i + 1);
      }
      double credit = filteredTxns
          .map((e) => e.credit != null ? e.credit : 0)
          .reduce((a, b) => a + b);
      var debit = filteredTxns
          .map((e) => e.debit != null ? e.debit : 0)
          .reduce((a, b) => a + b);
      sheet.insertRowIterables([
        ' ',
        '',
        '',
        '',
        credit,
        debit,
        (credit - debit).toStringAsFixed(2),
      ], reportList.length + 2);
      sheet
          .cell(CellIndex.indexByColumnRow(
              rowIndex: reportList.length + 1, columnIndex: 6))
          .cellStyle = style;
      excel.setDefaultSheet('Report');
      excel.encode().then((value) => File(p.join(_localFile))
        ..createSync(recursive: true)
        ..writeAsBytesSync(value));
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Report generated successfully ' +
                (Platform.isWindows
                    ? 'Documents/FineCash/Reports'
                    : 'in Downloads/FineCash/Reports.'),
          ),
        ),
      );
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Failed to generate Report.'),
        ),
      );
    }
  }

  String get _localFile {
    String reportPath = '/storage/emulated/0/Download';
    if (Platform.isWindows) {
      var dir = new Directory('$reportPath\\FineCash\\Reports');
      if (dir.existsSync())
        return '$reportPath\\FineCash\\Reports\\' + _getFileName();
      else {
        new Directory('$reportPath\\FineCash\\Reports').createSync();
        return '$reportPath\\FineCash\\Reports\\' + _getFileName();
      }
    } else {
      var rootDir = new Directory('$reportPath/FineCash');
      if (!rootDir.existsSync())
        new Directory('$reportPath/FineCash').createSync();
      var dir = new Directory('$reportPath/FineCash/Reports');
      if (dir.existsSync())
        return '$reportPath/FineCash/Reports/' + _getFileName();
      else {
        new Directory('$reportPath/FineCash/Reports').createSync();
        return '$reportPath/FineCash/Reports/' + _getFileName();
      }
    }
  }

  String _getFileName() {
    String fileName = 'FineCashReport';
    if (accountText.value != null && accountText.value.isNotEmpty)
      fileName += '_' + accountText.value.toUpperCase();
    if (subAccountText.value != null && subAccountText.value.isNotEmpty)
      fileName += '_' + subAccountText.value.toUpperCase();
    fileName += '_' +
        DateFormat('ddMMyyyy').format(startDate.value) +
        '_' +
        DateFormat('ddMMyyyy').format(endDate.value) +
        '.xlsx';
    return fileName;
  }
}

Widget _buildLoginBtn(Function submit) {
  return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: _generateReportButton(submit));
}

RaisedButton _generateReportButton(submit) {
  return RaisedButton(
    elevation: 5.0,
    onPressed: submit,
    padding: EdgeInsets.all(12.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    color: Colors.white,
    child: Text(
      'Generate Report',
      style: TextStyle(
        color: Color(0xFF527DAA),
        letterSpacing: 1.5,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        fontFamily: 'OpenSans',
      ),
    ),
  );
}
