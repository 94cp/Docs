import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_canvas/widget/FractalTree.dart';
import 'package:flutter_canvas/widget/Heart.dart';

enum ComplexType {
  ComplexTypeHeart1,
  ComplexTypeHeart2,
  ComplexTypeTree1,
  ComplexTypeTree2,
  ComplexTypeTree3,
  ComplexTypeTree4,
  ComplexTypeTree5,
}

class ComplexCanvasPage extends StatefulWidget {
  ComplexCanvasPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ComplexCanvasPage createState() => _ComplexCanvasPage();
}

class _ComplexCanvasPage extends State<ComplexCanvasPage> {
  ComplexType type = ComplexType.ComplexTypeHeart1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Wrap(
          spacing: 8.0, // 主轴(水平)方向间距
          runSpacing: 4.0, // 纵轴（垂直）方向间距
          alignment: WrapAlignment.center, //沿主轴方向居中
          children: <Widget>[
            RaisedButton(
              onPressed: (() =>
                  setState(() => {type = ComplexType.ComplexTypeHeart1})),
              child: Text('心形1'),
            ),
            RaisedButton(
              onPressed: (() =>
                  setState(() => {type = ComplexType.ComplexTypeHeart2})),
              child: Text('心形2'),
            ),
            RaisedButton(
              onPressed: (() =>
                  setState(() => {type = ComplexType.ComplexTypeTree1})),
              child: Text('树形1'),
            ),
            RaisedButton(
              onPressed: (() =>
                  setState(() => {type = ComplexType.ComplexTypeTree2})),
              child: Text('树形2'),
            ),
            RaisedButton(
              onPressed: (() =>
                  setState(() => {type = ComplexType.ComplexTypeTree3})),
              child: Text('树形3'),
            ),
            RaisedButton(
              onPressed: (() =>
                  setState(() => {type = ComplexType.ComplexTypeTree4})),
              child: Text('树形4'),
            ),
            RaisedButton(
              onPressed: (() =>
                  setState(() => {type = ComplexType.ComplexTypeTree5})),
              child: Text('树形5'),
            ),
            Padding(
              padding: EdgeInsets.only(top: 200),
              child: draw(),
            )
          ],
        ));
  }

  Widget draw() {
    switch (type) {
      case ComplexType.ComplexTypeHeart1:
        return Heart(square: 150);
      case ComplexType.ComplexTypeHeart2:
        return Heart(
          square: 150,
          heartStyle: HeartStyle.style2,
        );
      case ComplexType.ComplexTypeTree1:
        return FractalTree1(size: Size(260, 260));
      case ComplexType.ComplexTypeTree2:
        return FractalTree2(size: Size(260, 260));
      case ComplexType.ComplexTypeTree3:
        return FractalTree3(size: Size(260, 260));
      case ComplexType.ComplexTypeTree4:
        return FractalTree4(size: Size(260, 260));
      case ComplexType.ComplexTypeTree5:
        return FractalTree5(size: Size(260, 260));
      default:
        return null;
    }
  }
}
