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
    const givenItem = UniqueTestWidget();
    const givenId = 0;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraggableItem(
            enableLongPress: givenEnableLongPress,
            item: givenItem,
            id: givenId,
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
    const givenItem = UniqueTestWidget();
    const givenId = 0;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraggableItem(
            enableLongPress: givenEnableLongPress,
            item: givenItem,
            id: givenId,
            onCreated: (_, __, ___, ____) {},
            onDragUpdate: (_, __, ___) {},
          ),
        ),
      ),
    );

    // then
    expect(find.byWidgetPredicate((widget) => widget is Draggable<String>),
        findsNothing);
    expect(find.byType(LongPressDraggable), findsOneWidget);
  });

  testWidgets(
      'GIVEN enableLongPress = false, item, id and onCreated '
      'WHEN pumping [DraggableItem] '
      'THEN should call onCreated', (WidgetTester tester) async {
    // given
    const givenEnableLongPress = false;
    const givenItem = UniqueTestWidget();
    const givenId = 0;

    BuildContext? expectedContext;
    GlobalKey? expectedKey;
    Widget? expectedItem;
    int? expectedId;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DraggableItem(
            enableLongPress: givenEnableLongPress,
            item: givenItem,
            id: givenId,
            onCreated: (
              BuildContext context,
              GlobalKey key,
              Widget item,
              int id,
            ) {
              expectedContext = context;
              expectedKey = key;
              expectedItem = item;
              expectedId = id;
            },
            onDragUpdate: (_, __, ___) {},
          ),
        ),
      ),
    );

    // then
    expect(expectedContext, isNotNull);
    expect(expectedKey, isNotNull);
    expect(expectedItem, equals(givenItem));
    expect(expectedId, equals(givenId));
  });

  testWidgets(
      'GIVEN [DraggableItem] '
      'WHEN dragging '
      'THEN should call onDragUpdate', (WidgetTester tester) async {
    // given
    const givenEnableLongPress = false;
    const givenText = 'hallo';
    const givenItem = Text(givenText);
    const givenId = 0;

    BuildContext? expectedContext;
    DragUpdateDetails? expectedDragUpdateDetails;
    int? expectedId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 1000,
            width: 1000,
            child: DraggableItem(
              enableLongPress: givenEnableLongPress,
              item: givenItem,
              id: givenId,
              onCreated: (_, __, ___, ____) {},
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
    expect(expectedId, equals(givenId));
  });
}
