import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_dragging_container.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenChild = Text('hallo');
  const givenReorderableEntity = ReorderableEntity(
    child: givenChild,
    originalOrderId: 0,
    updatedOrderId: 0,
    isBuilding: false,
    originalOffset: Offset(0, 0),
    updatedOffset: Offset(100, 100),
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    required bool isDragging,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableAnimatedDraggingContainer(
              reorderableEntity: givenReorderableEntity,
              isDragging: isDragging,
              child: givenChild,
            ),
          ),
        ),
      );

  testWidgets(
      'GIVEN isDragging = false '
      'WHEN pumping [ReorderableAnimatedDraggingContainer] '
      'THEN should show expected widget with expected values',
      (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(tester, isDragging: false);

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is AnimatedContainer &&
            widget.duration == Duration.zero &&
            widget.curve == Curves.easeInOut &&
            widget.transform == Matrix4.translationValues(0.0, 0.0, 0.0)),
        findsOneWidget);

    expect(find.byWidget(givenChild), findsOneWidget);
  });

  testWidgets(
      'GIVEN isDragging = true '
      'WHEN pumping [ReorderableAnimatedDraggingContainer] '
      'THEN should show expected widget with expected values',
      (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(tester, isDragging: true);

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is AnimatedContainer &&
            widget.duration == const Duration(milliseconds: 300) &&
            widget.curve == Curves.easeInOut &&
            widget.transform == Matrix4.translationValues(100, 100, 0)),
        findsOneWidget);

    expect(find.byWidget(givenChild), findsOneWidget);
  });
}
