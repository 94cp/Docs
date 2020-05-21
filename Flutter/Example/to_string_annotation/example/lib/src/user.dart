import 'package:to_string/to_string.dart';

part 'user.g.dart';

@toString
class User {
  final String name;
  final int age;

  User(this.name, this.age);

  @override
  String toString() {
    return _$UserToString(this);
  }
}