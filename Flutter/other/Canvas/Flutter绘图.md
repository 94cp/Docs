## Flutter绘图

在Flutter中，提供了一个`CustomPaint` 组件，它可以结合画笔`CustomPainter`来实现2D图形绘制。并且也提供了`Canvas`类，封装了一些基本绘制的API方法。

![HeartTree](https://github.com/cp110/Docs/blob/master/Flutter/other/Canvas/Screenshots/HeartTree.png)

### 1 常用类

#### 1.1 CustomPaint

```dart
CustomPaint({
  Key key,
  this.painter, // 背景画笔，会显示在子节点后面
  this.foregroundPainter, // 前景画笔，会显示在子节点前面
  this.size = Size.zero, // 当child为null时，代表默认绘制区域大小，如果有child则忽略此参数，画布尺寸则为child尺寸。如果有child但是想指定画布为特定大小，可以使用SizeBox包裹CustomPaint实现
  this.isComplex = false, // 是否复杂的绘制，如果是，Flutter会应用一些缓存策略来减少重复渲染的开销
  this.willChange = false, // 和isComplex配合使用，当启用缓存时，该属性代表在下一帧中绘制是否会改变
  Widget child, //子节点，可以为空。为了避免子节点不必要的重绘并提高性能，通常情况下都会将子节点包裹在RepaintBoundary组件中，这样会在绘制时就会创建一个新的绘制层（Layer），其子组件将在新的Layer上绘制，而父组件将在原来Layer上绘制，也就是说RepaintBoundary 子组件的绘制将独立于父组件的绘制，RepaintBoundary会隔离其子节点和CustomPaint本身的绘制边界
})
```

#### 1.2 抽象类CustomPainter

```dart
void paint(Canvas canvas, Size size);
bool shouldRepaint(CustomPainter oldDelegate);
```

#### 1.3 画笔Paint

```dart
Paint paint = Paint() //创建一个画笔并配置其属性
  ..isAntiAlias = true //是否抗锯齿
  ..style = PaintingStyle.fill //画笔样式：填充
  ..color=Color(0x77cdb175);//画笔颜色
```

### 2 简单绘图示例

![sample](https://github.com/cp110/Docs/blob/master/Flutter/other/Canvas/Screenshots/sample.png)

```dart
Paint paint = Paint()
      ..isAntiAlias = true //抗锯齿
      ..style = PaintingStyle.stroke //画笔样式
      ..color = Colors.green //画笔颜色
      ..strokeWidth = 2; //画笔宽度

// 画点
canvas.drawPoints(PointMode.points, [Offset(size.width / 2, 20)], paint);

// 画线
canvas.drawLine(Offset(100, 40), Offset(size.width - 100, 40), paint);

// 画矩形
canvas.drawRect(Rect.fromLTWH((size.width - 100) / 2, 60, 100, 50), paint);

// 画椭圆
canvas.drawOval(Rect.fromLTWH((size.width - 100) / 2, 130, 100, 50), paint);

// 画弧线
canvas.drawArc(
    Rect.fromCircle(center: Offset(size.width / 2, 180), radius: 60),
    pi * 1 / 6.0,
    pi * 1 / 3.0,
    false,
    paint);

// 画圆
canvas.drawCircle(Offset(size.width / 2, 320), 60, paint);

// 画图片
if (_image != null) {
  canvas.drawImage(
      _image, Offset((size.width - _image.width) / 2, 400), paint);
}

// 画文字
ParagraphBuilder pb = ParagraphBuilder(ParagraphStyle(
    textAlign: TextAlign.center,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.normal,
    fontSize: 16,
))
    ..pushStyle(ui.TextStyle(color: Colors.blue))
    ..addText('Hello Canvas');
ParagraphConstraints pc = ParagraphConstraints(width: 200);
Paragraph paragraph = pb.build()..layout(pc);
canvas.drawParagraph(paragraph, Offset((size.width - 200) / 2, 460));

// 画路径
Path path = Path()..moveTo((size.width - 200) / 2, 500);
Rect rect =
    Rect.fromCircle(center: Offset(size.width / 2, 500), radius: 60.0);
path.arcTo(rect, 0.0, pi, false);
canvas.drawPath(path, paint);
```

### 3 复杂绘图示例

#### 3.1 心形

![heart1](https://github.com/cp110/Docs/blob/master/Flutter/other/Canvas/Screenshots/heart1.png)

```dart
/// 心形公式1：{x = 16sin^3(t), y = 13cos(t) - 5cos(2t) - 2cos(3t) - cos(4t)}, t = [0, 2π]
/// [orign]: 心形尖头位置，默认=.zero
/// [scale]: 缩放比例，默认=15.0
/// [offset]: 偏移值，默认=0.05
/// [fill]: 是否实心，默认=true
List<Offset> heart1(
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

```

#### 3.2 心形

![heart2](https://github.com/cp110/Docs/blob/master/Flutter/other/Canvas/Screenshots/heart2.png)

```dart
/// 心形公式2：x^2 + (y - (x^2)^(1/3))^2 = 1, x = [-1, 1]
/// [orign]: 心形尖头位置，默认=.zero
/// [scale]: 缩放比例，默认=15.0
/// [offset]: 偏移值，默认=0.05
/// [fill]: 是否实心，默认=true
List<Offset> heart2(
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
```

#### 3.3 树形

![tree1](https://github.com/cp110/Docs/blob/master/Flutter/other/Canvas/Screenshots/tree1.png)

```dart
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
```

#### 3.4 树形

![tree2](https://github.com/cp110/Docs/blob/master/Flutter/other/Canvas/Screenshots/tree2.png)

```dart
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
    drawTree(canvas, paint, Offset(x1L, y1L), length / s2, angle - extendAngle);
    drawTree(canvas, paint, Offset(x1R, y1R), length / s2, angle + extendAngle);
    drawTree(canvas, paint, Offset(x2R, y2R), length / s2, angle + extendAngle);
    drawTree(canvas, paint, Offset(x2L, y2L), length / s2, angle - extendAngle);
  }
}
```

#### 3.5 树形

![tree3](https://github.com/cp110/Docs/blob/master/Flutter/other/Canvas/Screenshots/tree3.png)

```dart
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
```

#### 3.6 树

![tree4](https://github.com/cp110/Docs/blob/master/Flutter/other/Canvas/Screenshots/tree4.png)

```dart
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
```

#### 3.7 树

![tree5](https://github.com/cp110/Docs/blob/master/Flutter/other/Canvas/Screenshots/tree5.png)

```dart
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
```

### 4 组合绘图

![heart_tree](https://github.com/cp110/Docs/blob/master/Flutter/other/Canvas/Screenshots/heart_tree.png)