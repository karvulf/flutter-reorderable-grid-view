import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helper/widget_test_helper.dart';

/// Complete drag and drop flows as a user would do them.
void main() {
  const givenItems = [0, 1, 2, 3, 4, 5];
  const givenGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,
  );

  late List<int> actualItems;

  setUp(() {
    actualItems = givenItems;
  });

  /// Returns the shown position of the child of [item].
  Offset getOffset(WidgetTester tester, int item) =>
      tester.getTopLeft(find.byKey(Key('$item')).last);

  /// Drags the child of [item] to [position] and releases it.
  Future<void> dragAndRelease(
    WidgetTester tester, {
    required int item,
    required Offset position,
  }) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(Key('$item'))),
      pointer: 7,
    );
    await tester.pump(kLongPressTimeout);
    await tester.pumpAndSettle();
    await gesture.moveTo(position);
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();
  }

  group('#GridView', () {
    Widget buildChild(int item) => ColoredBox(
          key: Key('$item'),
          color: Colors.lightBlue,
        );

    Future<void> pumpWidget(
      WidgetTester tester, {
      required Widget Function(List<Widget> children) builder,
      List<int> lockedIndices = const [],
      ScrollController? scrollController,
    }) =>
        pumpWidgetWithMaterialApp(
          tester,
          child: ReorderableBuilder<int>(
            lockedIndices: lockedIndices,
            scrollController: scrollController,
            onReorder: (reorder) => actualItems = reorder(actualItems),
            builder: builder,
            children: [for (final item in givenItems) buildChild(item)],
          ),
        );

    testWidgets(
        'GIVEN [GridView] '
        'WHEN dragging the first child below all children and releasing it '
        'THEN should move it to the last position',
        (WidgetTester tester) async {
      // given
      await pumpWidget(
        tester,
        builder: (children) => GridView(
          gridDelegate: givenGridDelegate,
          children: children,
        ),
      );

      // when
      await dragAndRelease(tester, item: 0, position: const Offset(100, 550));

      // then
      expect(actualItems, equals(const [1, 2, 3, 4, 5, 0]));
    });

    testWidgets(
        'GIVEN [GridView] with top padding and locked first index '
        'WHEN dragging the last child above all children and releasing it '
        'THEN should move it to the first unlocked position',
        (WidgetTester tester) async {
      // given
      await pumpWidget(
        tester,
        lockedIndices: const [0],
        builder: (children) => GridView(
          padding: const EdgeInsets.only(top: 100),
          gridDelegate: givenGridDelegate,
          children: children,
        ),
      );

      // when
      await dragAndRelease(tester, item: 5, position: const Offset(300, 20));

      // then
      expect(actualItems, equals(const [0, 5, 1, 2, 3, 4]));
    });

    testWidgets(
        'GIVEN horizontal [GridView] '
        'WHEN dragging the first child right of all children and releasing it '
        'THEN should move it to the last position',
        (WidgetTester tester) async {
      // given
      final givenScrollController = ScrollController();
      final givenGridViewKey = GlobalKey();
      await pumpWidget(
        tester,
        scrollController: givenScrollController,
        builder: (children) => GridView(
          key: givenGridViewKey,
          controller: givenScrollController,
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          children: children,
        ),
      );

      // when
      await dragAndRelease(tester, item: 0, position: const Offset(750, 100));

      // then
      expect(actualItems, equals(const [1, 2, 3, 4, 5, 0]));
    });

    testWidgets(
        'GIVEN [GridView.count] '
        'WHEN dragging the first child below all children and releasing it '
        'THEN should move it to the last position',
        (WidgetTester tester) async {
      // given
      await pumpWidget(
        tester,
        builder: (children) => GridView.count(
          crossAxisCount: 4,
          children: children,
        ),
      );

      // when
      await dragAndRelease(tester, item: 0, position: const Offset(100, 550));

      // then
      expect(actualItems, equals(const [1, 2, 3, 4, 5, 0]));
    });

    testWidgets(
        'GIVEN [GridView.extent] '
        'WHEN dragging the first child below all children and releasing it '
        'THEN should move it to the last position',
        (WidgetTester tester) async {
      // given
      await pumpWidget(
        tester,
        builder: (children) => GridView.extent(
          maxCrossAxisExtent: 200,
          children: children,
        ),
      );

      // when
      await dragAndRelease(tester, item: 0, position: const Offset(100, 550));

      // then
      expect(actualItems, equals(const [1, 2, 3, 4, 5, 0]));
    });
  });

  group('#GridView.builder', () {
    testWidgets(
        'GIVEN [ReorderableBuilder.builder] with [GridView.builder] '
        'WHEN dragging the first child below all children and releasing it '
        'THEN should move it to the last position',
        (WidgetTester tester) async {
      // given
      final givenScrollController = ScrollController();
      final givenGridViewKey = GlobalKey();
      await pumpWidgetWithMaterialApp(
        tester,
        child: ReorderableBuilder<int>.builder(
          scrollController: givenScrollController,
          itemCount: givenItems.length,
          onReorder: (reorder) => actualItems = reorder(actualItems),
          childBuilder: (itemBuilder) => GridView.builder(
            key: givenGridViewKey,
            controller: givenScrollController,
            itemCount: givenItems.length,
            gridDelegate: givenGridDelegate,
            itemBuilder: (context, index) => itemBuilder(
              ColoredBox(key: Key('$index'), color: Colors.lightBlue),
              index,
            ),
          ),
        ),
      );

      // when
      await dragAndRelease(tester, item: 0, position: const Offset(100, 550));

      // then
      expect(actualItems, equals(const [1, 2, 3, 4, 5, 0]));
    });
  });

  /// The children have widths of 60, 100, 140, 180, 60, 100 and are laid out
  /// in a 400 wide [Wrap] with spacing 8 and runSpacing 4:
  ///
  /// ```
  /// [0][ 1 ][  2  ]
  /// [   3   ][4][ 5 ]
  /// ```
  group('#Wrap', () {
    late StateSetter setItems;
    final actualUpdatedIndices = <int>[];

    setUp(() {
      actualUpdatedIndices.clear();
      final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views;
      view.first.physicalSize = const Size(400.0, 800.0);
      view.first.devicePixelRatio = 1.0;
    });

    tearDown(() {
      final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views;
      view.first.resetPhysicalSize();
      view.first.resetDevicePixelRatio();
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      List<int> lockedIndices = const [],
      WrapAlignment alignment = WrapAlignment.start,
    }) =>
        pumpWidgetWithMaterialApp(
          tester,
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                setItems = setState;
                return ReorderableBuilder<int>.wrap(
                  lockedIndices: lockedIndices,
                  onReorder: (reorder) =>
                      setState(() => actualItems = reorder(actualItems)),
                  onUpdatedDraggedChild: actualUpdatedIndices.add,
                  builder: (children) => Wrap(
                    alignment: alignment,
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: children,
                  ),
                  children: [
                    for (final item in actualItems)
                      SizedBox(
                        key: Key('$item'),
                        width: 60.0 + (item % 4) * 40.0,
                        height: 50.0,
                        child: const ColoredBox(color: Colors.lightBlue),
                      ),
                  ],
                );
              },
            ),
          ),
        );

    /// Starts dragging the child of [item] after a long press.
    Future<TestGesture> startDrag(WidgetTester tester, int item) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(Key('$item'))),
        pointer: 7,
      );
      await tester.pump(kLongPressTimeout);
      await tester.pumpAndSettle();
      return gesture;
    }

    testWidgets(
        'GIVEN [ReorderableBuilder.wrap] '
        'WHEN dragging the first child onto the fourth child '
        'THEN should exchange both and move the others to make space',
        (WidgetTester tester) async {
      // given
      await pumpWidget(tester);

      // when
      final gesture = await startDrag(tester, 0);
      await gesture.moveTo(tester.getCenter(find.byKey(const Key('3'))));
      await tester.pumpAndSettle();

      // then
      expect(getOffset(tester, 3), equals(const Offset(0, 0)));
      expect(getOffset(tester, 1), equals(const Offset(188, 0)));
      expect(getOffset(tester, 2), equals(const Offset(0, 54)));
      expect(getOffset(tester, 4), equals(const Offset(216, 54)));
      expect(getOffset(tester, 5), equals(const Offset(284, 54)));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'GIVEN [ReorderableBuilder.wrap] '
        'WHEN releasing the first child on the fourth child '
        'THEN should reorder both and show them at their new position',
        (WidgetTester tester) async {
      // given
      await pumpWidget(tester);

      // when
      await dragAndRelease(
        tester,
        item: 0,
        position: tester.getCenter(find.byKey(const Key('3'))),
      );

      // then
      expect(actualItems, equals(const [3, 1, 2, 0, 4, 5]));
      expect(getOffset(tester, 3), equals(const Offset(0, 0)));
      expect(getOffset(tester, 0), equals(const Offset(148, 54)));
    });

    testWidgets(
        'GIVEN [ReorderableBuilder.wrap] '
        'WHEN dragging the small fifth child over the wide fourth child '
        'THEN should exchange them once without trembling',
        (WidgetTester tester) async {
      // given
      await pumpWidget(tester);
      final givenWideChildCenter = tester.getCenter(find.byKey(const Key('3')));

      // when
      final gesture = await startDrag(tester, 4);
      await gesture.moveTo(givenWideChildCenter);
      await tester.pump();
      await gesture.moveTo(givenWideChildCenter + const Offset(4, 0));
      await tester.pump();
      await gesture.moveTo(givenWideChildCenter + const Offset(8, 0));
      await tester.pump();

      // then
      expect(actualUpdatedIndices, equals(const [3]));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'GIVEN [ReorderableBuilder.wrap] with locked fourth child '
        'WHEN releasing the first child on the locked child '
        'THEN should not reorder the children', (WidgetTester tester) async {
      // given
      await pumpWidget(tester, lockedIndices: const [3]);

      // when
      await dragAndRelease(
        tester,
        item: 0,
        position: tester.getCenter(find.byKey(const Key('3'))),
      );

      // then
      expect(actualItems, equals(givenItems));
    });

    testWidgets(
        'GIVEN [ReorderableBuilder.wrap] with an already reordered child '
        'WHEN reordering it a second time '
        'THEN should show all children at their new position',
        (WidgetTester tester) async {
      // given
      await pumpWidget(tester);
      await dragAndRelease(
        tester,
        item: 0,
        position: tester.getCenter(find.byKey(const Key('3'))),
      );

      // when
      await dragAndRelease(
        tester,
        item: 0,
        position: tester.getCenter(find.byKey(const Key('1'))),
      );

      // then
      expect(actualItems, equals(const [3, 0, 2, 1, 4, 5]));
      expect(getOffset(tester, 3), equals(const Offset(0, 0)));
      expect(getOffset(tester, 0), equals(const Offset(188, 0)));
      expect(getOffset(tester, 2), equals(const Offset(256, 0)));
      expect(getOffset(tester, 1), equals(const Offset(0, 54)));
      expect(getOffset(tester, 4), equals(const Offset(108, 54)));
      expect(getOffset(tester, 5), equals(const Offset(176, 54)));
    });

    testWidgets(
        'GIVEN [ReorderableBuilder.wrap] '
        'WHEN removing the first child '
        'THEN should animate the third child to its new position',
        (WidgetTester tester) async {
      // given
      await pumpWidget(tester);

      // when
      setItems(() => actualItems = const [1, 2, 3, 4, 5]);
      await tester.pump();
      // after the fade out of the removed child and before the end
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      // then: on its way from 176 to 108
      expect(getOffset(tester, 2).dx, lessThan(176));
      expect(getOffset(tester, 2).dx, greaterThan(108));

      await tester.pumpAndSettle();
      expect(getOffset(tester, 2), equals(const Offset(108, 0)));
    });

    testWidgets(
        'GIVEN [ReorderableBuilder.wrap] '
        'WHEN removing all children at once '
        'THEN should not clip the removed children while fading out',
        (WidgetTester tester) async {
      // given
      await pumpWidget(tester);
      const givenRectOfFourthChild = Rect.fromLTWH(0, 54, 180, 50);

      // when
      setItems(() => actualItems = const []);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // then
      final actualVisibleArea = tester.getRect(
        find.byType(ReorderableBuilder<int>),
      );
      expect(
        actualVisibleArea.intersect(givenRectOfFourthChild),
        equals(givenRectOfFourthChild),
      );

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('3')), findsNothing);
    });

    testWidgets(
        'GIVEN [ReorderableBuilder.wrap] without children '
        'WHEN adding children while the others are still moving and '
        'dragging one onto another '
        'THEN should show all children at the right position',
        (WidgetTester tester) async {
      // given
      await pumpWidget(tester);
      setItems(() => actualItems = []);
      await tester.pumpAndSettle();

      // when: adding a child every 128 ms with real frames of 16 ms
      for (var item = 100; item <= 112; item++) {
        setItems(() => actualItems.insert(0, item));
        for (var frame = 0; frame < 8; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
      }
      await tester.pumpAndSettle();
      final gesture = await startDrag(tester, 109);
      await gesture.moveTo(tester.getCenter(find.byKey(const Key('107'))));
      await tester.pumpAndSettle();

      // then: 109 and 107 are exchanged
      expect(getOffset(tester, 112), equals(const Offset(0, 0)));
      expect(getOffset(tester, 111), equals(const Offset(68, 0)));
      expect(getOffset(tester, 110), equals(const Offset(256, 0)));
      expect(getOffset(tester, 107), equals(const Offset(0, 54)));
      expect(getOffset(tester, 108), equals(const Offset(188, 54)));
      expect(getOffset(tester, 106), equals(const Offset(0, 108)));
      expect(getOffset(tester, 105), equals(const Offset(148, 108)));
      expect(getOffset(tester, 104), equals(const Offset(256, 108)));
      expect(getOffset(tester, 103), equals(const Offset(0, 162)));
      expect(getOffset(tester, 102), equals(const Offset(188, 162)));
      expect(getOffset(tester, 101), equals(const Offset(0, 216)));
      expect(getOffset(tester, 100), equals(const Offset(108, 216)));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'GIVEN [ReorderableBuilder.wrap] '
        'WHEN dragging the first child below all children and releasing it '
        'THEN should move it to the last position',
        (WidgetTester tester) async {
      // given
      await pumpWidget(tester);

      // when
      await dragAndRelease(tester, item: 0, position: const Offset(100, 700));

      // then
      expect(actualItems, equals(const [1, 2, 3, 4, 5, 0]));
    });

    testWidgets(
        'GIVEN [ReorderableBuilder.wrap] with a centered [Wrap] '
        'WHEN dragging a child onto another child '
        'THEN should throw AssertionError because it is not supported',
        (WidgetTester tester) async {
      // given
      await pumpWidget(tester, alignment: WrapAlignment.center);

      // when
      final gesture = await startDrag(tester, 0);
      await gesture.moveTo(tester.getCenter(find.byKey(const Key('1'))));

      // then
      expect(tester.takeException(), isAssertionError);

      await gesture.up();
    });
  });
}
