import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';

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
    ScreenScaler scaler = ScreenScaler()..init(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: Container(
        height: scaler.getHeight(10),
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
              size: scaler.getHeight(5),
              color: color,
            ),
            SizedBox(
              height: scaler.getHeight(1),
            ),
            AutoSizeText(
              title,
              maxLines: 1,
              minFontSize: 8,
              style: Theme.of(context).textTheme.headline6.copyWith(
                    fontSize: scaler.getHeight(1),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
