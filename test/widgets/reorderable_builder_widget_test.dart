import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/removed/reorderable_animated_removed_child.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_reorderable_grid_view/widgets/item/reorderable_builder_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/drag/reorderable_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/listeners/reorderable_scrolling_listener.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Finder findRemovedChild(int item) => find.byWidgetPredicate(
        (widget) =>
            widget is ReorderableAnimatedRemovedChild &&
            widget.removedEntity.key == ValueKey(item.toString()),
      );

  group('#ReorderableBuilder.builder', () {
    Future<void> pumpWidget(
      WidgetTester tester, {
      bool enableDraggable = true,
      OnReorderCallback? onReorder,
      OnReorderPositions? onReorderPositions,
    }) async =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableBuilder.builder(
                itemCount: 1,
                childBuilder: (itemBuilder) {
                  return itemBuilder(
                    const Placeholder(
                      key: ValueKey('0'),
                    ),
                    0,
                  );
                },
                enableDraggable: enableDraggable,
                onReorder: onReorder,
                onReorderPositions: onReorderPositions,
              ),
            ),
          ),
        );

    testWidgets(
        "GIVEN enableDraggable = true and onReorder = null "
        "WHEN pumping [ReorderableBuilder.builder] "
        "THEN should throw AssertionError", (WidgetTester tester) async {
      expect(
        () => pumpWidget(tester, enableDraggable: true, onReorder: null),
        throwsAssertionError,
      );
    });

    testWidgets(
        "GIVEN enableDraggable = true and onReorder = null and onReorderPositions != null "
        "WHEN pumping [ReorderableBuilder.builder] "
        "THEN should return normally", (WidgetTester tester) async {
      expect(
        () => pumpWidget(
          tester,
          enableDraggable: true,
          onReorderPositions: (p0) {},
        ),
        returnsNormally,
      );
    });

    testWidgets(
        "GIVEN only required values, children and child for builder "
        "WHEN pumping [ReorderableBuilder.builder] "
        "THEN should show expected widgets", (WidgetTester tester) async {
      // given
      const givenChild = Text(
        'child1',
        key: Key('child1'),
      );

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableBuilder.builder(
              itemCount: 1,
              childBuilder: (itemBuilder) {
                return SingleChildScrollView(
                  child: itemBuilder(givenChild, 0),
                );
              },
              onReorder: (_) {},
            ),
          ),
        ),
      );

      // then
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableBuilder &&
              widget.children == null &&
              widget.lockedIndices.isEmpty &&
              widget.nonDraggableIndices.isEmpty &&
              widget.longPressDelay == const Duration(milliseconds: 500) &&
              widget.enableDraggable &&
              widget.automaticScrollExtent == 150.0 &&
              widget.enableScrollingWhileDragging &&
              widget.animationConfig == const ReorderableAnimationConfig() &&
              widget.feedbackScaleFactor == null &&
              !widget.reverse,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableScrollingListener &&
              !widget.isDragging &&
              widget.reorderableChildKey == null &&
              widget.scrollController == null &&
              widget.automaticScrollExtent == 150.0 &&
              widget.enableScrollingWhileDragging &&
              !widget.reverse &&
              widget.child is SingleChildScrollView,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableBuilderItem &&
              widget.animationConfig.insert.duration ==
                  const Duration(milliseconds: 500) &&
              widget.animationConfig.positionChangeDuration ==
                  const Duration(milliseconds: 200) &&
              widget.releasedReorderableEntity == null &&
              widget.scrollOffset == Offset.zero &&
              widget.animationConfig.releasedItemDuration ==
                  const Duration(milliseconds: 150) &&
              widget.enableDraggable &&
              widget.currentDraggedEntity == null &&
              widget.enableLongPress &&
              widget.longPressDelay == const Duration(milliseconds: 500) &&
              widget.dragChildBoxDecoration == null &&
              widget.draggingAnimationMap.isEmpty &&
              widget.child == givenChild,
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        "GIVEN [ReorderableBuilder.builder], three children, "
        "then removing third child "
        "WHEN moving last (second) child to the right "
        "THEN should not call onReorder", (WidgetTester tester) async {
      // given
      const givenItems = ['item1', 'item2', 'item3'];
      var onReorderCallCounter = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestReorderableBuilderBuilder1(
              items: givenItems,
              onCalledReorder: () {
                onReorderCallCounter++;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      // when
      final lastLocation = tester.getCenter(find.text(givenItems[1]));
      final gesture = await tester.startGesture(lastLocation, pointer: 7);
      await tester.pump(kLongPressTimeout);
      await tester.pumpAndSettle();

      await gesture.moveTo(Offset(lastLocation.dx + 80.0, lastLocation.dy));
      await tester.pump();

      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      // then
      expect(onReorderCallCounter, equals(0));
    });

    group('fade out of removed children', () {
      late List<int> givenItems;
      late StateSetter updateItems;

      /// Pumps 40 children in 4 columns, more than fit on the screen.
      Future<void> pumpWidgetWithManyChildren(WidgetTester tester) async {
        givenItems = List.generate(40, (index) => index);
        final scrollController = ScrollController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  updateItems = setState;
                  return ReorderableBuilder.builder(
                    scrollController: scrollController,
                    animationConfig: const ReorderableAnimationConfig(
                      fadeOutDuration: Duration(milliseconds: 200),
                    ),
                    onReorder: (_) {},
                    itemCount: givenItems.length,
                    childBuilder: (itemBuilder) => GridView.builder(
                      controller: scrollController,
                      itemCount: givenItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                      ),
                      itemBuilder: (context, index) => itemBuilder(
                        SizedBox(
                          key: ValueKey(givenItems[index].toString()),
                          child: Text(givenItems[index].toString()),
                        ),
                        index,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      testWidgets(
          "GIVEN [ReorderableBuilder.builder] "
          "WHEN removing a visible child "
          "THEN should only fade out the removed child",
          (WidgetTester tester) async {
        // given
        await pumpWidgetWithManyChildren(tester);

        // when
        updateItems(() => givenItems.remove(5));
        // the removed child is found after the GridView was built
        await tester.pump();
        await tester.pump();

        // then
        expect(find.byType(ReorderableAnimatedRemovedChild), findsOneWidget);
        expect(findRemovedChild(5), findsOneWidget);
      });
    });
  });

  group('#ReorderableBuilder', () {
    Future<void> pumpWidget(
      WidgetTester tester, {
      List<Widget> children = const [],
      bool enableDraggable = true,
      DraggableBuilder? builder,
      OnReorderCallback? onReorder,
      ItemCallback? onDragStarted,
      ItemCallback? onDragEnd,
      ItemCallback? onUpdatedDraggedChild,
    }) async =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableBuilder(
                builder: builder ?? (_) => const Placeholder(),
                enableDraggable: enableDraggable,
                onReorder: onReorder,
                onDragStarted: onDragStarted,
                onDragEnd: onDragEnd,
                onUpdatedDraggedChild: onUpdatedDraggedChild,
                children: children,
              ),
            ),
          ),
        );

    testWidgets(
        "GIVEN enableDraggable = true and onReorder = null "
        "WHEN pumping [ReorderableBuilder] "
        "THEN should throw AssertionError", (WidgetTester tester) async {
      expect(
        () => pumpWidget(tester, enableDraggable: true, onReorder: null),
        throwsAssertionError,
      );
    });

    testWidgets(
        "GIVEN only required values, children and child for builder "
        "WHEN pumping [ReorderableBuilder] "
        "THEN should show expected widgets", (WidgetTester tester) async {
      // given
      const givenChildren = [
        Text('child1', key: Key('child1')),
        Text('non draggable child', key: Key('child2')),
        Text('locked child', key: Key('child3')),
      ];

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableBuilder(
              nonDraggableIndices: const [1],
              lockedIndices: const [2],
              builder: (children) {
                return SingleChildScrollView(
                  child: Column(
                    children: children,
                  ),
                );
              },
              onReorder: (_) {},
              children: givenChildren,
            ),
          ),
        ),
      );

      // then
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableBuilder &&
              widget.childBuilder == null &&
              widget.lockedIndices == const [2] &&
              widget.nonDraggableIndices == const [1] &&
              widget.longPressDelay == const Duration(milliseconds: 500) &&
              widget.enableDraggable &&
              widget.automaticScrollExtent == 150.0 &&
              widget.enableScrollingWhileDragging &&
              widget.animationConfig == const ReorderableAnimationConfig() &&
              !widget.reverse,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableScrollingListener &&
              !widget.isDragging &&
              widget.reorderableChildKey == null &&
              widget.scrollController == null &&
              widget.automaticScrollExtent == 150.0 &&
              widget.enableScrollingWhileDragging &&
              !widget.reverse &&
              widget.child is SingleChildScrollView,
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableBuilderItem &&
              widget.animationConfig.insert.duration ==
                  const Duration(milliseconds: 500) &&
              widget.animationConfig.positionChangeDuration ==
                  const Duration(milliseconds: 200) &&
              widget.releasedReorderableEntity == null &&
              widget.scrollOffset == Offset.zero &&
              widget.animationConfig.releasedItemDuration ==
                  const Duration(milliseconds: 150) &&
              widget.currentDraggedEntity == null &&
              widget.enableLongPress &&
              widget.longPressDelay == const Duration(milliseconds: 500) &&
              widget.dragChildBoxDecoration == null &&
              widget.draggingAnimationMap.isEmpty,
        ),
        findsNWidgets(3),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableBuilderItem &&
              widget.enableDraggable &&
              widget.child == givenChildren[0],
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableBuilderItem &&
              !widget.enableDraggable &&
              widget.child == givenChildren[1],
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableBuilderItem &&
              !widget.enableDraggable &&
              widget.child == givenChildren[2],
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        "GIVEN [ReorderableBuilder] and three children "
        "WHEN moving first child to the third child "
        "THEN should order children and "
        "call onDragStarted, onDragEnd, onUpdatedDraggedChildIndex ",
        (WidgetTester tester) async {
      // given
      const givenChildren = [
        Text('child1', key: Key('child1')),
        Text('child2', key: Key('child2')),
        Text('child3', key: Key('child3')),
      ];
      late List<Widget> updatedChildren;
      late int actualOnDragStartedIndex;
      late int actualOnDragEndIndex;
      late int actualOnUpdatedDraggedChildIndex;

      await pumpWidget(
        tester,
        children: givenChildren,
        onReorder: (reorderFunction) {
          updatedChildren = reorderFunction(givenChildren) as List<Widget>;
        },
        onDragStarted: (index) {
          actualOnDragStartedIndex = index;
        },
        onDragEnd: (index) {
          actualOnDragEndIndex = index;
        },
        onUpdatedDraggedChild: (index) {
          actualOnUpdatedDraggedChildIndex = index;
        },
        builder: (children) {
          return GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 8,
            ),
            children: children,
          );
        },
      );
      await tester.pumpAndSettle();

      // when
      final firstLocation = tester.getCenter(find.byWidget(givenChildren[0]));
      final gesture = await tester.startGesture(firstLocation, pointer: 7);
      await tester.pump(kLongPressTimeout);
      await tester.pumpAndSettle();

      final secondLocation = tester.getCenter(find.byWidget(givenChildren[2]));
      await gesture.moveTo(secondLocation);
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // then
      final expectedUpdatedChildren = [
        givenChildren[1],
        givenChildren[2],
        givenChildren[0],
      ];
      expect(actualOnDragStartedIndex, equals(0));
      expect(actualOnDragEndIndex, equals(2));
      expect(actualOnUpdatedDraggedChildIndex, equals(2));
      expect(updatedChildren, equals(expectedUpdatedChildren));
      final actualDraggingAnimationMap = tester
          .widget<ReorderableBuilderItem>(
            find.byType(ReorderableBuilderItem).first,
          )
          .draggingAnimationMap;
      expect(actualDraggingAnimationMap.keys, equals(const [Key('child1')]));
    });

    testWidgets(
        "GIVEN [ReorderableBuilder] and three children and rotated screen "
        "WHEN moving first child to the third child "
        "THEN should order children and call onUpdatedDraggedChildIndex ",
        (WidgetTester tester) async {
      // given
      const givenChildren = [
        Text('child1', key: Key('child1')),
        Text('child2', key: Key('child2')),
        Text('child3', key: Key('child3')),
      ];
      late List<Widget> updatedChildren;

      await pumpWidget(
        tester,
        children: givenChildren,
        onReorder: (reorderFunction) {
          updatedChildren = reorderFunction(givenChildren) as List<Widget>;
        },
        builder: (children) {
          return GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 8,
            ),
            children: children,
          );
        },
      );
      await tester.pumpAndSettle();

      // to landscape
      tester.view.physicalSize = const Size(1200.0, 800.0);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      // when
      final firstLocation = tester.getCenter(find.byWidget(givenChildren[0]));
      final gesture = await tester.startGesture(firstLocation, pointer: 7);
      await tester.pump(kLongPressTimeout);
      await tester.pumpAndSettle();

      final secondLocation = tester.getCenter(find.byWidget(givenChildren[2]));
      await gesture.moveTo(secondLocation);
      await tester.pump();

      await gesture.up();
      await tester.pump();

      // then
      final expectedUpdatedChildren = [
        givenChildren[1],
        givenChildren[2],
        givenChildren[0],
      ];
      expect(updatedChildren, equals(expectedUpdatedChildren));
    });

    testWidgets(
        "GIVEN [ReorderableBuilder] with 2 columns "
        "WHEN changing to 4 columns "
        "THEN should re-measure the cached size of every child",
        (WidgetTester tester) async {
      // given
      final givenChildren = List.generate(
        4,
        (index) => Container(key: ValueKey(index.toString())),
      );
      Widget build({required int crossAxisCount}) => MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: ReorderableBuilder(
                  children: givenChildren,
                  onReorder: (_) {},
                  builder: (children) => GridView.count(
                    crossAxisCount: crossAxisCount,
                    children: children,
                  ),
                ),
              ),
            ),
          );
      await tester.pumpWidget(build(crossAxisCount: 2));
      await tester.pumpAndSettle();

      // when
      await tester.pumpWidget(build(crossAxisCount: 4));
      await tester.pumpAndSettle();

      // then
      final draggables = tester.widgetList<ReorderableDraggable>(
        find.byType(ReorderableDraggable),
      );
      for (final draggable in draggables) {
        expect(draggable.reorderableEntity.size, equals(const Size(100, 100)));
      }
    });

    testWidgets(
        "GIVEN [ReorderableBuilder] and a child moving after a removal "
        "WHEN a drag swaps it in the frame its move finishes "
        "THEN should keep every child and reorder them",
        (WidgetTester tester) async {
      // given
      var givenItems = List.generate(6, (index) => index);
      late StateSetter updateItems;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                updateItems = setState;
                return ReorderableBuilder<int>(
                  longPressDelay: Duration.zero,
                  animationConfig: const ReorderableAnimationConfig(
                    positionChangeDuration: Duration(milliseconds: 200),
                  ),
                  onReorder: (reorderedListFunction) => setState(
                    () => givenItems = reorderedListFunction(givenItems),
                  ),
                  builder: (children) => GridView(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                    ),
                    children: children,
                  ),
                  children: [
                    for (final item in givenItems)
                      SizedBox(
                        key: ValueKey(item.toString()),
                        child: Text(item.toString()),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final givenPositionOf2 = tester.getCenter(find.text('2'));

      // removing "2" moves "3" to the position of "2" within 200 ms
      updateItems(() => givenItems.remove(2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      // dragging "1" while "3" is still moving
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('1')),
      );
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 160));

      // when
      // swapping "1" and "3" without a frame before "3" finishes moving
      await gesture.moveTo(givenPositionOf2);
      await tester.pump(const Duration(milliseconds: 50));

      // then
      expect(tester.takeException(), isNull);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(givenItems, equals([0, 3, 1, 4, 5]));
    });

    group('fade out of removed children', () {
      late List<int> givenItems;
      late StateSetter updateItems;

      /// Pumps 40 children in 4 columns, more than fit on the screen.
      Future<void> pumpWidgetWithManyChildren(
        WidgetTester tester, {
        required Duration fadeOutDuration,
      }) async {
        givenItems = List.generate(40, (index) => index);
        final scrollController = ScrollController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  updateItems = setState;
                  return ReorderableBuilder(
                    scrollController: scrollController,
                    animationConfig: ReorderableAnimationConfig(
                      fadeOutDuration: fadeOutDuration,
                    ),
                    onReorder: (_) {},
                    builder: (children) => GridView(
                      controller: scrollController,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                      ),
                      children: children,
                    ),
                    children: [
                      for (final item in givenItems)
                        SizedBox(
                          key: ValueKey(item.toString()),
                          child: Text(item.toString()),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      testWidgets(
          "GIVEN [ReorderableBuilder] "
          "WHEN removing a visible child "
          "THEN should fade out the child at its old position",
          (WidgetTester tester) async {
        // given
        await pumpWidgetWithManyChildren(
          tester,
          fadeOutDuration: const Duration(milliseconds: 200),
        );
        final givenOffset = tester.getTopLeft(find.text('5'));

        // when
        updateItems(() => givenItems.remove(5));
        await tester.pump();

        // then
        expect(find.byType(ReorderableAnimatedRemovedChild), findsOneWidget);
        expect(tester.getTopLeft(findRemovedChild(5)), equals(givenOffset));
      });
    });
  });
}

