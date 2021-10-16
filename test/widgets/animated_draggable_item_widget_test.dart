import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated_draggable_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/reorderable_grid_view_builder.dart';

void main() {
  final builder = ReorderableGridViewBuilder();

  testWidgets(
      'GIVEN enableAnimation = false, enableLongPress = false and entry '
      'WHEN pumping [AnimatedDraggableItem] '
      'THEN should show expected widgets and have expected values',
      (WidgetTester tester) async {
    // given
    const givenEnableAnimation = false;
    const givenEnableLongPress = false;
    final givenEntry = MapEntry(0, builder.getGridItemEntity());

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              AnimatedDraggableItem(
                enableAnimation: givenEnableAnimation,
                enableLongPress: givenEnableLongPress,
                entry: givenEntry,
                onDragUpdate: (_, __, ___) {},
              ),
            ],
          ),
        ),
      ),
    );

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Positioned &&
            widget.top == givenEntry.value.localPosition.dy &&
            widget.left == givenEntry.value.localPosition.dx &&
            widget.width == givenEntry.value.size.width &&
            widget.height == givenEntry.value.size.height),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is DraggableItem &&
            widget.item == givenEntry.value.item &&
            widget.enableLongPress == givenEnableLongPress &&
            widget.id == givenEntry.key &&
            widget.longPressDelay == kLongPressTimeout),
        findsOneWidget);
  });

  testWidgets(
      'GIVEN enableAnimation = true, enableLongPress = true and entry '
      'WHEN pumping [AnimatedDraggableItem] '
      'THEN should show expected widgets and have expected values',
      (WidgetTester tester) async {
    // given
    const givenEnableAnimation = true;
    const givenEnableLongPress = true;
    const givenLongPressDelay = Duration(seconds: 100);
    final givenEntry = MapEntry(0, builder.getGridItemEntity());

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              AnimatedDraggableItem(
                enableAnimation: givenEnableAnimation,
                enableLongPress: givenEnableLongPress,
                entry: givenEntry,
                onDragUpdate: (_, __, ___) {},
                longPressDelay: givenLongPressDelay,
              ),
            ],
          ),
        ),
      ),
    );

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is AnimatedPositioned &&
            widget.top == givenEntry.value.localPosition.dy &&
            widget.left == givenEntry.value.localPosition.dx &&
            widget.width == givenEntry.value.size.width &&
            widget.height == givenEntry.value.size.height),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is DraggableItem &&
            widget.item == givenEntry.value.item &&
            widget.enableLongPress == givenEnableLongPress &&
            widget.id == givenEntry.key &&
            widget.longPressDelay == givenLongPressDelay),
        findsOneWidget);
  });

  testWidgets(
      'GIVEN [AnimatedDraggableItem] '
      'WHEN dragging '
      'THEN should call onDragUpdate', (WidgetTester tester) async {
    // given
    const givenEnableLongPress = false;
    const givenEnableAnimation = true;
    const givenText = 'hallo';
    const givenItem = Text(givenText);
    final givenEntry = MapEntry(
      0,
      builder.getGridItemEntity(
        item: givenItem,
        size: const Size(100, 100),
      ),
    );

    BuildContext? expectedContext;
    DragUpdateDetails? expectedDragUpdateDetails;
    int? expectedId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 1000,
            width: 1000,
            child: Stack(
              children: [
                AnimatedDraggableItem(
                  enableAnimation: givenEnableAnimation,
                  enableLongPress: givenEnableLongPress,
                  entry: givenEntry,
                  onDragUpdate: (
                    BuildContext context,
                    DragUpdateDetails details,
                    int id,
                  ) {
                    expectedContext = context;
                    expectedDragUpdateDetails = details;
                    expectedId = id;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // when
    // start dragging
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(givenText)),
      pointer: 7,
    );
    await tester.pump();

    // move dragged object
    await gesture.moveTo(const Offset(200, 200));
    await tester.pumpAndSettle();

    // then
    expect(expectedContext, isNotNull);
    expect(expectedDragUpdateDetails, isNotNull);
    expect(expectedId, equals(givenEntry.key));
  });
}
