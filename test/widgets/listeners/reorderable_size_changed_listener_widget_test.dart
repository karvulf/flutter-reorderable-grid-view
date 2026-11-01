import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/listeners/reorderable_size_changed_listener.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_builder_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenChild = Text('child');

  Future<void> pumpWidget(
    WidgetTester tester, {
    double? size,
    double? width,
    double? height,
    VoidCallback? onSizeChanged,
    ReorderableBuilderType type = ReorderableBuilderType.children,
    Key? childKey,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width ?? size,
                height: height ?? size,
                child: ReorderableSizeChangedListener(
                  onSizeChanged: onSizeChanged ?? () {},
                  type: type,
                  childKey: childKey,
                  child: givenChild,
                ),
              ),
            ),
          ),
        ),
      );

  group('#constructor', () {
    testWidgets(
        "GIVEN ReorderableBuilderType.wrap and childKey "
        "WHEN pumping [ReorderableSizeChangedListener] "
        "THEN should have childKey as key", (WidgetTester tester) async {
      // given
      const givenChildKey = ValueKey('child');

      // when
      await pumpWidget(
        tester,
        size: 100,
        type: ReorderableBuilderType.wrap,
        childKey: givenChildKey,
      );

      // then
      final actual = tester.widget<ReorderableSizeChangedListener>(
        find.byType(ReorderableSizeChangedListener),
      );
      expect(actual.key, equals(const ValueKey<Key>(givenChildKey)));
    });

    testWidgets(
        "GIVEN ReorderableBuilderType.children and childKey "
        "WHEN pumping [ReorderableSizeChangedListener] "
        "THEN should have no key", (WidgetTester tester) async {
      // when
      await pumpWidget(
        tester,
        size: 100,
        type: ReorderableBuilderType.children,
        childKey: const ValueKey('child'),
      );

      // then
      final actual = tester.widget<ReorderableSizeChangedListener>(
        find.byType(ReorderableSizeChangedListener),
      );
      expect(actual.key, isNull);
    });

    testWidgets(
        "GIVEN ReorderableBuilderType.wrap without childKey "
        "WHEN pumping [ReorderableSizeChangedListener] "
        "THEN should have no key", (WidgetTester tester) async {
      // when
      await pumpWidget(
        tester,
        size: 100,
        type: ReorderableBuilderType.wrap,
      );

      // then
      final actual = tester.widget<ReorderableSizeChangedListener>(
        find.byType(ReorderableSizeChangedListener),
      );
      expect(actual.key, isNull);
    });
  });

  group('#ReorderableBuilderType.children', () {
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
  });

  group('#ReorderableBuilderType.wrap', () {
    testWidgets(
        "GIVEN pumped [ReorderableSizeChangedListener] around all children "
        "WHEN updating with a different height "
        "THEN should not call onSizeChanged", (WidgetTester tester) async {
      // given
      var actualCallCount = 0;
      await pumpWidget(
        tester,
        width: 100,
        height: 100,
        type: ReorderableBuilderType.wrap,
        onSizeChanged: () => actualCallCount++,
      );

      // when
      await pumpWidget(
        tester,
        width: 100,
        height: 50,
        type: ReorderableBuilderType.wrap,
        onSizeChanged: () => actualCallCount++,
      );

      // then
      expect(actualCallCount, equals(0));
    });

    testWidgets(
        "GIVEN pumped [ReorderableSizeChangedListener] around all children "
        "WHEN updating with a different width "
        "THEN should call onSizeChanged once", (WidgetTester tester) async {
      // given
      var actualCallCount = 0;
      await pumpWidget(
        tester,
        width: 100,
        height: 100,
        type: ReorderableBuilderType.wrap,
        onSizeChanged: () => actualCallCount++,
      );

      // when
      await pumpWidget(
        tester,
        width: 50,
        height: 100,
        type: ReorderableBuilderType.wrap,
        onSizeChanged: () => actualCallCount++,
      );

      // then
      expect(actualCallCount, equals(1));
    });

    testWidgets(
        "GIVEN pumped [ReorderableSizeChangedListener] around a single child "
        "WHEN updating with a different height "
        "THEN should call onSizeChanged once", (WidgetTester tester) async {
      // given
      var actualCallCount = 0;
      await pumpWidget(
        tester,
        width: 100,
        height: 100,
        type: ReorderableBuilderType.wrap,
        childKey: const ValueKey('child'),
        onSizeChanged: () => actualCallCount++,
      );

      // when
      await pumpWidget(
        tester,
        width: 100,
        height: 50,
        type: ReorderableBuilderType.wrap,
        childKey: const ValueKey('child'),
        onSizeChanged: () => actualCallCount++,
      );

      // then
      expect(actualCallCount, equals(1));
    });
  });
}
