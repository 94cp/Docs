import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/*
 
CustomPaint({
  Key key,
  this.painter, // 背景画笔，会显示在子节点后面
  this.foregroundPainter, // 前景画笔，会显示在子节点前面
  this.size = Size.zero, // 当child为null时，代表默认绘制区域大小，如果有child则忽略此参数，画布尺寸则为child尺寸。如果有child但是想指定画布为特定大小，可以使用SizeBox包裹CustomPaint实现
  this.isComplex = false, // 是否复杂的绘制，如果是，Flutter会应用一些缓存策略来减少重复渲染的开销
  this.willChange = false, // 和isComplex配合使用，当启用缓存时，该属性代表在下一帧中绘制是否会改变
  Widget child, //子节点，可以为空。为了避免子节点不必要的重绘并提高性能，通常情况下都会将子节点包裹在RepaintBoundary组件中，这样会在绘制时就会创建一个新的绘制层（Layer），其子组件将在新的Layer上绘制，而父组件将在原来Layer上绘制，也就是说RepaintBoundary 子组件的绘制将独立于父组件的绘制，RepaintBoundary会隔离其子节点和CustomPaint本身的绘制边界
})

CustomPainter
  void paint(Canvas canvas, Size size);

var paint = Paint() //创建一个画笔并配置其属性
  ..isAntiAlias = true //是否抗锯齿
  ..style = PaintingStyle.fill //画笔样式：填充
  ..color=Color(0x77cdb175);//画笔颜色

 */

class SingleCanvasPage extends StatefulWidget {
  SingleCanvasPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SingleCanvasPage createState() => _SingleCanvasPage();
}

class _SingleCanvasPage extends State<SingleCanvasPage> {
  ui.Image _image;

  @override
  void initState() {
    _loadImage('assets/apple.png').then((image) {
      setState(() {
        _image = image;
      });
    });

    super.initState();
  }

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
            painter: _SingleCanvasPainter(_image), size: Size(width, height)),
      ),
    );
  }

  Future<ui.Image> _loadImage(String asset) async {
    ByteData data = await rootBundle.load(asset);
    if (data == null) throw 'Unable to read data';
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List());
    FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }
}

class _SingleCanvasPainter extends CustomPainter {
  ui.Image _image;

  _SingleCanvasPainter(this._image) {
    this._image = _image;
  }

  @override
  void paint(Canvas canvas, Size size) {
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
  }

  //在实际场景中正确利用此回调可以避免重绘开销，本示例我们简单的返回true
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