/// This test widget is testing [ReorderableBuilder.builder].
///
/// This widget is built for the following test case:
/// - add three children
/// - remove last child
/// - drag now the second child to the right where nothing is
/// - [onCalledReorder] shouldn't get called because there is no last item
///
/// The issue was first discovered here: https://github.com/karvulf/flutter-reorderable-grid-view/issues/155.
class _TestReorderableBuilderBuilder1 extends StatefulWidget {
  final List<String> items;
  final VoidCallback onCalledReorder;

  const _TestReorderableBuilderBuilder1({
    required this.items,
    required this.onCalledReorder,
  });

  @override
  State<_TestReorderableBuilderBuilder1> createState() =>
      _TestReorderableBuilderBuilder1State();
}

class _TestReorderableBuilderBuilder1State
    extends State<_TestReorderableBuilderBuilder1> {
  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();
  late var items = widget.items.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              setState(() {
                items = items..removeLast();
              });
            },
          ),
        ],
      ),
      body: ReorderableBuilder.builder(
        scrollController: _scrollController,
        itemCount: items.length,
        onReorder: (ReorderedListFunction<String> reorderedListFunction) {
          widget.onCalledReorder();
          setState(() {
            items = reorderedListFunction(items);
          });
        },
        childBuilder: (itemBuilder) {
          return GridView.builder(
            key: _gridViewKey,
            controller: _scrollController,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return itemBuilder(
                Card(
                  key: ValueKey(items[index]),
                  child: Text(items[index]),
                ),
                index,
              );
            },
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 90,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          );
        },
      ),
    );
  }
}
