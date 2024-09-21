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
    }) async =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableBuilder.builder(
                childBuilder: (itemBuilder) {
                  return itemBuilder(const Placeholder(), 0);
                },
                enableDraggable: enableDraggable,
                onReorder: onReorder,
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
          find.byWidgetPredicate((widget) =>
              widget is ReorderableBuilder &&
              widget.children == null &&
              widget.lockedIndices.isEmpty &&
              widget.nonDraggableIndices.isEmpty &&
              widget.enableLongPress &&
              widget.longPressDelay == const Duration(milliseconds: 500) &&
              widget.enableDraggable &&
              widget.automaticScrollExtent == 80.0 &&
              widget.enableScrollingWhileDragging &&
              widget.fadeInDuration == const Duration(milliseconds: 500) &&
              widget.releasedChildDuration ==
                  const Duration(milliseconds: 150) &&
              widget.positionDuration == const Duration(milliseconds: 200) &&
              widget.feedbackScaleFactor == 1.05),
          findsOneWidget);
      expect(
          find.byWidgetPredicate((widget) =>
              widget is ReorderableScrollingListener &&
              !widget.isDragging &&
              widget.reorderableChildKey == null &&
              widget.scrollController == null &&
              widget.automaticScrollExtent == 80.0 &&
              widget.enableScrollingWhileDragging &&
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
          find.byWidgetPredicate((widget) =>
              widget is ReorderableBuilder &&
              widget.childBuilder == null &&
              widget.lockedIndices == const [2] &&
              widget.nonDraggableIndices == const [1] &&
              widget.enableLongPress &&
              widget.longPressDelay == const Duration(milliseconds: 500) &&
              widget.enableDraggable &&
              widget.automaticScrollExtent == 80.0 &&
              widget.enableScrollingWhileDragging &&
              widget.fadeInDuration == const Duration(milliseconds: 500) &&
              widget.releasedChildDuration ==
                  const Duration(milliseconds: 150) &&
              widget.positionDuration == const Duration(milliseconds: 200)),
          findsOneWidget);
      expect(
          find.byWidgetPredicate((widget) =>
              widget is ReorderableScrollingListener &&
              !widget.isDragging &&
              widget.reorderableChildKey == null &&
              widget.scrollController == null &&
              widget.automaticScrollExtent == 80.0 &&
              widget.enableScrollingWhileDragging &&
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
  });
}
