## Annotation

**注解** ：也叫元数据，一种代码级标注。类似`Java`注解，可以作用于编译时或运行时，但由于`Flutter`目前不支持运行时的反射功能（`Dart`本身支持），仅能利用注解技术在编译期做一些生成文档、编译检查、生成代码的工作。

### 1. 内置注解

**Dart内置的3个编译检查的注解**

- @deprecated：标注类、方法、属性已过时
- @override：标注重写方法
- @required：标注参数必须传入

**Flutter内置的3个生成Document文档的注解**

- @Category：标注该类的类别
- @DocumentationIcon：标注表示该类的图片
- @Summary：标注对该类的简短描述

### 2. 注释 与 注解 的区别

- 注释：用于提高代码的可读性，也就是说，注释是给人看的。
- 注解：可以看做是注释的“强力升级版”，主要是向编译器、虚拟机等解释说明一些事情。

### 3. 开源应用

- [json_serializable](https://github.com/dart-lang/json_serializable)：json序列化库
- [annotation_route](https://github.com/alibaba-flutter/annotation_route)：闲鱼团队开源的路由映射库

原理：通过 `source_gen` 拦截注解，并分析其语法结构，最后动态生成代码。

[source_gen](https://github.com/dart-lang/source_gen)： 基于 `analyzer` 和 `build` 库。 build库主要是资源文件的处理，analyser库是对dart文件生成语法结构，source_gen主要是处理dart源码，可以通过注解生成代码。

### 4. 实战演练

接下来，我们将通过自定义一个**toString**注解来了解**annotation**的高级特性。

项目结构：
```dart
to_string_annotation
	> example					 		// toString注解示例工程（下面2个工程的使用示例）
	> to_string				 		// toString注解类工程（基础包，声明注解）
	> to_string_generator	// toString注解拦截、代码生成器工程（构建包，用于运行命令行自动生成代码）
```

#### 4.1. to_string工程

声明toString注解

```dart
library to_string;

class ToString {
  const ToString(); // 注解的构造方法必须使用const关键字申明
}

const toString = ToString(); // 实例化，用于注解简写@toString，否则要用@ToString()
```

#### 4.2. to_string_generator工程

在`pubspec.yaml`中添加对 `build`、`source_gen`和上面的`to_string`包的依赖

```yaml
dependencies:
  build: ^1.2.2
  source_gen: ^0.9.5
  to_string:
    path: ../to_string/
```

实现`toString`注解生成器

```dart
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:to_string/to_string.dart';

class ToStringGenerator extends GeneratorForAnnotation<ToString> {

  const ToStringGenerator();

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    assert(!(element is ClassElement)); // toString注解仅支持类元素

    final clazz = element as ClassElement;

    final clazzName = clazz.displayName;
    final fields = clazz.fields;

    final fieldKeyValues = fields.map((field) => "${field.displayName}: \${obj.${field.displayName}}");

    // 拼接toString注解自动生成的代码
    final toStringBuffer = StringBuffer();
    toStringBuffer.write("String _\$${clazzName}ToString(${clazzName} obj) {");
    toStringBuffer.write("return \"${clazzName}{${fieldKeyValues.join(", ")}}\";");
    toStringBuffer.write("}");
    
    return toStringBuffer.toString();
  }
  
}
```

在lib目录下添加`builder.dart`文件

```dart
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:to_string_generator/src/to_string_generator.dart';

Builder toString(BuilderOptions options) =>
    SharedPartBuilder([const ToStringGenerator()], 'to_string');
```

在根目录下添加`build.yaml`文件

```yaml
targets:
  $default: #定义目标库，关键字$default默认为当前库
    builders: #构建的两个库
      to_string|to_string_generator:
        enabled: true #可选，是否将构建器应用于此目标

builders:
  to_string:
    target: ":to_string_generator" #目标库
    import: "package:to_string_generator/builder.dart" #build文件
    builder_factories: ["toString"] #build文件中对应的方法
    build_extensions: {".dart": [".to_string.g.part"]}
    auto_apply: dependents #将此Builder应用于包，直接依赖于公开构建起的包
    build_to: cache #输出转到隐藏的构建缓存，不会发布
    applies_builders: ["source_gen|combining_builder"] #指定是否可以延迟运行构建器
```

`build.yaml`具体参数见https://github.com/dart-lang/build/blob/master/build_config/README.md

#### 4.3. example工程

在`pubspec.yaml`中添加对 `to_string`、`build_runner`、`to_string_generator`包的依赖

```yaml
dependencies:
  to_string:
    path: ../to_string

dev_dependencies:
  build_runner: ^1.8.0
  to_string_generator:
    path: ../to_string_generator
    
# to_string_generator包仅需添加到开发依赖中，这也就是我们为什么要拆成 to_string 和 to_string_generator 两个工程的原因了。
```

下面我们声明一个`User.dart`类来验证`toString`注解功能

```dart
import 'package:to_string/to_string.dart';

part 'user.g.dart'; // 警告

@toString
class User {
  final String name;
  final int age;

  User(this.name, this.age);

  @override
  String toString() {
    return _$UserToString(this); // 警告
  }
}
```

首次创建类时会有如上2处警告，这是正常现象。因为我们还没有为`toString`注解自动生成代码。

**一次性生成代码命令**

`flutter packages pub run build_runner build ` 
上述命令需要我们在更改User模型时都要手动运行构建命令，才能生成代码

**持续生成代码命令**

`flutter packages pub run build_runner watch`
上述命令会监视我们项目中文件的变化，并在需要时自动构建必要的文件

**自动生成的`user.g.dart`文件如下**

```dart
part of 'user.dart';

String _$UserToString(User obj) {
  return "User{name: ${obj.name}, age: ${obj.age}}";
}
```

**详见[to_string_annotation](https://github.com/cp110/Docs/tree/master/Flutter/Example/to_string_annotation)**

### 5. 总结

通过上述讲解，相信大家已经发现了`Annotation`可以用于减少模板化代码的编写。我们可以应用在网络请求、数据解析、SQL、获取资源(类似ButterKnife等)、路由映射等模板化代码中，简化使用，降低代码量，提高工作效率。
