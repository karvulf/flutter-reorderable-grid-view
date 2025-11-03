import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_scrolling_listener.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
                      0);
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
                widget.fadeInDuration == const Duration(milliseconds: 500) &&
                widget.releasedChildDuration ==
                    const Duration(milliseconds: 150) &&
                widget.positionDuration == const Duration(milliseconds: 200) &&
                widget.feedbackScaleFactor == 1.05 &&
                !widget.reverse,
          ),
          findsOneWidget);
      expect(
          find.byWidgetPredicate((widget) =>
              widget is ReorderableScrollingListener &&
              !widget.isDragging &&
              widget.reorderableChildKey == null &&
              widget.scrollController == null &&
              widget.automaticScrollExtent == 150.0 &&
              widget.enableScrollingWhileDragging &&
              !widget.reverse &&
              widget.child is SingleChildScrollView),
          findsOneWidget);
      expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is ReorderableBuilderItem &&
                widget.fadeInDuration == const Duration(milliseconds: 500) &&
                widget.positionDuration == const Duration(milliseconds: 200) &&
                widget.releasedReorderableEntity == null &&
                widget.scrollOffset == Offset.zero &&
                widget.releasedChildDuration ==
                    const Duration(milliseconds: 150) &&
                widget.enableDraggable &&
                widget.currentDraggedEntity == null &&
                widget.enableLongPress &&
                widget.longPressDelay == const Duration(milliseconds: 500) &&
                widget.dragChildBoxDecoration == null &&
                widget.child == givenChild,
          ),
          findsOneWidget);
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
                widget.fadeInDuration == const Duration(milliseconds: 500) &&
                widget.releasedChildDuration ==
                    const Duration(milliseconds: 150) &&
                widget.positionDuration == const Duration(milliseconds: 200) &&
                !widget.reverse,
          ),
          findsOneWidget);
      expect(
          find.byWidgetPredicate((widget) =>
              widget is ReorderableScrollingListener &&
              !widget.isDragging &&
              widget.reorderableChildKey == null &&
              widget.scrollController == null &&
              widget.automaticScrollExtent == 150.0 &&
              widget.enableScrollingWhileDragging &&
              !widget.reverse &&
              widget.child is SingleChildScrollView),
          findsOneWidget);

      expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is ReorderableBuilderItem &&
                widget.fadeInDuration == const Duration(milliseconds: 500) &&
                widget.positionDuration == const Duration(milliseconds: 200) &&
                widget.releasedReorderableEntity == null &&
                widget.scrollOffset == Offset.zero &&
                widget.releasedChildDuration ==
                    const Duration(milliseconds: 150) &&
                widget.currentDraggedEntity == null &&
                widget.enableLongPress &&
                widget.longPressDelay == const Duration(milliseconds: 500) &&
                widget.dragChildBoxDecoration == null,
          ),
          findsNWidgets(3));
      expect(
          find.byWidgetPredicate((widget) =>
              widget is ReorderableBuilderItem &&
              widget.enableDraggable &&
              widget.child == givenChildren[0]),
          findsOneWidget);
      expect(
          find.byWidgetPredicate((widget) =>
              widget is ReorderableBuilderItem &&
              !widget.enableDraggable &&
              widget.child == givenChildren[1]),
          findsOneWidget);
      expect(
          find.byWidgetPredicate((widget) =>
              widget is ReorderableBuilderItem &&
              !widget.enableDraggable &&
              widget.child == givenChildren[2]),
          findsOneWidget);
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
