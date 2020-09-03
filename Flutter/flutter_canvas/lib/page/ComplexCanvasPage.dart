import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ComplexCanvasPage extends StatefulWidget {
  ComplexCanvasPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ComplexCanvasPage createState() => _ComplexCanvasPage();
}

class _ComplexCanvasPage extends State<ComplexCanvasPage> {
  @override
  Widget build(BuildContext context) {
    double width = window.physicalSize.width / window.devicePixelRatio;
    double height = window.physicalSize.height / window.devicePixelRatio -
        window.padding.top / window.devicePixelRatio;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: CustomPaint(
            painter: _SingleCanvasPainter(), size: Size(width, height)),
      ),
    );
  }
}

class _SingleCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true //抗锯齿
      ..style = PaintingStyle.stroke //画笔样式
      ..color = Colors.red //画笔颜色
      ..strokeWidth = 2; //画笔宽度

    List<Offset> heartPoints1 = heart1(origin: Offset(size.width / 2, 100));
    canvas.drawPoints(PointMode.polygon, heartPoints1, paint);

    List<Offset> heartPoints2 = heart2(origin: Offset(size.width / 2, 200));
    canvas.drawPoints(PointMode.polygon, heartPoints2, paint);

    // fractal tree 分形树
  }

  // 心形公式1：{x = 16sin^3(t), y = 13cos(t) - 5cos(2t) - 2cos(3t) - cos(4t)} t = [0, 2π]
  List<Offset> heart1(
      {Offset origin = Offset.zero,
      double scale = 15.0,
      double deviant = 0.05}) {
    List<Offset> points = List();

    double _scale = 15.0 / scale;

    for (var t = 0.0; t <= pi * 2; t += deviant) {
      double x = 16 * pow(sin(t), 3);
      double y = 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t);
      points.add(Offset(x * _scale + origin.dx, y * _scale + origin.dy));
    }

    return points;
  }

  // 心形公式2：x^2 + (y - (x^2)^(1/3))^2 = 1, x = [-1, 1]
  List<Offset> heart2(
      {Offset origin = Offset.zero,
      double scale = 15.0,
      double deviant = 0.05}) {
    List<Offset> points = List();

    // 计算上半部分点位置
    // (x^(2/3) - y)^2 + x^2 = 1
    for (double x = -1.0; x <= 1.0; x += deviant) {
      if (x == -1.0 || x == 1.0) {
        points.add(Offset(x * scale + origin.dx, 1.0 * scale + origin.dy));
      } else if (x == 0.0) {
        points.add(Offset(x * scale + origin.dx, 1.0 * scale + origin.dy));
      } else {
        double y = pow(x.abs(), 2.0 / 3) - sqrt(1 - x * x);
        points.add(Offset(x * scale + origin.dx, y * scale + origin.dy));
      }
    }

    // 计算下半部分点位置
    // (y - x^(2/3))^2 + x^2 = 1
    for (double x = 1.0; x >= -1.0; x -= deviant) {
      if (x == -1.0 || x == 1.0) {
        points.add(Offset(x * scale + origin.dx, 1.0 * scale + origin.dy));
      } else if (x == 0.0) {
        points.add(Offset(x * scale + origin.dx, -1.0 * scale + origin.dy));
      } else {
        double y = sqrt(1 - x * x) + pow(x.abs(), 2.0 / 3);
        points.add(Offset(x * scale + origin.dx, y * scale + origin.dy));
      }
    }

    // 修复double精度问题导致遗漏起点问题
    if (points.last.dx != (-1.0 * scale + origin.dx)) {
      points.add(Offset(-1.0 * scale + origin.dx, 1.0 * scale + origin.dy));
    }

    return points;
  }

  //在实际场景中正确利用此回调可以避免重绘开销，本示例我们简单的返回true
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
