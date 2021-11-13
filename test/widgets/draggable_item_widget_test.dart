import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/widget_test_helper.dart';

void main() {
  testWidgets(
      'GIVEN enableLongPress = false, item and id '
      'WHEN pumping [DraggableItem] '
      'THEN should have expected widgets', (WidgetTester tester) async {
    // given
    const givenEnableLongPress = false;
    const givenOrderId = 0;
    const givenChild = UniqueTestWidget();

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraggableItem(
            enableLongPress: givenEnableLongPress,
            child: givenChild,
            orderId: givenOrderId,
            onCreated: (_, __, ___, ____) {},
            onDragUpdate: (_, __, ___) {},
          ),
        ),
      ),
    );

    // then
    expect(find.byWidgetPredicate((widget) => widget is Draggable<String>),
        findsOneWidget);
    expect(find.byType(LongPressDraggable), findsNothing);
  });

  testWidgets(
      'GIVEN enableLongPress = true, item and id '
      'WHEN pumping [DraggableItem] '
      'THEN should have expected widgets', (WidgetTester tester) async {
    // given
    const givenEnableLongPress = true;
    const givenChild = UniqueTestWidget();
    const givenOrderId = 0;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraggableItem(
            enableLongPress: givenEnableLongPress,
            child: givenChild,
            orderId: givenOrderId,
            onCreated: (_, __, ___, ____) {},
            onDragUpdate: (_, __, ___) {},
          ),
        ),
      ),
    );

    // then
    expect(find.byWidgetPredicate((widget) => widget is Draggable<String>),
        findsNothing);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is LongPressDraggable && widget.delay == kLongPressTimeout),
        findsOneWidget);
  });

  testWidgets(
      'GIVEN enableLongPress = true, longPressDelay, item and id '
      'WHEN pumping [DraggableItem] '
      'THEN should have expected widgets', (WidgetTester tester) async {
    // given
    const givenEnableLongPress = true;
    const givenOrderId = 0;
    const givenLongPressDelay = Duration(days: 100);
    const givenChild = UniqueTestWidget();

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraggableItem(
            enableLongPress: givenEnableLongPress,
            child: givenChild,
            orderId: givenOrderId,
            onCreated: (_, __, ___, ____) {},
            onDragUpdate: (_, __, ___) {},
            longPressDelay: givenLongPressDelay,
          ),
        ),
      ),
    );

    // then
    expect(find.byWidgetPredicate((widget) => widget is Draggable<String>),
        findsNothing);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is LongPressDraggable &&
            widget.delay == givenLongPressDelay),
        findsOneWidget);
  });

  testWidgets(
      'GIVEN enable = false, item and id '
      'WHEN pumping [DraggableItem] '
      'THEN should have no Draggable widget and just given item',
      (WidgetTester tester) async {
    // given
    const givenOrderId = 0;
    const givenChild = UniqueTestWidget();

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraggableItem(
            child: givenChild,
            orderId: givenOrderId,
            onCreated: (_, __, ___, ____) {},
            onDragUpdate: (_, __, ___) {},
            enabled: false,
            enableLongPress: false,
          ),
        ),
      ),
    );

    // then
    expect(find.byWidgetPredicate((widget) => widget is Draggable<String>),
        findsNothing);
    expect(find.byWidgetPredicate((widget) => widget is LongPressDraggable),
        findsNothing);
    expect(find.byType(UniqueTestWidget), findsOneWidget);
  });

  testWidgets(
      'GIVEN enableLongPress = false, item, id and onCreated '
      'WHEN pumping [DraggableItem] '
      'THEN should call onCreated', (WidgetTester tester) async {
    // given
    const givenEnableLongPress = false;
    const givenOrderId = 0;
    const givenChild = UniqueTestWidget();

    BuildContext? expectedContext;
    GlobalKey? expectedKey;
    int? expectedOrderId;
    Widget? expectedChild;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraggableItem(
            child: givenChild,
            enableLongPress: givenEnableLongPress,
            orderId: givenOrderId,
            onCreated: (
              BuildContext context,
              GlobalKey key,
              int orderId,
              Widget child,
            ) {
              expectedContext = context;
              expectedKey = key;
              expectedOrderId = orderId;
              expectedChild = child;
            },
            onDragUpdate: (_, __, ___) {},
          ),
        ),
      ),
    );

    // then
    expect(expectedContext, isNotNull);
    expect(expectedKey, isNotNull);
    expect(expectedOrderId, equals(givenOrderId));
    expect(expectedChild, equals(givenChild));
  });

  testWidgets(
      'GIVEN [DraggableItem] '
      'WHEN dragging and releasing '
      'THEN should call onDragUpdate', (WidgetTester tester) async {
    // given
    const givenEnableLongPress = false;
    const givenText = 'hallo';
    const givenChild = Text(givenText);
    const givenOrderId = 0;

    Offset? expectedPosition;
    int? expectedId;
    Size? expectedSize;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 1000,
            width: 1000,
            child: DraggableItem(
              child: givenChild,
              enableLongPress: givenEnableLongPress,
              orderId: givenOrderId,
              onCreated: (_, __, ___, ____) {},
              onDragUpdate: (
                int id,
                Offset position,
                Size size,
              ) {
                expectedId = id;
                expectedPosition = position;
                expectedSize = size;
              },
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
    await gesture.up();
    await tester.pumpAndSettle();

    // then
    expect(expectedPosition, isNotNull);
    expect(expectedSize, isNotNull);
    expect(expectedId, equals(givenOrderId));
  });
}
