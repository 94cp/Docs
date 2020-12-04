import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_canvas/widget/FractalTree.dart';
import 'package:flutter_canvas/widget/Heart.dart';

class HeartTreeCanvasPage extends StatefulWidget {
  HeartTreeCanvasPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HeartTreeCanvasPage createState() => _HeartTreeCanvasPage();
}

class _HeartTreeCanvasPage extends State<HeartTreeCanvasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: ConstrainedBox(
          constraints: BoxConstraints.tight(Size(320, 320)),
          child: Stack(
            children: [
              FractalTree1(
                size: Size(320, 320),
                strokeWidth: 3,
                colors: [
                  Color.fromRGBO(35, 31, 32, 1.0),
                  Color.fromRGBO(35, 31, 32, 1.0)
                ],
                depth: 4,
                length: 125,
              ),
              Transform.rotate(
                angle: pi,
                child: Stack(
                  children: createHearts(),
                ),
              )
            ],
          ),
        )));
  }

  List<Widget> createHearts() {
    List<Widget> children = [];

    for (var i = 0; i < 500; i++) {
      double x =
          Random().nextDouble() * (Random().nextBool() ? 1.0 : -1.0) * 130;
      double y =
          Random().nextDouble() * (Random().nextBool() ? 1.0 : -1.0) * 130;
      if (HeartUtil.inHeart(x, y, 100.0)) {
        children.add(Positioned(
          left: x + 150,
          top: y + 180,
          child: Heart(
            angle: Random().nextDouble() * 2 * pi,
            colors: [
              Color.fromRGBO(
                  2255, Random().nextInt(255), Random().nextInt(255), 1.0)
            ],
          ),
        ));
      }
    }

    return children;
  }
}
