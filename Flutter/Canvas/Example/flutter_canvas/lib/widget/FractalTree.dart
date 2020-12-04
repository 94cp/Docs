import 'dart:math';

import 'package:flutter/material.dart';

class FractalTree1 extends StatelessWidget {
  static const defaultColors = [Colors.blue, Colors.green, Colors.red];

  final List<Color> colors;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  final Size size;

  final Offset origin; // 原点A
  final int depth; // 递归深度
  final double length; // 主干初始长度
  final double angle0; // 主干生长角度
  final double offsetAngle; // 主干与侧干夹角(>45°时会不太自然)
  final Offset offset; // 侧干生长偏移值
  final double z; // 侧干与主干的长度比例

  const FractalTree1(
      {this.colors = FractalTree1.defaultColors,
      this.paintingStyle = PaintingStyle.stroke,
      this.strokeWidth = 1.0,
      @required this.size,
      this.origin,
      this.depth = 8,
      this.length = 90.0,
      this.angle0 = 90 * pi / 180,
      this.offsetAngle = 45 * pi / 180,
      this.offset = Offset.zero,
      this.z = 2 / 3.0});

  @override
  Widget build(BuildContext context) {
    Offset _origin = origin;
    if (_origin == null) {
      _origin = Offset(size.width / 2, size.height);
    }

    return Center(
      child: CustomPaint(
        size: size,
        painter: _FractalTree1(colors, paintingStyle, strokeWidth, _origin,
            depth, length, angle0, offsetAngle, offset, z),
      ),
    );
  }
}

class _FractalTree1 extends CustomPainter {
  final List<Color> colors;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  final Offset origin; // 原点A
  final int depth; // 递归深度
  final double length; // 主干初始长度
  final double angle0; // 主干生长角度
  final double offsetAngle; // 主干与侧干夹角(>45°时会不太自然)
  final Offset offset; // 侧干生长偏移值
  final double z; // 侧干与主干的长度比例

