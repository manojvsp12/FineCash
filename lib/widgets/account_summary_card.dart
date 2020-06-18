import 'package:fine_cash/constants/constants.dart';
import 'package:fine_cash/providers/filter_provider.dart';
import 'package:fine_cash/providers/txn_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:provider/provider.dart';

class AccountSummaryCard extends StatelessWidget {
  const AccountSummaryCard({
    Key key,
    this.itemIndex,
    this.press,
  }) : super(key: key);

  final int itemIndex;
  final Function press;

  @override
  Widget build(BuildContext context) {
    TxnProvider txnProvider = Provider.of<TxnProvider>(context);
    FilterProvider filterProvider = Provider.of<FilterProvider>(context);
    ScreenScaler scaler = new ScreenScaler()..init(context);
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 100,
      ),
      height: 160,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            height: 136,
            child: Container(
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Positioned.fill(
            bottom: scaler.getHeight(3),
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: _acctSummaryTitle(filterProvider),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontSize: 14,
                      ),
                  children: [
                    TextSpan(
                      text: '\n₹' +
                          getBalance(txnProvider, filterProvider)
                              .toStringAsFixed(2),
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: scaler.getHeight(6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: scaler.getWidth(10)),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'CREDIT',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontSize: 14,
                            ),
                        children: [
                          TextSpan(
                            text: '\n₹' +
                                getCredit(txnProvider, filterProvider)
                                    .toStringAsFixed(2),
                            style:
                                Theme.of(context).textTheme.bodyText1.copyWith(
                                      fontSize: 20,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: scaler.getWidth(12)),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'DEBIT',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontSize: 14,
                            ),
                        children: [
                          TextSpan(
                            text: '\n₹' +
                                getDebit(txnProvider, filterProvider)
                                    .toStringAsFixed(2),
                            style:
                                Theme.of(context).textTheme.bodyText1.copyWith(
                                      fontSize: 20,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            top: scaler.getHeight(1),
            left: scaler.getWidth(1),
            right: scaler.getWidth(2),
            child: Divider(
              color: Colors.red,
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }

  String _acctSummaryTitle(FilterProvider filterProvider) {
    if (filterProvider.acctFilter.isNotEmpty &&
        filterProvider.subAcctFilter.isEmpty)
      return filterProvider.acctFilter.first +
          ' - ' +
          '${DateFormat.MMMM().format(DateTime.now()).toUpperCase()} BALANCE';

    if (filterProvider.acctFilter.isEmpty &&
        filterProvider.subAcctFilter.isNotEmpty)
      return filterProvider.subAcctFilter.first +
          ' - ' +
          '${DateFormat.MMMM().format(DateTime.now()).toUpperCase()} BALANCE';

    if (filterProvider.acctFilter.isNotEmpty &&
        filterProvider.subAcctFilter.isNotEmpty)
      return filterProvider.acctFilter.first +
          ' - ' +
          filterProvider.subAcctFilter.first +
          ' - ' +
          '${DateFormat.MMMM().format(DateTime.now()).toUpperCase()} BALANCE';

    return '${DateFormat.MMMM().format(DateTime.now()).toUpperCase()} BALANCE';
  }

  double getBalance(TxnProvider txnProvider, FilterProvider filterProvider) {
    return getCredit(txnProvider, filterProvider) -
        getDebit(txnProvider, filterProvider);
  }

  double getCredit(TxnProvider txnProvider, FilterProvider filterProvider) {
    if (filterProvider.acctFilter.isNotEmpty &&
        filterProvider.subAcctFilter.isEmpty) {
      var list = txnProvider.allTxns
          .where((e) =>
              e.credit != null &&
              e.createdDTime.month == DateTime.now().month 
              &&
              filterProvider.acctFilter.contains(e.accountHead.toUpperCase())
              )
          .map((e) => e.credit)
          .toList();
      return list.length > 1
          ? list.reduce((a, b) => a + b)
          : list.length == 1 ? list.first : 0;
    }

    if (filterProvider.acctFilter.isEmpty &&
        filterProvider.subAcctFilter.isNotEmpty) {
      var list = txnProvider.allTxns
          .where((e) =>
              e.credit != null &&
              e.createdDTime.month == DateTime.now().month &&
              filterProvider.subAcctFilter
                  .contains(e.subAccountHead.toUpperCase()))
          .map((e) => e.credit)
          .toList();
      return list.length > 1
          ? list.reduce((a, b) => a + b)
          : list.length == 1 ? list.first : 0;
    }

    if (filterProvider.acctFilter.isNotEmpty &&
        filterProvider.subAcctFilter.isNotEmpty) {
      var list = txnProvider.allTxns
          .where((e) =>
              e.credit != null &&
              e.createdDTime.month == DateTime.now().month &&
              filterProvider.acctFilter.contains(e.accountHead.toUpperCase()) &&
              filterProvider.subAcctFilter
                  .contains(e.subAccountHead.toUpperCase()))
          .map((e) => e.credit)
          .toList();
      return list.length > 1
          ? list.reduce((a, b) => a + b)
          : list.length == 1 ? list.first : 0;
    }

    var list = txnProvider.allTxns
        .where((e) =>
            e.credit != null && e.createdDTime.month == DateTime.now().month)
        .map((e) => e.credit)
        .toList();
    return list.length > 1
        ? list.reduce((a, b) => a + b)
        : list.length == 1 ? list.first : 0;
  }

  double getDebit(TxnProvider txnProvider, FilterProvider filterProvider) {
    if (filterProvider.acctFilter.isNotEmpty &&
        filterProvider.subAcctFilter.isEmpty) {
      var list = txnProvider.allTxns
          .where((e) =>
              e.debit != null &&
              e.createdDTime.month == DateTime.now().month &&
              filterProvider.acctFilter.contains(e.accountHead.toUpperCase()))
          .map((e) => e.debit)
          .toList();
      return list.length > 1
          ? list.reduce((a, b) => a + b)
          : list.length == 1 ? list.first : 0;
    }

    if (filterProvider.acctFilter.isEmpty &&
        filterProvider.subAcctFilter.isNotEmpty) {
      var list = txnProvider.allTxns
          .where((e) =>
              e.debit != null &&
              e.createdDTime.month == DateTime.now().month &&
              filterProvider.subAcctFilter
                  .contains(e.subAccountHead.toUpperCase()))
          .map((e) => e.debit)
          .toList();
      return list.length > 1
          ? list.reduce((a, b) => a + b)
          : list.length == 1 ? list.first : 0;
    }

    if (filterProvider.acctFilter.isNotEmpty &&
        filterProvider.subAcctFilter.isNotEmpty) {
      var list = txnProvider.allTxns
          .where((e) =>
              e.debit != null &&
              e.createdDTime.month == DateTime.now().month &&
              filterProvider.acctFilter.contains(e.accountHead.toUpperCase()) &&
              filterProvider.subAcctFilter
                  .contains(e.subAccountHead.toUpperCase()))
          .map((e) => e.debit)
          .toList();
      return list.length > 1
          ? list.reduce((a, b) => a + b)
          : list.length == 1 ? list.first : 0;
    }

    var list = txnProvider.allTxns
        .where((e) =>
            e.debit != null && e.createdDTime.month == DateTime.now().month)
        .map((e) => e.debit)
        .toList();
    return list.length > 1
        ? list.reduce((a, b) => a + b)
        : list.length == 1 ? list.first : 0;
  }
}
