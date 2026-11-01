import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderWrap;
import 'package:flutter_reorderable_grid_view/controller/reorderable_wrap_controller.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_test/flutter_test.dart';

/// Complete drag and drop flows as a user would do them.
void main() {
  const givenDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,
  );

  List<int> givenItems(int count) => List.generate(count, (index) => index);

  Widget buildChild(int item) => ColoredBox(
        key: Key(item.toString()),
        color: Colors.lightBlue,
      );

  /// Drags the child of [item] to [position] and releases it.
  Future<void> dragAndRelease(
    WidgetTester tester, {
    required int item,
    required Offset position,
  }) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(Key(item.toString()))),
      pointer: 7,
    );
    await tester.pump(kLongPressTimeout);
    await tester.pumpAndSettle();

    await gesture.moveTo(position);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }

  /// Pumps [ReorderableBuilder] with [items] and returns the reordered items.
  ///
  /// [gridBuilder] receives the wrapped children for the GridView.
  Future<List<int> Function()> pumpReorderableBuilder(
    WidgetTester tester, {
    required List<int> items,
    required Widget Function(List<Widget> children) gridBuilder,
    List<int> lockedIndices = const [],
    ScrollController? scrollController,
  }) async {
    var updatedItems = items;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReorderableBuilder<int>(
            lockedIndices: lockedIndices,
            scrollController: scrollController,
            onReorder: (reorder) => updatedItems = reorder(updatedItems),
            builder: gridBuilder,
            children: [for (final item in items) buildChild(item)],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return () => updatedItems;
  }

  testWidgets(
      'GIVEN GridView '
      'WHEN dragging first child below all children and releasing it '
      'THEN should move it to the last position', (WidgetTester tester) async {
    // given
    final getItems = await pumpReorderableBuilder(
      tester,
      items: givenItems(6),
      gridBuilder: (children) => GridView(
        gridDelegate: givenDelegate,
        children: children,
      ),
    );

    // when
    await dragAndRelease(tester, item: 0, position: const Offset(100, 550));

    // then
    expect(getItems(), equals([1, 2, 3, 4, 5, 0]));
  });

  testWidgets(
      'GIVEN GridView.count '
      'WHEN dragging first child below all children and releasing it '
      'THEN should move it to the last position', (WidgetTester tester) async {
    // given
    final getItems = await pumpReorderableBuilder(
      tester,
      items: givenItems(6),
      gridBuilder: (children) => GridView.count(
        crossAxisCount: 4,
        children: children,
      ),
    );

    // when
    await dragAndRelease(tester, item: 0, position: const Offset(100, 550));

    // then
    expect(getItems(), equals([1, 2, 3, 4, 5, 0]));
  });

  testWidgets(
      'GIVEN GridView.extent '
      'WHEN dragging first child below all children and releasing it '
      'THEN should move it to the last position', (WidgetTester tester) async {
    // given
    final getItems = await pumpReorderableBuilder(
      tester,
      items: givenItems(6),
      gridBuilder: (children) => GridView.extent(
        maxCrossAxisExtent: 200,
        children: children,
      ),
    );

    // when
    await dragAndRelease(tester, item: 0, position: const Offset(100, 550));

    // then
    expect(getItems(), equals([1, 2, 3, 4, 5, 0]));
  });

  testWidgets(
      'GIVEN ReorderableBuilder.builder with GridView.builder '
      'WHEN dragging first child below all children and releasing it '
      'THEN should move it to the last position', (WidgetTester tester) async {
    // given
    var items = givenItems(6);
    final givenScrollController = ScrollController();
    final givenGridViewKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReorderableBuilder<int>.builder(
            scrollController: givenScrollController,
            itemCount: items.length,
            onReorder: (reorder) => items = reorder(items),
            childBuilder: (itemBuilder) => GridView.builder(
              key: givenGridViewKey,
              controller: givenScrollController,
              itemCount: items.length,
              gridDelegate: givenDelegate,
              itemBuilder: (context, index) => itemBuilder(
                buildChild(items[index]),
                index,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // when
    await dragAndRelease(tester, item: 0, position: const Offset(100, 550));

    // then
    expect(items, equals([1, 2, 3, 4, 5, 0]));
  });

  testWidgets(
      'GIVEN GridView with top padding and locked first index '
      'WHEN dragging last child above all children and releasing it '
      'THEN should move it to the first unlocked position',
      (WidgetTester tester) async {
    // given
    final getItems = await pumpReorderableBuilder(
      tester,
      items: givenItems(6),
      lockedIndices: const [0],
      gridBuilder: (children) => GridView(
        padding: const EdgeInsets.only(top: 100),
        gridDelegate: givenDelegate,
        children: children,
      ),
    );

    // when
    await dragAndRelease(tester, item: 5, position: const Offset(300, 20));

    // then
    expect(getItems(), equals([0, 5, 1, 2, 3, 4]));
  });

  testWidgets(
      'GIVEN horizontal GridView '
      'WHEN dragging first child right of all children and releasing it '
      'THEN should move it to the last position', (WidgetTester tester) async {
    // given
    final givenScrollController = ScrollController();
    final givenGridViewKey = GlobalKey();
    final getItems = await pumpReorderableBuilder(
      tester,
      items: givenItems(4),
      scrollController: givenScrollController,
      gridBuilder: (children) => GridView(
        key: givenGridViewKey,
        controller: givenScrollController,
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        children: children,
      ),
    );

    // when
    await dragAndRelease(tester, item: 0, position: const Offset(750, 100));

    // then
    expect(getItems(), equals([1, 2, 3, 0]));
  });

  group('#ReorderableBuilder.wrap', () {
    const givenWidths = [60.0, 180.0, 100.0, 140.0, 60.0, 180.0];
    const givenSpacing = 8.0;
    const givenRunSpacing = 4.0;

    Widget buildWrapChild(int item) => SizedBox(
          key: Key(item.toString()),
          width: givenWidths[item],
          height: 50.0,
          child: const ColoredBox(color: Colors.lightBlue),
        );

    /// Returns the rects of [items] laid out by a real [Wrap] in this order.
    Future<Map<int, Rect>> layoutRealWrap(
      WidgetTester tester,
      List<int> items,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Wrap(
              spacing: givenSpacing,
              runSpacing: givenRunSpacing,
              children: [for (final item in items) buildWrapChild(item)],
            ),
          ),
        ),
      );
      return {
        for (final item in items)
          item: tester.getRect(find.byKey(Key(item.toString()))),
      };
    }

    setUp(() {
      final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views;
      view.first.physicalSize = const Size(400.0, 800.0);
      view.first.devicePixelRatio = 1.0;
    });

    tearDown(() {
      final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views;
      view.first.resetPhysicalSize();
      view.first.resetDevicePixelRatio();
    });

    testWidgets(
        'GIVEN children with different widths '
        'WHEN dragging first child onto the fourth child '
        'THEN should exchange both and show all children like a Wrap in the '
        'new order and '
        'reorder them after releasing', (WidgetTester tester) async {
      // given
      const expectedItems = [3, 1, 2, 0, 4, 5];
      final expectedRects = await layoutRealWrap(tester, expectedItems);

      var items = givenItems(6);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableBuilder<int>.wrap(
              onReorder: (reorder) => items = reorder(items),
              builder: (children) => Wrap(
                spacing: givenSpacing,
                runSpacing: givenRunSpacing,
                children: children,
              ),
              children: [for (final item in items) buildWrapChild(item)],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // when
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('0'))),
        pointer: 7,
      );
      await tester.pump(kLongPressTimeout);
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(find.byKey(const Key('3'))));
      await tester.pumpAndSettle();

      // then
      for (final item in [1, 2, 3, 4, 5]) {
        final actualRect = tester.getRect(find.byKey(Key('$item')).last);
        expect(actualRect, equals(expectedRects[item]), reason: 'item $item');
      }

      // when
      await gesture.up();
      await tester.pumpAndSettle();

      // then
      expect(items, equals(expectedItems));
    });

    testWidgets(
        'GIVEN small child before a wide child '
        'WHEN dragging the small child to the middle of the wide child and '
        'moving a bit within it '
        'THEN should move it once without trembling and move it back after '
        'leaving and entering the wide child again',
        (WidgetTester tester) async {
      // given
      final givenItems = [0, 1, 2];
      final actualUpdatedIndices = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableBuilder<int>.wrap(
              onReorder: (_) {},
              onUpdatedDraggedChild: actualUpdatedIndices.add,
              builder: (children) => Wrap(
                spacing: givenSpacing,
                runSpacing: givenRunSpacing,
                children: children,
              ),
              children: [for (final item in givenItems) buildWrapChild(item)],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final wideChildCenter = tester.getCenter(find.byKey(const Key('1')));

      // when
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('0'))),
        pointer: 7,
      );
      await tester.pump(kLongPressTimeout);
      await tester.pumpAndSettle();
      for (var dx = 0.0; dx < 10.0; dx += 2.0) {
        await gesture.moveTo(wideChildCenter + Offset(dx, 0.0));
        await tester.pump();
      }

      // then
      expect(actualUpdatedIndices, equals([1]));

      // when leaving the wide child onto the new position of the small child
      // and entering the wide child again
      await gesture.moveTo(wideChildCenter + const Offset(52.0, 0.0));
      await tester.pump();
      await gesture.moveTo(wideChildCenter);
      await tester.pump();

      // then
      expect(actualUpdatedIndices, equals([1, 0]));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'GIVEN children like in the example app with locked indices '
        'WHEN dragging the second child onto the fourth child, the locked '
        'fifth child and the sixth child '
        'THEN should exchange it with the fourth and sixth child and never '
        'change the index of the locked children', (WidgetTester tester) async {
      // given
      var items = List.generate(7, (index) => index);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            // 350 wide like the example app on a phone
            body: Padding(
              padding: const EdgeInsets.only(right: 50.0),
              child: StatefulBuilder(
                builder: (context, setState) => ReorderableBuilder<int>.wrap(
                  lockedIndices: const [0, 4],
                  onReorder: (reorder) =>
                      setState(() => items = reorder(items)),
                  builder: (children) => Wrap(
                    spacing: givenSpacing,
                    runSpacing: givenRunSpacing,
                    children: children,
                  ),
                  children: [
                    for (final item in items)
                      SizedBox(
                        key: Key('$item'),
                        width: 60.0 + (item % 4) * 40.0,
                        height: 50.0,
                        child: const ColoredBox(color: Colors.lightBlue),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> dragAndRelease(int item, int targetItem) async {
        final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(Key('$item'))),
          pointer: 7,
        );
        await tester.pump(kLongPressTimeout);
        await tester.pumpAndSettle();
        await gesture.moveTo(tester.getCenter(find.byKey(Key('$targetItem'))));
        await tester.pumpAndSettle();
        await gesture.up();
        await tester.pumpAndSettle();
      }

      // when
      await dragAndRelease(1, 3);

      // then the following children moved to make space
      expect(items, equals(const [0, 3, 2, 1, 4, 5, 6]));

      // when
      await dragAndRelease(1, 4);

      // then
      expect(items, equals(const [0, 3, 2, 1, 4, 5, 6]));

      // when
      await dragAndRelease(1, 5);

      // then
      expect(items, equals(const [0, 3, 2, 5, 4, 1, 6]));
    });

    testWidgets(
        'GIVEN children with different widths and an app updating them '
        'WHEN moving children and releasing them twice '
        'THEN should show all children like a Wrap in the new order '
        'after every drop', (WidgetTester tester) async {
      // given
      var items = givenItems(6);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => ReorderableBuilder<int>.wrap(
                onReorder: (reorder) => setState(() => items = reorder(items)),
                builder: (children) => Wrap(
                  spacing: givenSpacing,
                  runSpacing: givenRunSpacing,
                  children: children,
                ),
                children: [for (final item in items) buildWrapChild(item)],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      /// Returns the rects of [order] like a Wrap at the top left lays them out.
      Map<int, Rect> getExpectedRects(List<int> order) {
        final sizes = [for (final item in order) Size(givenWidths[item], 50)];
        final offsets = ReorderableWrapController().calculateWrapOffsets(
          sizes: sizes,
          renderWrap: tester.renderObject<RenderWrap>(find.byType(Wrap)),
        );
        return {
          for (final (index, item) in order.indexed)
            item: offsets[index] & sizes[index],
        };
      }

      /// Drags [item] onto [targetItem] and releases it.
      Future<void> dragAndRelease(int item, int targetItem) async {
        final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(Key('$item'))),
          pointer: 7,
        );
        await tester.pump(kLongPressTimeout);
        await tester.pumpAndSettle();
        await gesture.moveTo(tester.getCenter(find.byKey(Key('$targetItem'))));
        await tester.pumpAndSettle();
        await gesture.up();
        await tester.pumpAndSettle();
      }

      void expectWrapLayout(List<int> expectedOrder) {
        expect(items, equals(expectedOrder));
        final expectedRects = getExpectedRects(expectedOrder);
        for (final item in expectedOrder) {
          final actualRect = tester.getRect(find.byKey(Key('$item')));
          expect(actualRect, equals(expectedRects[item]), reason: 'item $item');
        }
      }

      // when
      await dragAndRelease(0, 3);

      // then
      expectWrapLayout(const [3, 1, 2, 0, 4, 5]);

      // when dragging onto a child that changed its position by the first drop
      await dragAndRelease(0, 2);

      // then
      expectWrapLayout(const [3, 1, 0, 2, 4, 5]);
    });

    testWidgets(
        'GIVEN children with different widths '
        'WHEN removing the first child '
        'THEN should animate the following children to their new positions',
        (WidgetTester tester) async {
      // given
      var items = givenItems(6);
      late StateSetter setItems;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setItems = setState;
                return ReorderableBuilder<int>.wrap(
                  onReorder: (_) {},
                  builder: (children) => Wrap(
                    spacing: givenSpacing,
                    runSpacing: givenRunSpacing,
                    children: children,
                  ),
                  children: [for (final item in items) buildWrapChild(item)],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final givenRect = tester.getRect(find.byKey(const Key('2')));
      // first child of the first run with 180 + spacing
      const expectedLeft = 188.0;

      // when
      setItems(() => items = items.sublist(1));
      await tester.pump();
      // after the fade out of the removed child and before the end
      for (var frame = 0; frame < 4; frame++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // then the child is on its way to its new position
      final actualLeft = tester.getRect(find.byKey(const Key('2'))).left;
      expect(actualLeft, lessThan(givenRect.left));
      expect(actualLeft, greaterThan(expectedLeft));

      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(const Key('2'))).left, expectedLeft);
    });

    testWidgets(
        'GIVEN children in a scrollable '
        'WHEN removing all children at once '
        'THEN should show them fading out at their last position',
        (WidgetTester tester) async {
      // given
      var items = givenItems(6);
      late StateSetter setItems;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  setItems = setState;
                  return ReorderableBuilder<int>.wrap(
                    onReorder: (_) {},
                    builder: (children) => Wrap(
                      spacing: givenSpacing,
                      runSpacing: givenRunSpacing,
                      children: children,
                    ),
                    children: [for (final item in items) buildWrapChild(item)],
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final givenRect = tester.getRect(find.byKey(const Key('3')));

      // when
      setItems(() => items = []);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // then the removed child is still at its last position and not
      // clipped by the shrunk Wrap
      final finder = find.byKey(const Key('3'));
      expect(tester.getRect(finder), equals(givenRect));
      final visibleArea = tester.getRect(find.byType(ReorderableBuilder<int>));
      expect(visibleArea.intersect(givenRect), equals(givenRect));

      await tester.pumpAndSettle();
      expect(finder, findsNothing);
    });

    testWidgets(
        'GIVEN removed children '
        'WHEN adding new children quickly at the first index and exchanging '
        'two of them '
        'THEN should show all children like a Wrap at every step',
        (WidgetTester tester) async {
      // given
      var items = givenItems(4);
      late StateSetter setItems;
      Widget buildChild(int item) => SizedBox(
            key: Key('$item'),
            width: 60.0 + (item % 4) * 40.0,
            height: 50.0,
            child: const ColoredBox(color: Colors.lightBlue),
          );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setItems = setState;
                return ReorderableBuilder<int>.wrap(
                  onReorder: (reorder) =>
                      setState(() => items = reorder(items)),
                  builder: (children) => Wrap(
                    spacing: givenSpacing,
                    runSpacing: givenRunSpacing,
                    children: children,
                  ),
                  children: [for (final item in items) buildChild(item)],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      setItems(() => items = []);
      await tester.pumpAndSettle();

      void expectWrapLayout(List<int> expectedItems) {
        expect(items, equals(expectedItems));
        final offsets = ReorderableWrapController().calculateWrapOffsets(
          sizes: [
            for (final item in expectedItems)
              Size(60.0 + (item % 4) * 40.0, 50.0),
          ],
          renderWrap: tester.renderObject<RenderWrap>(find.byType(Wrap)),
        );
        for (final (index, item) in expectedItems.indexed) {
          final actualOffset = tester.getTopLeft(find.byKey(Key('$item')));
          expect(actualOffset, equals(offsets[index]), reason: 'item $item');
        }
      }

      // when adding a new child every 30 ms, faster than the fade in
      for (var item = 100; item < 106; item++) {
        setItems(() => items.insert(0, item));
        await tester.pump(const Duration(milliseconds: 30));
      }
      await tester.pumpAndSettle();

      // then
      expectWrapLayout(const [105, 104, 103, 102, 101, 100]);

      // when
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('105'))),
        pointer: 7,
      );
      await tester.pump(kLongPressTimeout);
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(find.byKey(const Key('102'))));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      // then
      expectWrapLayout(const [102, 104, 103, 105, 101, 100]);
    });

    testWidgets(
        'GIVEN removed children '
        'WHEN adding new children at the first index while the others are '
        'still moving and exchanging two of them '
        'THEN should show all children like a Wrap while dragging',
        (WidgetTester tester) async {
      // given
      var items = givenItems(30);
      late StateSetter setItems;
      double getWidth(int item) => 60.0 + (item % 4) * 40.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setItems = setState;
                return ReorderableBuilder<int>.wrap(
                  onReorder: (reorder) =>
                      setState(() => items = reorder(items)),
                  builder: (children) => Wrap(
                    spacing: givenSpacing,
                    runSpacing: givenRunSpacing,
                    children: children,
                  ),
                  children: [
                    for (final item in items)
                      SizedBox(
                        key: Key('$item'),
                        width: getWidth(item),
                        height: 50.0,
                        child: const ColoredBox(color: Colors.lightBlue),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      setItems(() => items = []);
      await tester.pumpAndSettle();

      // when adding a child every 128 ms, the moving children are measured
      // in the frames in between like on a real device
      for (var item = 100; item < 113; item++) {
        setItems(() => items.insert(0, item));
        for (var frame = 0; frame < 8; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
      }
      await tester.pumpAndSettle();

      final draggedItem = items[3];
      final collisionItem = items[5];
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(Key('$draggedItem'))),
        pointer: 7,
      );
      await tester.pump(kLongPressTimeout);
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(find.byKey(Key('$collisionItem'))));
      await tester.pumpAndSettle();

      // then
      final expectedItems = [...items]
        ..[3] = collisionItem
        ..[5] = draggedItem;
      final expectedOffsets = ReorderableWrapController().calculateWrapOffsets(
        sizes: [for (final item in expectedItems) Size(getWidth(item), 50.0)],
        renderWrap: tester.renderObject<RenderWrap>(find.byType(Wrap)),
      );
      for (final (index, item) in expectedItems.indexed) {
        if (item == draggedItem) continue;
        final actualOffset = tester.getTopLeft(find.byKey(Key('$item')).last);
        expect(
          actualOffset,
          equals(expectedOffsets[index]),
          reason: 'item $item',
        );
      }

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'GIVEN Wrap with centered alignment '
        'WHEN dragging a child onto another child '
        'THEN should throw AssertionError because it is not supported',
        (WidgetTester tester) async {
      // given
      final items = givenItems(3);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableBuilder<int>.wrap(
              onReorder: (_) {},
              builder: (children) => Wrap(
                alignment: WrapAlignment.center,
                children: children,
              ),
              children: [for (final item in items) buildWrapChild(item)],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // when
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('0'))),
        pointer: 7,
      );
      await tester.pump(kLongPressTimeout);
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(find.byKey(const Key('1'))));

      // then
      expect(tester.takeException(), isAssertionError);
      await gesture.up();
    });
  });
}