  _FractalTree1(
      this.colors,
      this.paintingStyle,
      this.strokeWidth,
      this.origin,
      this.depth,
      this.length,
      this.angle0,
      this.offsetAngle,
      this.offset,
      this.z);

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
  void drawTree(Canvas canvas, Paint paint, int depth, double length,
      double angle, Offset root) {
    double xx = length * cos(angle) + offset.dx;
    double yy = length * sin(angle) + offset.dy;

    Offset p1 = Offset(root.dx + origin.dx, origin.dy - root.dy);
    Offset p2 = Offset(root.dx + xx + origin.dx, origin.dy - root.dy - yy);

    canvas.drawLine(p1, p2, paint);

    if (depth > 0) {
      drawTree(
          canvas,
          paint,
          depth - 1,
          length * z,
          angle - offsetAngle / 2.0 + 0.0 * offsetAngle / 1.0,
          Offset(root.dx + xx, root.dy + yy));
      drawTree(
          canvas,
          paint,
          depth - 1,
          length * z,
          angle - offsetAngle / 2.0 + 1.0 * offsetAngle / 1.0,
          Offset(root.dx + xx, root.dy + yy));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..isAntiAlias = true //抗锯齿
      ..style = paintingStyle //画笔样式
      ..strokeWidth = strokeWidth //画笔宽度
      ..shader = LinearGradient(colors: colors) // 渐变
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    drawTree(canvas, paint, depth, length, angle0, Offset.zero);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class FractalTree2 extends StatelessWidget {
  static const defaultColors = [Colors.blue, Colors.green, Colors.red];

  final List<Color> colors;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  final Size size;

  final double extendAngle; // 树杈伸展角度
  final double curveAngle; // 树杈弯曲角度
  final double s1; // 树疏密
  final double s2; // 树疏密
  final double s3; // 树高矮
  final Offset origin; // 原点A
  final double length;
  final double angle;

  const FractalTree2(
      {Key key,
      this.colors = defaultColors,
      this.paintingStyle = PaintingStyle.stroke,
      this.strokeWidth = 1.0,
      @required this.size,
      this.extendAngle = 50.0,
      this.curveAngle = 9.0,
      this.s1 = 2.0,
      this.s2 = 3.0,
      this.s3 = 1.2,
      this.origin,
      this.length = 50.0,
      this.angle = 270.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Offset _origin = origin;
    if (_origin == null) {
      _origin = Offset(size.width / 2, size.height);
    }

    return Center(
      child: CustomPaint(
        size: size,
        painter: _FractalTree2(colors, paintingStyle, strokeWidth, extendAngle,
            curveAngle, s1, s2, s3, _origin, length, angle),
      ),
    );
  }
}

class _FractalTree2 extends CustomPainter {
  // ignore: non_constant_identifier_names
  final double PI = pi / 180;

  final List<Color> colors;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final double extendAngle; // 树杈伸展角度
  final double curveAngle; // 树杈弯曲角度
  final double s1; // 树疏密
  final double s2; // 树疏密
  final double s3; // 树高矮
  final Offset origin; // 原点A
  final double length;
  final double angle;

  _FractalTree2(
      this.colors,
      this.paintingStyle,
      this.strokeWidth,
      this.extendAngle,
      this.curveAngle,
      this.s1,
      this.s2,
      this.s3,
      this.origin,
      this.length,
      this.angle);

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
  void drawTree(
      Canvas canvas, Paint paint, Offset root, double length, double angle) {
    if (length > s1) {
      double x1 = root.dx + length / s2 * cos(angle * PI);
      double y1 = root.dy + length / s2 * sin(angle * PI);
      double x1L = x1 + length / s2 * cos((angle - extendAngle) * PI);
      double y1L = y1 + length / s2 * sin((angle - extendAngle) * PI);
      double x1R = x1 + length / s2 * cos((angle + extendAngle) * PI);
      double y1R = y1 + length / s2 * sin((angle + extendAngle) * PI);

      double x2 = root.dx + length * cos(angle * PI);
      double y2 = root.dy + length * sin(angle * PI);
      double x2R = x2 + length / s2 * cos((angle + extendAngle) * PI);
      double y2R = y2 + length / s2 * sin((angle + extendAngle) * PI);
      double x2L = x2 + length / s2 * cos((angle - extendAngle) * PI);
      double y2L = y2 + length / s2 * sin((angle - extendAngle) * PI);

      canvas.drawLine(root, Offset(x2, y2), paint);
      canvas.drawLine(Offset(x1, y1), Offset(x1L, y1L), paint);
      canvas.drawLine(Offset(x1, y1), Offset(x1R, y1R), paint);
      canvas.drawLine(Offset(x2, y2), Offset(x2R, y2R), paint);
      canvas.drawLine(Offset(x2, y2), Offset(x2L, y2L), paint);

      drawTree(canvas, paint, Offset(x2, y2), length / s3, angle + curveAngle);
      drawTree(
          canvas, paint, Offset(x1L, y1L), length / s2, angle - extendAngle);
      drawTree(
          canvas, paint, Offset(x1R, y1R), length / s2, angle + extendAngle);
      drawTree(
          canvas, paint, Offset(x2R, y2R), length / s2, angle + extendAngle);
      drawTree(
          canvas, paint, Offset(x2L, y2L), length / s2, angle - extendAngle);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..isAntiAlias = true //抗锯齿
      ..style = paintingStyle //画笔样式
      ..strokeWidth = strokeWidth //画笔宽度
      ..shader = LinearGradient(colors: colors) // 渐变
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    drawTree(canvas, paint, origin, length, angle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class FractalTree3 extends StatelessWidget {
  static const defaultColors = [Colors.blue, Colors.green, Colors.red];

  final List<Color> colors;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  final Size size;

  final double s; // 树高矮
  final Offset origin; // 原点A
  final double length;
  final double angle;

  const FractalTree3(
      {Key key,
      this.colors = defaultColors,
      this.paintingStyle = PaintingStyle.stroke,
      this.strokeWidth = 1.0,
      @required this.size,
      this.s = 0.5,
      this.origin,
      this.length = 200,
      this.angle = -pi / 2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Offset _origin = origin;
    if (_origin == null) {
      _origin = Offset(size.width / 2, size.height);
    }

    return Center(
      child: CustomPaint(
        size: size,
        painter: _FractalTree3(
            colors, paintingStyle, strokeWidth, s, _origin, length, angle),
      ),
    );
  }
}

class _FractalTree3 extends CustomPainter {
  final int minLength = 1;

  final List<Color> colors;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  final double s; // 树高矮
  final Offset origin; // 原点A
  final double length;
  final double angle;

  _FractalTree3(this.colors, this.paintingStyle, this.strokeWidth, this.s,
      this.origin, this.length, this.angle);

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
  void drawTree(
      Canvas canvas, Paint paint, Offset root, double length, double angle) {
    if (length > minLength) {
      double x1 = cos(angle) * length + root.dx;
      double y1 = sin(angle) * length + root.dy;

      canvas.drawLine(root, Offset(x1, y1), paint);

      drawTree(canvas, paint, Offset((root.dx + x1) / 2, (root.dy + y1) / 2),
          length * s, angle - pi / 6);
      drawTree(canvas, paint, Offset(x1, y1), length * s, angle + pi / 6);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..isAntiAlias = true //抗锯齿
      ..style = paintingStyle //画笔样式
      ..strokeWidth = strokeWidth //画笔宽度
      ..shader = LinearGradient(colors: colors) // 渐变
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    drawTree(canvas, paint, origin, length, angle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class FractalTree4 extends StatelessWidget {
  static const defaultColors = [Colors.blue, Colors.green, Colors.red];

  final List<Color> colors;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  final Size size;

  final double s; // 树高矮
  final Offset origin; // 原点A
  final double length;
  final double angle;
  final bool leafArc;

  const FractalTree4(
      {Key key,
      this.colors = defaultColors,
      this.paintingStyle = PaintingStyle.stroke,
      this.strokeWidth = 1.0,
      @required this.size,
      this.s = 8,
      this.origin = Offset.zero,
      this.length = 50.0,
      this.angle = -90.0,
      this.leafArc = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Offset _origin = origin;
    if (_origin == null) {
      _origin = Offset(size.width / 2, size.height);
    }

    return Center(
      child: CustomPaint(
        painter: _FractalTree4(colors, paintingStyle, strokeWidth, s, _origin,
            length, angle, leafArc),
      ),
    );
  }
}

class _FractalTree4 extends CustomPainter {
  // ignore: non_constant_identifier_names
  final double PI = pi / 180;

  final List<Color> colors;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  final double s; // 树高矮
  final Offset origin; // 原点A
  final double length;
  final double angle;
  final bool leafArc;

  _FractalTree4(this.colors, this.paintingStyle, this.strokeWidth, this.s,
      this.origin, this.length, this.angle, this.leafArc);

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
  void drawTree(Canvas canvas, Paint paint, Offset root, double length,
      double angle, bool leafArc) {
    for (int i = -1; i <= 1; i++) {
      double x1 = root.dx +
          length * cos((angle + i * (Random().nextDouble() * 40 + 20)) * PI);
      double y1 = root.dy +
          length * sin((angle + i * (Random().nextDouble() * 40 + 20)) * PI);

      canvas.drawLine(root, Offset(x1, y1), paint);

      if (length > 5) {
        drawTree(canvas, paint, Offset(x1, y1), length - s,
            angle + i * (Random().nextDouble() * 40 + 10), leafArc);
      } else {
        if (leafArc) {
          canvas.drawArc(Rect.fromLTWH(x1, y1, 2, 2), 0, pi, false, paint);
        } else {
          canvas.drawLine(
              Offset(x1, y1),
              Offset((x1 + Random().nextDouble() * 5 * i),
                  (y1 + Random().nextDouble() * 20 + 50)),
              paint);
        }
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..isAntiAlias = true //抗锯齿
      ..style = paintingStyle //画笔样式
      ..strokeWidth = strokeWidth //画笔宽度
      ..shader = LinearGradient(colors: colors) // 渐变
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawLine(origin, Offset(origin.dx, origin.dy + length), paint);
    drawTree(canvas, paint, origin, length, angle, leafArc);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class FractalTree5 extends StatelessWidget {
  static const defaultColors = [Colors.blue, Colors.green, Colors.red];

  final List<Color> colors;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  final Size size;

  final Offset origin; // 原点A
  final double length;
  final double angle;
  final int depth; // 递归深度

  const FractalTree5(
      {Key key,
      this.colors = defaultColors,
      this.paintingStyle = PaintingStyle.stroke,
      this.strokeWidth = 1.0,
      @required this.size,
      this.origin,
      this.length = 4.0,
      this.angle = 30.0,
      this.depth = 4})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Offset _origin = origin;
    if (_origin == null) {
      _origin = Offset(size.width / 2, size.height);
    }

    return Center(
      child: CustomPaint(
        size: size,
        painter: _FractalTree5(
            colors, paintingStyle, strokeWidth, _origin, length, angle, depth),
      ),
    );
  }
}

class _FractalTree5 extends CustomPainter {
  final List<Color> colors;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  final Offset origin; // 原点A
  final double length;
  final double angle;
  final int depth; // 递归深度

  Staple last;
  Turtle turtle = Turtle();

  _FractalTree5(this.colors, this.paintingStyle, this.strokeWidth, this.origin,
      this.length, this.angle, this.depth);

  // 分形树5-随机LS文法
  //
  // a = 25°
  // w: F
  // P1: F --> F[+F]F[-F]F  概率p1
  // P2: F --> F[+F]F[-F[+F]]  概率p2
  // P3: F --> FF-[-F+F+F]+[+F-F-F]  概率p3
  // p1 + p2 + p3 = 1.0
  //
  void befehl(String ch, Canvas canvas, Paint paint) {
    switch (ch) {
      case 'F':
        turtle.pen = true;
        turtle.move(canvas, paint, length);
        break;
      case 'f':
        turtle.pen = false;
        turtle.move(canvas, paint, length);
        break;
      case '+':
        turtle.turn(angle);
        break;
      case '-':
        turtle.turn(-angle);
        break;
      case '[': // push
        last.nach = Staple();
        last.nach.vor = last;
        last = last.nach;
        last.x = turtle.xPos;
        last.y = turtle.yPos;
        last.angle = turtle.angle;
        break;
      case ']': // pop
        turtle.xPos = last.x;
        turtle.yPos = last.y;
        turtle.angle = last.angle;
        last = last.vor;
        last.nach = null;
        break;
      default:
    }
  }

  String createRegel(double c) {
    if (c <= 0.3) {
      return 'F[+F]F[-F]F';
    } else if (c > 0.3 && c <= 0.6) {
      return 'F[+F]F[-F[+F]]';
    } else {
      return 'FF-[-F+F+F]+[+F-F-F]';
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..isAntiAlias = true //抗锯齿
      ..style = paintingStyle //画笔样式
      ..strokeWidth = strokeWidth //画笔宽度
      ..shader = LinearGradient(colors: colors) // 渐变
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    turtle.xPos = origin.dx;
    turtle.yPos = origin.dy;
    turtle.angle = -90.0;
    turtle.pen = true;

    last = Staple();

    String zeichenkette = createRegel(Random().nextDouble()); // 公理
    for (var d = 0; d < depth; d++) {
      for (var i = 0; i < zeichenkette.length; i++) {
        if (zeichenkette[i] == 'F') {
          String regel = createRegel(Random().nextDouble());
          zeichenkette = zeichenkette.replaceRange(i, i + 1, regel);
          i += regel.length;
        }
      }
    }

    for (var char in zeichenkette.characters) {
      befehl(char, canvas, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class Staple {
  double x;
  double y;
  double angle;
  Staple nach;
  Staple vor;
}

class Turtle {
  double xPos;
  double yPos;
  double angle;
  bool pen;

  double bogenmass(double winkel) {
    return 2 * pi * winkel / 360.0;
  }

  double winkel(double bogenmass) {
    return 360 * bogenmass / (2 * pi);
  }

  void turn(double winkel) {
    angle = angle + winkel;

    if (angle > 360) {
      angle = angle - 360.0;
    } else if (angle < 0) {
      angle = 360.0 + angle;
    }
  }

  void move(Canvas canvas, Paint paint, double length) {
    double neuX = xPos + length * cos(bogenmass(angle));
    double neuY = yPos + length * sin(bogenmass(angle));

    if (pen) {
      canvas.drawLine(Offset(xPos, yPos), Offset(neuX, neuY), paint);
    }

    xPos = neuX;
    yPos = neuY;
  }
}
