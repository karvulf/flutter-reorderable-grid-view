import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_size_changed_listener.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenChild = Text('child');

  Future<void> pumpWidget(
    WidgetTester tester, {
    required double size,
    VoidCallback? onSizeChanged,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox.square(
                dimension: size,
                child: ReorderableSizeChangedListener(
                  onSizeChanged: onSizeChanged ?? () {},
                  child: givenChild,
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets(
      "GIVEN child "
      "WHEN pumping [ReorderableSizeChangedListener] "
      "THEN should show expected widgets", (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(
      tester,
      size: 100,
    );

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ReorderableSizeChangedListener &&
            widget.child == givenChild,
      ),
      findsOneWidget,
    );
  });

  testWidgets(
      "GIVEN pumped [ReorderableSizeChangedListener] "
      "WHEN updating with the same size "
      "THEN should not call onSizeChanged", (WidgetTester tester) async {
    // given
    var actualCallCount = 0;
    await pumpWidget(
      tester,
      size: 100,
      onSizeChanged: () => actualCallCount++,
    );

    // when
    await pumpWidget(
      tester,
      size: 100,
      onSizeChanged: () => actualCallCount++,
    );

    // then
    expect(actualCallCount, equals(0));
  });

  testWidgets(
      "GIVEN pumped [ReorderableSizeChangedListener] "
      "WHEN updating with a different size "
      "THEN should call onSizeChanged once", (WidgetTester tester) async {
    // given
    var actualCallCount = 0;
    await pumpWidget(
      tester,
      size: 100,
      onSizeChanged: () => actualCallCount++,
    );

    // when
    await pumpWidget(
      tester,
      size: 50,
      onSizeChanged: () => actualCallCount++,
    );

    // then
    expect(actualCallCount, equals(1));
  });
}
