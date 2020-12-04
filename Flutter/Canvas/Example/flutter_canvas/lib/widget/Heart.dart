import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

enum HeartStyle {
  style1,
  style2,
}

class Heart extends StatelessWidget {
  static const defaultColors = [Colors.blue, Colors.green, Colors.red];

  final Offset origin;
  final double angle;
  final List<Color> colors;
  final double square;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final HeartStyle heartStyle;
  final bool fill;

  Heart({
    this.origin,
    this.colors = Heart.defaultColors,
    this.square = 15.0,
    this.paintingStyle = PaintingStyle.fill,
    this.strokeWidth = 1.0,
    this.heartStyle = HeartStyle.style1,
    this.angle = pi,
    this.fill = true,
  });

  @override
  Widget build(BuildContext context) {
    Size size = Size.square(square);
    Offset _origin = origin;
    if (_origin == null) {
      _origin = Offset(size.width / 2, size.height / 2);
    }

    List<Color> _colors;
    if (colors.length == 1) {
      _colors = [colors.first, colors.first];
    } else if (colors == null || colors.length == 0) {
      _colors = [Colors.red, Colors.red];
    } else {
      _colors = colors;
    }

    return Transform.rotate(
      angle: angle,
      child: CustomPaint(
        size: size,
        painter: _HeartCanvasPainter(
            _origin, _colors, paintingStyle, strokeWidth, heartStyle, fill),
      ),
    );
  }
}

class _HeartCanvasPainter extends CustomPainter {
  final Offset origin;
  final List<Color> colors;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final HeartStyle heartStyle;
  final bool fill;

  _HeartCanvasPainter(this.origin, this.colors, this.paintingStyle,
      this.strokeWidth, this.heartStyle, this.fill);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..isAntiAlias = true //抗锯齿
      ..style = paintingStyle //画笔样式
      ..strokeWidth = strokeWidth //画笔宽度
      ..shader = LinearGradient(colors: colors) // 渐变
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    switch (heartStyle) {
      case HeartStyle.style1:
        List<Offset> heartPoints = HeartUtil.heart1(
            origin: origin, scale: min(origin.dx, origin.dy), fill: fill);
        canvas.drawPoints(PointMode.polygon, heartPoints, paint);
        break;
      case HeartStyle.style2:
        List<Offset> heartPoints = HeartUtil.heart2(
            origin: origin, scale: min(origin.dx, origin.dy), fill: fill);
        canvas.drawPoints(PointMode.polygon, heartPoints, paint);
        break;
      default:
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class HeartUtil {
  /// 心形公式1：{x = 16sin^3(t), y = 13cos(t) - 5cos(2t) - 2cos(3t) - cos(4t)}, t = [0, 2π]
  /// [orign]: 心形尖头位置，默认=.zero
  /// [scale]: 缩放比例，默认=15.0
  /// [offset]: 偏移值，默认=0.05
  /// [fill]: 是否实心，默认=true
  static List<Offset> heart1(
      {Offset origin = Offset.zero,
      double scale = 15.0,
      double offset = 0.05,
      bool fill = true}) {
    List<Offset> points = List();

    double _scale = scale / 15.0;
    double _offset = offset / scale;

    for (var t = 0.0; t <= pi * 2; t += _offset) {
      double x = 16 * pow(sin(t), 3);
      double y = 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t);
      points.add(Offset(x * _scale + origin.dx, y * _scale + origin.dy));
      if (fill) {
        // 补充原点是为了绘制实心心形
        points.add(Offset(origin.dx, origin.dy));
      }
    }

    return points;
  }

  /// 心形公式2：x^2 + (y - (x^2)^(1/3))^2 = 1, x = [-1, 1]
  /// [orign]: 心形尖头位置，默认=.zero
  /// [scale]: 缩放比例，默认=15.0
  /// [offset]: 偏移值，默认=0.05
  /// [fill]: 是否实心，默认=true
  static List<Offset> heart2(
      {Offset origin = Offset.zero,
      double scale = 15.0,
      double offset = 0.05,
      bool fill = true}) {
    List<Offset> points = List();

    double _offset = offset / scale;

    for (double x = -1.0; x <= 1.0; x += _offset) {
      if (x == -1.0 || x == 1.0) {
        points.add(Offset(x * scale + origin.dx, 1.0 * scale + origin.dy));
      } else if (x == 0.0) {
        points.add(Offset(x * scale + origin.dx, 1.0 * scale + origin.dy));
      } else {
        // 计算上半部分点位置
        // (x^(2/3) - y)^2 + x^2 = 1
        double y1 = pow(x.abs(), 2.0 / 3) - sqrt(1 - x * x);
        points.add(Offset(x * scale + origin.dx, y1 * scale + origin.dy));

        // 计算下半部分点位置
        // (y - x^(2/3))^2 + x^2 = 1
        if (fill) {
          double y2 = sqrt(1 - x * x) + pow(x.abs(), 2.0 / 3);
          points.add(Offset(x * scale + origin.dx, y2 * scale + origin.dy));
        }
      }
    }

    // 计算下半部分点位置
    // (y - x^(2/3))^2 + x^2 = 1
    if (!fill) {
      for (double x = 1.0; x >= -1.0; x -= _offset) {
        if (x == -1.0 || x == 1.0) {
          points.add(Offset(x * scale + origin.dx, 1.0 * scale + origin.dy));
        } else if (x == 0.0) {
          points.add(Offset(x * scale + origin.dx, -1.0 * scale + origin.dy));
        } else {
          double y2 = sqrt(1 - x * x) + pow(x.abs(), 2.0 / 3);
          points.add(Offset(x * scale + origin.dx, y2 * scale + origin.dy));
        }
      }
    }

    // 修复double精度问题导致遗漏起点问题
    if (points.last.dx != (-1.0 * scale + origin.dx)) {
      points.add(Offset(-1.0 * scale + origin.dx, 1.0 * scale + origin.dy));
    }

    return points;
  }

  static bool inHeart(double x, double y, double radius) {
    // x^2+(y-(x^2)^(1/3))^2 = 1
    var z = ((x / radius) * (x / radius) + (y / radius) * (y / radius) - 1) *
            ((x / radius) * (x / radius) + (y / radius) * (y / radius) - 1) *
            ((x / radius) * (x / radius) + (y / radius) * (y / radius) - 1) -
        (x / radius) *
            (x / radius) *
            (y / radius) *
            (y / radius) *
            (y / radius);
    return z < 0;
  }
}
