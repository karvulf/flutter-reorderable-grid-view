import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

T findWidget<T>() {
  return find.byType(T).evaluate().first.widget as T;
}

/// Pumps [child] inside a [MaterialApp] and waits until all animations ended.
Future<void> pumpWidgetWithMaterialApp(
  WidgetTester tester, {
  required Widget child,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}
