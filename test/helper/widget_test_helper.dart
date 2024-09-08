import 'package:flutter_test/flutter_test.dart';

T findWidget<T>() {
  return find.byType(T).evaluate().first.widget as T;
}
