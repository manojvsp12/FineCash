import 'dart:convert';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:fine_cash/constants/constants.dart';
import 'package:fine_cash/database/fine_cash_repo.dart';
import 'package:fine_cash/models/account_summary.dart';
import 'package:fine_cash/providers/metadata_provider.dart';
import 'package:fine_cash/providers/txn_provider.dart';
import 'package:fine_cash/widgets/account_summary_card.dart';
import 'package:fine_cash/widgets/process_transaction.dart';
import 'package:fine_cash/widgets/sub_accounts_list.dart';
import 'package:fine_cash/widgets/txn_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

class HomePage extends StatefulWidget {
  final Function onLogout;

  HomePage(this.onLogout, {Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<int> currentIndex = ValueNotifier(0);
  TxnProvider txnProvider;
  MetaDataProvider metaDataProvider;
  FineCashRepository repo;
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

  void changePage(int index) {
    currentIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentIndex,
      builder: (context, index, child) => Scaffold(
        appBar: buildAppBar(context, titles[index]),
        backgroundColor: kPrimaryColor,
        body: AccountSummaryPage(currentIndex: index),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: _buildFloatingActionButton(context),
        bottomNavigationBar: _buildNavBar(index),
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

  BubbleBottomBar _buildNavBar(int index) {
    return BubbleBottomBar(
      backgroundColor: Colors.white,
      opacity: .2,
      currentIndex: index,
      onTap: changePage,
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
        padding: const EdgeInsets.only(left: 50),
        child: Center(
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      ),
      actions: [
        IconButton(
          color: kPrimaryColor,
          icon: Icon(Icons.exit_to_app),
          onPressed: () {
            widget.onLogout(context);
            repo.clearDB();
          },
        )
      ],
    );
  }
}

class AccountSummaryPage extends StatelessWidget {
  final int currentIndex;
  AccountSummaryPage({Key key, this.currentIndex}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var subAccountList = Provider.of<TxnProvider>(context).subAccountList;
    return Column(
      children: <Widget>[
        // SearchBox(onChanged: (value) {}),
        if (currentIndex == 1 && subAccountList.length > 1)
          SubAccountsList(
            categories: subAccountList,
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
              _buildAccountDetails(currentIndex, context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetails(index, context) {
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

Widget _buildTxnDetails(context) {
  TxnProvider txnProvider = Provider.of<TxnProvider>(context);
  return SizedBox(
    height: MediaQuery.of(context).size.height * .62,
    child: txnProvider.allTxns.isEmpty
        ? Center(
            child: Text('Press \'+\' to add new Transaction'),
          )
        : ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: txnProvider.allTxns.length,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) => TransactionCard(
              txn: txnProvider.allTxns[index],
              press: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => DetailsScreen(
                //       product: products[index],
                //     ),
                //   ),
                // );
              },
            ),
          ),
  );
}

Widget _buildAccounts(context) {
  TxnProvider txnProvider = Provider.of<TxnProvider>(context);
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
          var decodedIcon = json.decode(metaDataProvider.getMetaData(e).icon);
          return AccountsCard(
            icon: IconData(decodedIcon['codePoint'],
                fontFamily: decodedIcon['fontFamily']),
            color: Color(metaDataProvider.getMetaData(e).color),
            title: e.toUpperCase(),
            onPressed: () {
              print('pressed');
            },
          );
        }).toList()
    ],
  );
}

class AccountsCard extends StatelessWidget {
  final Function onPressed;
  final IconData icon;
  final String title;
  final Color color;

  const AccountsCard(
      {Key key, this.onPressed, this.icon, this.title, this.color})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width * 0.22,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200],
              blurRadius: 10,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 50,
              color: color,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.headline6.copyWith(
                    fontSize: 15,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
