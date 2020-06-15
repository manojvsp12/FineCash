import 'dart:io';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
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
import 'package:icons_helper/icons_helper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

ValueNotifier<int> currentIndex = ValueNotifier(0);
final Set<int> selected = {};

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
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var titles = ['Accounts', 'Transactions', 'Report', 'Sync'];
  @override
  void initState() {
    super.initState();
    if (txnProvider == null)
      txnProvider = Provider.of<TxnProvider>(context, listen: false);
    if (metaDataProvider == null)
      metaDataProvider = Provider.of<MetaDataProvider>(context, listen: false);
    if (repo == null) repo = FineCashRepository(txnProvider, metaDataProvider);
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
        print(index);
        filter.acctFilter = [];
        filter.subAcctFilter = [];
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
                          } on StateError {
                            // print(e);
                          }
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
    List<String> getSubAcctList() {
      var subAccountList = txnProvider.getSubAccountList;
      // if (filter.acctFilter.isNotEmpty && filter.subAcctFilter.isEmpty) {
      //   subAccountList = {'ALL'};
      //   subAccountList.addAll(txnProvider.getAllTxns
      //       .where((element) =>
      //           filter.acctFilter.contains(element.accountHead.toUpperCase()))
      //       .map((e) => e.subAccountHead.toUpperCase())
      //       .toSet());
      // }
      // if (filter.acctFilter.isEmpty && filter.subAcctFilter.isNotEmpty) {
      //   subAccountList = {'ALL'};
      //   subAccountList.addAll(txnProvider.getAllTxns
      //       .where((element) => filter.subAcctFilter
      //           .contains(element.subAccountHead.toUpperCase()))
      //       .map((e) => e.subAccountHead.toUpperCase())
      //       .toSet());
      // }
      // if (filter.acctFilter.isNotEmpty && filter.subAcctFilter.isNotEmpty) {
      //   subAccountList = {'ALL'};
      //   subAccountList.addAll(txnProvider.getAllTxns
      //       .where((element) =>
      //           filter.acctFilter.contains(element.accountHead.toUpperCase()) &&
      //           filter.subAcctFilter
      //               .contains(element.subAccountHead.toUpperCase()))
      //       .map((e) => e.subAccountHead.toUpperCase())
      //       .toSet());
      // }
      return subAccountList.toList();
    }

    return Column(
      children: <Widget>[
        // SearchBox(onChanged: (value) {}),
        if (currentIndex == 1 && getSubAcctList().length > 1)
          SubAccountsList(
            categories: getSubAcctList(),
            onPressed: (index) {
              if (getSubAcctList()[index] == 'ALL')
                filter.subAcctFilter = [];
              else
                filter.subAcctFilter = [getSubAcctList()[index]];
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
      case 3:
      default:
        return Container();
    }
  }

  Widget _buildAccounts(context) {
    TxnProvider txnProvider = Provider.of<TxnProvider>(context);
    FilterProvider filter = Provider.of<FilterProvider>(context);
    MetaDataProvider metaDataProvider = Provider.of<MetaDataProvider>(context);
    return Wrap(
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
    );
  }

  Widget _buildTxnDetails(context) {
    TxnProvider txnProvider = Provider.of<TxnProvider>(context);
    FilterProvider filter = Provider.of<FilterProvider>(context);
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
          : MediaQuery.of(context).size.height * .59,
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
                  print('selected');
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
}
