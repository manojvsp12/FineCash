import 'package:fine_cash/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';

class SubAccountsList extends StatefulWidget {
  final List categories;
  final Function onPressed;
  final int selectedIndex;

  const SubAccountsList(
      {Key key, this.categories, this.onPressed, this.selectedIndex})
      : super(key: key);

  @override
  _SubAccountsListState createState() => _SubAccountsListState();
}

class _SubAccountsListState extends State<SubAccountsList> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = new ScreenScaler()..init(context);
    if (widget.selectedIndex != null)
      setState(() => selectedIndex = widget.selectedIndex);
    return Column(
      children: [
        Container(
          // padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 2.5),
          margin: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
          height: scaler.getHeight(1.3),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.categories.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                  widget.onPressed(index);
                });
              },
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  left: kDefaultPadding,
                  right: index == widget.categories.length - 1
                      ? kDefaultPadding
                      : 0,
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
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
                      fontSize: scaler.getHeight(1)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
