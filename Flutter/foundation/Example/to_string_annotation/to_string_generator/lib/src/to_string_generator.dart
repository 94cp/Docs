import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:to_string/to_string.dart';

class ToStringGenerator extends GeneratorForAnnotation<ToString> {

  const ToStringGenerator();

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    assert(!(element is ClassElement));

    final clazz = element as ClassElement;

    final clazzName = clazz.displayName;
    final fields = clazz.fields;

    final fieldKeyValues = fields.map((field) => "${field.displayName}: \${obj.${field.displayName}}");

    // 生成类似👇的代码
    // String _$UserToString(User obj) {
    //   return "User{name: ${obj.name}, age: ${obj.age}}";
    // }
    final toStringBuffer = StringBuffer();
    toStringBuffer.write("String _\$${clazzName}ToString(${clazzName} obj) {");
    toStringBuffer.write("return \"${clazzName}{${fieldKeyValues.join(", ")}}\";");
    toStringBuffer.write("}");

//    return "/*" + toStringBuffer.toString() + "*/";
    return toStringBuffer.toString();
  }

}