import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
}
