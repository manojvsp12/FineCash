import 'package:fine_cash/constants/constants.dart';
import 'package:fine_cash/database/fine_cash_repo.dart';
import 'package:fine_cash/models/account_summary.dart';
import 'package:flutter/material.dart';

class AccountSummaryCard extends StatelessWidget {
  const AccountSummaryCard({
    Key key,
    this.itemIndex,
    this.accountSummary,
    this.press,
  }) : super(key: key);

  final int itemIndex;
  final AccountSummary accountSummary;
  final Function press;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
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
          Positioned(
            top: 60,
            right: 50,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
              height: 160,
              width: 200,
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'This Month'.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontSize: 15,
                          ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding + 20),
                      child: FittedBox(
                        child: Text(
                          '₹10000',
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontSize: 30,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: SizedBox(
              height: 136,
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Spacer(),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    child: Text(
                      'YOUR BALANCE',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontSize: 15,
                          ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    child: FittedBox(
                      child: Text(
                        '₹10000',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontSize: 30,
                            ),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
