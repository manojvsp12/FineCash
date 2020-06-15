import 'package:fine_cash/constants/constants.dart';
import 'package:fine_cash/database/fine_cash_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    Key key,
    this.txn,
    this.press,
  }) : super(key: key);

  final Transaction txn;
  final Function press;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var getTxnColor = txn.credit == null ? Colors.redAccent : Colors.green;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      child: InkWell(
        onTap: () {
          print('pressed');
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              // width: MediaQuery.of(context).size.width / 3,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: getTxnColor,
                boxShadow: [kDefaultShadow],
              ),
              child: Container(
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
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
                height: 160,
                width: 300,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: '₹',
                      style: TextStyle(
                          color: getTxnColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                      children: [
                        TextSpan(
                            text: txn.credit == null
                                ? '${txn.debit}'
                                : '${txn.credit}',
                            style: TextStyle(
                                color: getTxnColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 40)),
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
                height: 136,
                // our image take 200 width, thats why we set out total width - 200
                width: size.width,
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
                              fontSize: 18),
                          children: [
                            TextSpan(
                                text: '|',
                                style: TextStyle(color: getTxnColor)),
                            TextSpan(
                              text:
                                  'Sub Account: ${txn.subAccountHead.toUpperCase()}',
                              style: TextStyle(
                                  color: kTextLightColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16),
                            ),
                            TextSpan(text: '\n'),
                            if (txn.desc.isNotEmpty)
                              TextSpan(
                                  text: 'Desc: ',
                                  style: TextStyle(
                                      color: kTextLightColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                            if (txn.desc.isNotEmpty)
                              TextSpan(
                                  text: txn.desc,
                                  style: TextStyle(
                                      color: kTextLightColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
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
  }
}
