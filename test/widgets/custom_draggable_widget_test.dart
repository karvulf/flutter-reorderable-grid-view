import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenChild = Placeholder();
  const givenKey = Key('hello');

  Future<void> pumpWidget(
    WidgetTester tester, {
    Object? data,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDraggable(
              data: data,
              key: givenKey,
              child: givenChild,
            ),
          ),
        ),
      );

  testWidgets(
      'GIVEN child and key '
      'WHEN pumping [CustomDraggable] '
      'THEN should show given child', (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(tester);

    // then
    expect(find.byWidget(givenChild), findsOneWidget);
  });
}
