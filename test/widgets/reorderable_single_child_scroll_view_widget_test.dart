import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated_draggable_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_single_child_scroll_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/reorderable_grid_view_builder.dart';

void main() {
  final builder = ReorderableGridViewBuilder();

  final givenChildrenIdMap = {
    0: builder.getGridItemEntity(orderId: 0),
    1: builder.getGridItemEntity(orderId: 1),
    2: builder.getGridItemEntity(orderId: 2),
  };

  final givenChildren = [
    Container(key: const Key('key1')),
    Container(key: const Key('key2')),
    Container(key: const Key('key3')),
  ];

  testWidgets(
      'GIVEN height, width and childrenIdMap '
      'WHEN pumping [ReorderableSingleChildScrollView] '
      'THEN should show expected widgets', (WidgetTester tester) async {
    // given
    const givenHeight = 200.0;
    const givenWidth = 200.0;
    const givenClipBehavior = Clip.none;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReorderableSingleChildScrollView(
            children: givenChildren,
            height: givenHeight,
            width: givenWidth,
            clipBehavior: givenClipBehavior,
            childrenIdMap: givenChildrenIdMap,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // then
    expect(find.byType(AnimatedDraggableItem),
        findsNWidgets(givenChildrenIdMap.length));
    expect(
        find.byWidgetPredicate((widget) =>
            widget is ReorderableSingleChildScrollView &&
            widget.enableAnimation &&
            widget.enableLongPress &&
            widget.longPressDelay == kLongPressTimeout &&
            widget.lockedChildren.isEmpty &&
            !widget.willBeRemoved),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is SizedBox &&
            widget.height == givenHeight &&
            widget.width == givenWidth),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Stack && widget.clipBehavior == givenClipBehavior),
        findsOneWidget);
  });
}
