import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_container.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_dragging_container.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_opacity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_update_container.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenChild = Text('hallo');
  const givenReorderableEntity = ReorderableEntity(
    child: givenChild,
    originalOrderId: 0,
    updatedOrderId: 0,
    isBuilding: false,
  );

  Future<void> pumpWidget(WidgetTester tester) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableAnimatedContainer(
              onOpacityFinished: (_) {},
              reorderableEntity: givenReorderableEntity,
              isDragging: false,
              onMovingFinished: (_, __) {},
              child: givenChild,
            ),
          ),
        ),
      );

  testWidgets(
      'GIVEN child '
      'WHEN pumping [ReorderableAnimatedContainer] '
      'THEN should show expected widgets', (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(tester);

    // then
    expect(find.byType(ReorderableAnimatedOpacity), findsOneWidget);
    expect(find.byType(ReorderableAnimatedDraggingContainer), findsOneWidget);
    expect(find.byType(ReorderableAnimatedUpdatedContainer), findsOneWidget);

    expect(find.byWidget(givenChild), findsOneWidget);
  });
}
