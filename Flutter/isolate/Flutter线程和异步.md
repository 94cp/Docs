## Flutter线程和异步

`Dart`是单线程执行模型，除非启动一个`Isolate`，否则代码永远运行在UI线程（我们可以简单地理解成主线程，但实际上Dart没有所谓的主线程/子线程之分），并由`event loop`驱动（和iOS中的main loop类似）。

`Dart`的单线程模型并不意味着代码一定是阻塞操作。相反，与`Java`、`OC`相比，`Dart`提供了`async / await`语法来简化异步操作。

### 1. Future

Future 是一个异步执行并且在未来的某一个时刻完成（或失败）的任务。

#### 1.1. Future单任务

```dart
Future future = ...;
// 1、原始写法
future.then((result) {
  // 正常
}).catchError((error) {
  // 异常
});

// 2、await写法（推荐）
try {
  final result = await future(...);
  // 正常
} catch (error) {
  // 异常
}
```

#### 1.2. Future任务依赖

```dart
// 1、原始写法
future1.then((result1) {// 先执行任务1
  future2(result1).then((result2) {// 任务1执行完毕后，再执行任务2
    // 正常
   })
}).catchError((error) {
   // 异常
});

// 2、await写法（推荐）
try {
  final result1= await future1(...);// 先执行任务1
  final result2= await future2(result1);// 任务1执行完毕后，再执行任务2
  // 正常
} catch (error) {
  // 异常
}
```

#### 1.3. Future任务组

```dart
Future future1() async =>  ...
Future future2() async =>  ...
Future future3() async =>  ...

// 并发执行
await Future.wait([
  future1(),
  future2(),
  future3(),
]);

// 所有任务都执行完毕后，才继续执行下面的代码
```

### 2. Sream

Stream流数据处理，是一个异步执行并且在未来的某时段内持续响应数据（或失败）的任务。

```dart
Future streamXX() async {
  // ...
  await for (var request in requestServer) {
    handleRequest(request);
  }
  // ...
}
```

### 3. Isolate

一般对于访问磁盘或网络请求等，使用`Future`、`Stream` 或 `async / await` 就完事了。但当你执行计算密集型任务时，这会阻塞 `event loop`，导致UI挂起。这就需要`Isolate`来处理那些长期运行或是计算密集型的任务。

`Isolate`：英文意思是隔离。正如它的名字一样，它和主线程不共享内存，`Isolate`之间也不共享内存，原理可以简单地理解成iOS的沙盒机制。

JVM vs Dart VM：

与JVM内存模型不同的是，`dart`中每个`Isolate`都有自己的独立的堆栈内存空间，其各自的GC不会影响到其他`Isolate`的。所以我们可以通过把部分占用内存空间较大且生命周期较短的对象方法其他`Isolate`中，这样即使另外一个`Isolate` GC了，并不会对我们显示UI的`Isolate`造成影响。

[JVM vs Dart VM]()

`Isolate`带来的好处显而易见，我们无需考虑与`OC`、`Java`等语言的加锁操作，不会影响UI线程，但也带来了新的问题，`Isolate`间的数据如何共享？答案是`ReceivePort`。

`ReceivePort`：接收端口，用于建立Isolate间或与UI线程间的联系。

我们可以运行下面的代码看下使用`Isolate`前后的区别：

```dart
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
```

```dart
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
```



### 4. compute

`compute`实际上是`Isolate`的包装方法，简化了`Isolate`的操作，用于**一次性计算**

```dart
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
```

### 5. 使用场景

原则：如果一个处理流程需要几毫秒 => `Future`或`Stream`，如果一个处理流程需要几百毫秒 => `Isolate`或`compute`。实际上，如果应用没有明显的卡顿掉帧，你无需考虑`Isolate`与`compute`。

- Json解析：当解析一个庞大的 json时，建议使用`compute`
- 加密、信号处理：如果涉及计算密集型的数学操作，建议使用`compute`
- 图片或文件加载、解码、处理：耗时较多时，建议使用`Isolate`