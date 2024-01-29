import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/definitions.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_positioned.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reorderable_builder.dart';

void main() {
  final reorderableBuilder = ReorderableBuilder();

  const givenPositionDuration = Duration(milliseconds: 300);
  const givenChild = Placeholder();

  Future<void> pumpWidget(
    WidgetTester tester, {
    required ReorderableEntity reorderableEntity,
    required bool isDragging,
    required ReorderableEntityCallback onMovingFinished,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableAnimatedPositioned(
              reorderableEntity: reorderableEntity,
              isDragging: isDragging,
              positionDuration: givenPositionDuration,
              onMovingFinished: onMovingFinished,
              child: givenChild,
            ),
          ),
        ),
      );

  testWidgets('GIVEN WHEN THEN', (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity();

    // when
    await pumpWidget(
      tester,
      reorderableEntity: givenReorderableEntity,
      isDragging: true,
      onMovingFinished: (_) {},
    );

    // then
  });
}
