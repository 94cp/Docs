import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Isolate Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// 斐波那契数列：F[n]=F[n-1]+F[n-2](n>=3,F[1]=1,F[2]=1)
// 0、1、1、2、3、5、8、13、21、34、……
int fibonacci(int n) {
  if (n <= 0) return 0;
  if (n == 1 || n == 2) return 1;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  // 动画
  AnimationController _animationController;
  Animation _animation;

  // 斐波那契数列计算结果
  String _fibonacciResult = 'waiting...';

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(seconds: 5), vsync: this);
    _animation = Tween(begin: 0.0, end: pi * 2).animate(_animationController);
    _animationController.repeat();

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RotationTransition(
              turns: _animation,
              child: Container(
                height: 80,
                width: 80,
                color: Colors.red,
              ),
            ),
            Text(_fibonacciResult),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: RaisedButton(
                onPressed: _fibonacciCalculate,
                child: Text('斐波那契数列'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: RaisedButton(
                onPressed: _isolateFibonacciCalculate,
                child: Text('isolate斐波那契数列'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: RaisedButton(
                onPressed: _computeFibonacciCalculate,
                child: Text('compute斐波那契数列'),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 方式1：同步计算斐波那契数列
  void _fibonacciCalculate() {
    setState(() {
      _fibonacciResult = 'waiting...';
    });

    int n = Random().nextInt(5) + 40;
    int fibonacciN = fibonacci(n);

    setState(() {
      _fibonacciResult =
          'fibonacci(${n.toString()}) = ${fibonacciN.toString()}';
    });
  }

  // 方式2：isolate异步计算斐波那契数列
  void _isolateFibonacciCalculate() async {
    setState(() {
      _fibonacciResult = 'waiting...';
    });

    /** 建立主从接收端口的联系 */
    // 创建 主接收端口
    ReceivePort masterPort = ReceivePort();
    // 创建isolate，并将 主接收端口 的 发送端口 传给 从接收端口方法_calculate(该方法必须是顶级函数或static)
    Isolate isolate = await Isolate.spawn(_calculate, masterPort.sendPort);
    // 等待 从接收端口 将 发送端口 传给 主接收端口
    SendPort slaveSendPort = await masterPort.first;

    int n = Random().nextInt(5) + 40;
    int fibonacciN = await _sendReceive(slaveSendPort, n);

    // 不再使用isolate时，务必销毁它
    isolate.kill(priority: Isolate.immediate);

    setState(() {
      _fibonacciResult =
          'fibonacci(${n.toString()}) = ${fibonacciN.toString()}';
    });
  }

  // 从接收端口方法_calculate(该方法必须是顶级函数或static)
  static _calculate(SendPort masterSendPort) async {
    // 创建从接收端口
    ReceivePort slavePort = ReceivePort();
    // 用 主接收端口 的 发送端口 将 从接收端口 的 发送端口 传给 主接收端口
    masterSendPort.send(slavePort.sendPort);

    await for (var msg in slavePort) {
      int n = msg[0];
      SendPort tempSendPort = msg[1];
      int fibonacciN = fibonacci(n);
      tempSendPort.send(fibonacciN);
    }
  }

  Future _sendReceive(SendPort slaveSendPort, msg) {
    ReceivePort tempPort = ReceivePort();
    slaveSendPort.send([msg, tempPort.sendPort]);
    return tempPort.first;
  }

  // 方式3：compute异步计算斐波那契数列
  void _computeFibonacciCalculate() async {
    setState(() {
      _fibonacciResult = 'waiting...';
    });

    int n = Random().nextInt(5) + 40;
    int fibonacciN = await compute(fibonacci, n);

    setState(() {
      _fibonacciResult =
          'fibonacci(${n.toString()}) = ${fibonacciN.toString()}';
    });
  }
}
