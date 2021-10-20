import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_type.dart';
import 'package:flutter_reorderable_grid_view/flutter_reorderable_grid_view.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'GIVEN children '
      'WHEN pumping [ReorderableWrap] '
      'THEN should show widget with default values',
      (WidgetTester tester) async {
    // given
    const givenChildren = <Widget>[
      Text('hallo'),
    ];

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: ReorderableWrap(
          children: givenChildren,
          onReorder: (_, __) {},
        ),
      ),
    );

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is ReorderableWrap &&
            widget.lockedChildren.isEmpty &&
            widget.longPressDelay == kLongPressTimeout &&
            widget.enableLongPress &&
            widget.enableAnimation &&
            widget.spacing == 8 &&
            widget.runSpacing == 8),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Reorderable &&
            widget.reorderableType == ReorderableType.wrap &&
            widget.children == givenChildren),
        findsOneWidget);
  });

  testWidgets(
      'GIVEN values '
      'WHEN pumping [ReorderableWrap] '
      'THEN should show widget with given values', (WidgetTester tester) async {
    // given
    const givenChildren = <Widget>[
      Text('hallo'),
    ];
    const givenPhysics = AlwaysScrollableScrollPhysics();
    const givenEnableAnimation = false;
    const givenEnableLongPress = false;
    const givenLongPressDelay = Duration(days: 100);
    const givenRunSpacing = 10.0;
    const givenLockedChildren = [10, 20];
    const givenSpacing = 100.0;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: ReorderableWrap(
          children: givenChildren,
          onReorder: (_, __) {},
          physics: givenPhysics,
          enableAnimation: givenEnableAnimation,
          enableLongPress: givenEnableLongPress,
          longPressDelay: givenLongPressDelay,
          runSpacing: givenRunSpacing,
          lockedChildren: givenLockedChildren,
          spacing: givenSpacing,
        ),
      ),
    );

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Reorderable &&
            widget.physics == givenPhysics &&
            widget.lockedChildren == givenLockedChildren &&
            widget.longPressDelay == givenLongPressDelay &&
            widget.enableLongPress == givenEnableLongPress &&
            widget.enableAnimation == givenEnableAnimation &&
            widget.spacing == givenSpacing &&
            widget.runSpacing == givenRunSpacing),
        findsOneWidget);
  });
}
