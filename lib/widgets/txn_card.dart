import 'dart:io';

import 'package:fine_cash/constants/constants.dart';
import 'package:fine_cash/database/fine_cash_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';

class TransactionCard extends StatelessWidget {
  TransactionCard({
    Key key,
    this.txn,
    this.press,
    this.isSelected,
    this.onSelected,
    this.onDeselected,
    this.isSync,
  }) : super(key: key);

  final Transaction txn;
  final Function press;
  final ValueNotifier isSelected;
  final Function onSelected;
  final Function onDeselected;
  final ValueNotifier color = ValueNotifier(Colors.white);
  bool selected = false;
  final bool isSync;

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    var getTxnColor = txn.credit == null ? Colors.redAccent : Colors.green;
    return ValueListenableBuilder(
      valueListenable: isSelected,
      builder: (context, value, child) {
        selected = value;
        if (value) {
          color.value = Colors.grey.shade900;
          onSelected();
        } else {
          color.value = Colors.white;
          onDeselected();
        }
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: kDefaultPadding,
            vertical: kDefaultPadding / 3,
          ),
          child: InkWell(
            onDoubleTap: isSync ? () {} : _processSelection,
            onLongPress: isSync ? () {} : _processSelection,
            onTap: isSync ? () {} : press,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                ValueListenableBuilder(
                  valueListenable: color,
                  builder: (context, value, child) => Container(
                    // width: MediaQuery.of(context).size.width / 3,
                    height: scaler.getHeight(9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: getTxnColor,
                      boxShadow: [kDefaultShadow],
                    ),
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: value,
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  // right: MediaQuery.of(context).size.width / 3,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    // height: 160,
                    width: Platform.isWindows ? 300 : 200,
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          text: '₹',
                          style: TextStyle(
                              color: getTxnColor,
                              fontWeight: FontWeight.bold,
                              fontSize: Platform.isWindows ? 25 : scaler.getWidth(3)),
                          children: [
                            TextSpan(
                                text: txn.credit == null
                                    ? '${txn.debit}'
                                    : '${txn.credit}',
                                style: TextStyle(
                                    color: getTxnColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Platform.isWindows ? 40 : scaler.getWidth(4))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  // left: MediaQuery.of(context).size.width / 3.19,
                  left: 0,
                  child: SizedBox(
                    height: scaler.getHeight(10),
                    width: scaler.getWidth(80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: kDefaultPadding),
                          child: RichText(
                            text: TextSpan(
                              text: 'Account: ${txn.accountHead.toUpperCase()}',
                              style: TextStyle(
                                  color: kTextLightColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: Platform.isWindows ? 18 : scaler.getWidth(2)),
                              children: [
                                TextSpan(
                                    text: Platform.isWindows ? '|' : '\n',
                                    style: TextStyle(color: getTxnColor)),
                                TextSpan(
                                  text:
                                      'Sub Account: ${txn.subAccountHead.toUpperCase()}',
                                  style: TextStyle(
                                      color: kTextLightColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: Platform.isWindows ? 16 : scaler.getWidth(1.9)),
                                ),
                                TextSpan(text: '\n'),
                                if (txn.desc.isNotEmpty)
                                  TextSpan(
                                      text: 'Desc: ',
                                      style: TextStyle(
                                          color: kTextLightColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              Platform.isWindows ? 15 : scaler.getWidth(1.8))),
                                if (txn.desc.isNotEmpty)
                                  TextSpan(
                                      text: txn.desc,
                                      style: TextStyle(
                                          color: kTextLightColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              Platform.isWindows ? 15 : scaler.getWidth(1.8))),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: kDefaultPadding * 1.5, // 30 padding
                            vertical: kDefaultPadding / 4, // 5 top and bottom
                          ),
                          decoration: BoxDecoration(
                            color: kSecondaryColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(22),
                              topRight: Radius.circular(22),
                            ),
                          ),
                          child: Text(
                            DateFormat.yMMMMd().format(txn.createdDTime),
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _processSelection() {
    selected = !selected;
    if (selected) {
      color.value = Colors.grey.shade900;
      onSelected();
    } else {
      color.value = Colors.white;
      onDeselected();
    }
  }
}
