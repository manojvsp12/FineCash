import 'package:fine_cash/constants/constants.dart';
import 'package:flutter/material.dart';

class SubAccountsList extends StatefulWidget {
  final List categories;

  const SubAccountsList({Key key, this.categories}) : super(key: key);

  @override
  _SubAccountsListState createState() => _SubAccountsListState();
}

class _SubAccountsListState extends State<SubAccountsList> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 2.5),
          margin: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.categories.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  left: kDefaultPadding,
                  right:
                      index == widget.categories.length - 1 ? kDefaultPadding : 0,
                ),
                padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                decoration: BoxDecoration(
                  color: index == selectedIndex
                      ? Colors.white.withOpacity(0.4)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.categories[index],
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
