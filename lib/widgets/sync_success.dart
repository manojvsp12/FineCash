import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';

import 'app_shell.dart';

class SyncSuccess extends StatefulWidget {
  const SyncSuccess({Key key}) : super(key: key);

  @override
  _SyncSuccessState createState() =>
      _SyncSuccessState();
}

class _SyncSuccessState extends State<SyncSuccess>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(seconds: 200), vsync: this);
    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.addListener(() {
      setState(() {});
    });
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: '',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: (animation.value * 0.6) * 360.0,
                    child: Blob.fromID(
                      size: 190,
                      id: ['6-8-34659'],
                      styles: BlobStyles(
                        color: Colors.green.withOpacity(0.2),
                        fillType: BlobFillType.fill,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: animation.value * 360.0,
                    child: Blob.fromID(
                      size: 200,
                      id: ['6-8-6090'],
                      styles: BlobStyles(
                        color: Colors.lightGreen,
                        fillType: BlobFillType.stroke,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: (animation.value * 0.4) * 360.0,
                    child: Blob.fromID(
                      size: 200,
                      id: ['6-8-115566'],
                      styles: BlobStyles(
                        color: Colors.green,
                        fillType: BlobFillType.stroke,
                      ),
                    ),
                  ),
                  Center(
                      child: Text(
                    "Sync Success",
                    style: TextStyle(
                      fontFamily: 'Ropa',
                      fontSize: 20,
                      color: Colors.green,
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
