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

    // List<Offset> heartPoints1 = heart1(origin: Offset(size.width / 2, 100));
    // canvas.drawPoints(PointMode.polygon, heartPoints1, paint);

    // List<Offset> heartPoints2 = heart2(origin: Offset(size.width / 2, 200));
    // canvas.drawPoints(PointMode.polygon, heartPoints2, paint);

    // fractal tree 分形树
    origin = Offset(size.width / 2, size.height);
    // drawTree1(canvas, paint, level, L, a0, 0, 0);

    // drawTree2(canvas, paint, origin.dx, origin.dy, 50.0, 270.0);

    // drawTree3(canvas, paint, origin.dx, origin.dy, 200, -pi / 2);

    // canvas.drawLine(Offset(origin.dx - 50, origin.dy - 50),
    //     Offset(origin.dx - 50, origin.dy - 50 + 120), paint);
    // drawTree4(canvas, paint, origin.dx - 50, origin.dy - 50, 50, -90, 1);

    hoehe = size.height;
    breite = size.width;
    laenge = 4;

    turtle.xpos = breite / 2;
    turtle.ypos = hoehe / 2;
    turtle.alpha = -90;
    turtle.pen = true;

    kopf = Staple();
    last = kopf;
    kopf.vor = null;
    kopf.nach = null;

    for (int z = 0; z < angle; z++) {
      for (var i = 0; i < zeichenkette.length; i++) {
        if (zeichenkette.characters.elementAt(i) == 'F') {
          zeichenkette = zeichenkette.replaceRange(
              i,
              min(i + 1, zeichenkette.length),
              selectFunction(Random().nextDouble()));

          i = i + regel.length;
          continue;
        }
      }
    }

    for (var char in zeichenkette.characters) {
      befehl(char, canvas, paint);
    }
  }

  //在实际场景中正确利用此回调可以避免重绘开销，本示例我们简单的返回true
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
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

  // 分形树1
  //
  // 一主干两侧干分形树，
  //  \C  /D
  //   \ /
  //    |B
  //    |
  //    |A
  //
  // 1、假设A(x, y) B(x0, y0) C(x1, y1) D(x2, y2)，主干长度为 = L , 主干与侧干夹角为 = a
  // 2、绘制主干AB，即(x, y) - (x0, y0)直线
  // 3、计算C坐标，L = 2L / 3，x1 = x0+ L * cos(a)，y1 = y0 - L * sin(a)
  // 4、计算D坐标，L = 2L / 3，x2 = x0+ L * cos(-a)，y2 = y0 - L * sin(-a)
  // 5、绘制侧干BC、BD
  // 6、重复步骤3-5，直至完成递归函数
  Offset origin; // 原点A
  int level = 8; // 递归深度
  double L = 90.0; // 主干初始长度
  double a = 45.0 * pi / 180.0; // 主干与侧干夹角(>45°时会不太自然)
  double a0 = 90.0 * pi / 180.0; // 主干生长角度
  double radioX = 0.8;
  double radioY = 0.8;
  double z = 2.0 / 3.0; // 侧干与主干的长度比例

  void drawTree1(
      Canvas canvas, Paint paint, int n, double l, double arg, int x, int y) {
    int xx, yy;
    xx = (l * cos(arg) + radioX).toInt();
    yy = (l * sin(arg) + radioY).toInt();
    Offset p1 = Offset(x + origin.dx, origin.dy - y);
    Offset p2 = Offset(x + xx + origin.dx, origin.dy - y - yy);

    canvas.drawLine(p1, p2, paint);

    if (n > 0) {
      drawTree1(canvas, paint, n - 1, l * z, arg - a / 2.0 + 0.0 * a / 1.0,
          x + xx, y + yy);
      drawTree1(canvas, paint, n - 1, l * z, arg - a / 2.0 + 1.0 * a / 1.0,
          x + xx, y + yy);
    }
  }

  // 分形树2(贴近自然树形态)
  //
  // 一主干4侧干分形树，
  // F\   /G
  //   \ /
  //    |B
  //    |
  // D\ | /E
  //   \|/
  //   C|
  //    |A
  //
  final double PI = pi / 180.0;
  void drawTree2(
      Canvas canvas, Paint paint, double x, double y, double L, double a) {
    double x1, x2, x1L, x2L, x1R, x2R;
    double y1, y2, y1L, y2L, y1R, y2R;

    double B = 50.0;
    double C = 9.0;
    double s1 = 2.0;
    double s2 = 3.0;
    double s3 = 1.2;

    if (L > s1) {
      x2 = x + L * cos(a * PI);
      y2 = y + L * sin(a * PI);
      x2R = x2 + L / s2 * cos((a + B) * PI);
      y2R = y2 + L / s2 * sin((a + B) * PI);
      x2L = x2 + L / s2 * cos((a - B) * PI);
      y2L = y2 + L / s2 * sin((a - B) * PI);

      x1 = x + L / s2 * cos(a * PI);
      y1 = y + L / s2 * sin(a * PI);
      x1L = x1 + L / s2 * cos((a - B) * PI);
      y1L = y1 + L / s2 * sin((a - B) * PI);
      x1R = x1 + L / s2 * cos((a + B) * PI);
      y1R = y1 + L / s2 * sin((a + B) * PI);

      canvas.drawLine(Offset(x, y), Offset(x2, y2), paint);
      canvas.drawLine(Offset(x2, y2), Offset(x2R, y2R), paint);
      canvas.drawLine(Offset(x2, y2), Offset(x2L, y2L), paint);
      canvas.drawLine(Offset(x1, y1), Offset(x1L, y1L), paint);
      canvas.drawLine(Offset(x1, y1), Offset(x1R, y1R), paint);

      drawTree2(canvas, paint, x2, y2, L / s3, a + C);
      drawTree2(canvas, paint, x2R, y2R, L / s2, a + B);
      drawTree2(canvas, paint, x2L, y2L, L / s2, a - B);
      drawTree2(canvas, paint, x1L, y1L, L / s2, a - B);
      drawTree2(canvas, paint, x1R, y1R, L / s2, a + B);
    }
  }

  // 分形树3
  //
  // 一主干2侧干分形树，
  //       /E
  //     /
  // D\ |B
  //   \|
  //   C|
  //    |A
  //
  final int minL = 1;
  void drawTree3(
      Canvas canvas, Paint paint, double x, double y, int L, double angle) {
    double x1, y1;
    if (L > minL) {
      x1 = cos(angle) * L + x;
      y1 = sin(angle) * L + y;

      canvas.drawLine(Offset(x1, y1), Offset(x, y), paint);

      drawTree3(canvas, paint, (x + x1) / 2, (y + y1) / 2, (L * 0.5).toInt(),
          angle - pi / 6);

      drawTree3(canvas, paint, x1, y1, (L * 0.5).toInt(), angle + pi / 6);
    }
  }

  // 分形树4
  //
  // 一主干2侧干分形树，
  // C\ | /D
  //   \|/
  //    |B
  //    |
  //    |
  //    |A
  //
  void drawTree4(
      Canvas canvas, Paint paint, double x, double y, int L, int angle, int t) {
    double x1, y1;
    for (int i = -1; i <= 1; i++) {
      x1 = x + L * cos((angle + i * (Random().nextDouble() * 40 + 20)) * PI);
      y1 = y + L * sin((angle + i * (Random().nextDouble() * 40 + 20)) * PI);

      canvas.drawLine(Offset(x, y), Offset(x1, y1), paint);

      if (L > 5) {
        drawTree4(canvas, paint, x1, y1, L - 8,
            (angle + i * (Random().nextDouble() * 40 + 10)).toInt(), t);
      } else {
        if (t == 1) {
          canvas.drawArc(Rect.fromLTWH(x1, y1, 2, 2), 0, pi, false, paint);
        } else if (t == 2) {
          canvas.drawLine(
              Offset(x1, y1),
              Offset((x1 + Random().nextDouble() * 5 * i),
                  (y1 + Random().nextDouble() * 20 + 50)),
              paint);
        }
      }
    }
  }

  // 分形树5-随机LS文法
  //
  // a = 25°
  // w: F
  // P1: F --> F[+F]F[-F]F  概率p1
  // P2: F --> F[+F]F[-F[+F]]  概率p2
  // P3: F --> FF-[-F+F+F]+[+F-F-F]  概率p3
  // p1 + p2 + p3 = 1.0
  //
  String regel;
  Staple kopf;
  Staple last;
  String zeichenkette = 'F'; // 公理
  double win = 30.0; // 转角

  String ch;

  double hoehe;
  double breite;
  int laenge;
  static final int angle = 5;
  Turtle turtle = Turtle();

  void befehl(String ch, Canvas canvas, Paint paint) {
    switch (ch) {
      case 'F':
        turtle.pen = true;
        turtle.move(canvas, paint, laenge);
        break;
      case 'f':
        turtle.pen = false;
        turtle.move(canvas, paint, laenge);
        break;
      case '+':
        turtle.turn(win);
        break;
      case '-':
        turtle.turn(-win);
        break;
      case '[': // push
        last.nach = Staple();
        last.nach.vor = last;
        last = last.nach;
        last.x = turtle.xpos;
        last.y = turtle.ypos;
        break;
      case ']': // pop
        turtle.xpos = last.x;
        turtle.ypos = last.y;
        turtle.alpha = last.alpha;
        last = last.vor;
        last.nach = null;
        break;
      default:
    }
  }

  String selectFunction(double c) {
    if (c <= 0.3) {
      regel = 'F[+F]F[-F]F';
      return regel;
    } else if (c > 0.3 && c <= 0.6) {
      regel = 'F[+F]F[-F[+F]]';
      return regel;
    } else {
      regel = 'FF-[-F+F+F]+[+F-F-F]';
      return regel;
    }
  }

  void drawTree5(Canvas canvas, Paint paint) {}
}

class Staple {
  double x;
  double y;
  double alpha;
  Staple nach;
  Staple vor;
}

class Turtle {
  double xpos;
  double ypos;
  double alpha;
  bool pen; // up: false, down: true

  double bogenmass(double winkel) {
    return 2 * pi * winkel / 360;
  }

  double winkel(double bogenmass) {
    return 360 * bogenmass / (2 * pi);
  }

  void turn(double winkel) {
    alpha = alpha + winkel;

    if (alpha > 360) {
      alpha = alpha - 360;
    } else if (alpha < 0) {
      alpha = 360 + alpha;
    }
  }

  void move(Canvas canvas, Paint paint, int laenge) {
    double neuX, neuY;

    neuX = xpos + laenge * cos(bogenmass(alpha));
    neuY = ypos + laenge * sin(bogenmass(alpha));

    if (pen) {
      canvas.drawLine(Offset(xpos, ypos), Offset(neuX, neuY), paint);

      xpos = neuX;
      ypos = neuY;
    }
  }
}
