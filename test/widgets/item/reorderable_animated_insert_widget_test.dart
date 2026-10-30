import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/item/reorderable_animated_insert.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../reorderable_builder.dart';

void main() {
  final reorderableBuilder = ReorderableBuilder();
  const givenChild = SizedBox.square(
    dimension: 200.0,
    child: Placeholder(),
  );
  const givenInsertDuration = Duration(milliseconds: 1000);

  Future<void> pumpWidget(
    WidgetTester tester, {
    required ReorderableEntity reorderableEntity,
    required VoidCallback onAnimationStarted,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableAnimatedInsert(
              animationConfig: const ReorderableAnimationConfig(
                insert:
                    ReorderableItemTransition(duration: givenInsertDuration),
                draggingPositionChangeCurve: Curves.easeInCubic,
                positionChangeCurve: Curves.elasticIn,
              ),
              onAnimationStarted: onAnimationStarted,
              reorderableEntity: reorderableEntity,
              child: givenChild,
            ),
          ),
        ),
      );

  testWidgets(
      'GIVEN insert duration and reorderableEntity is new '
      'WHEN pumping [ReorderableAnimatedInsert] '
      'THEN should show expected FadeTransition', (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity(
      originalOrderId: -1,
    );
    int callCounter = 0;

    // when
    await pumpWidget(
      tester,
      reorderableEntity: givenReorderableEntity,
      onAnimationStarted: () {
        callCounter++;
      },
    );
    await tester.pump();
    await tester.pump(givenInsertDuration);

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is FadeTransition &&
            widget.opacity.value == 1.0 &&
            widget.child == givenChild,
      ),
      findsOneWidget,
    );
    expect(callCounter, equals(1));
  });

  testWidgets(
      'GIVEN reorderableEntity which is NOT new  '
      'WHEN pumping [ReorderableAnimatedInsert] '
      'THEN should NOT call onAnimationStarted', (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity(
      originalOrderId: 0,
    );
    int callCounter = 0;

    // when
    await pumpWidget(
      tester,
      reorderableEntity: givenReorderableEntity,
      onAnimationStarted: () {
        callCounter++;
      },
    );
    await tester.pumpAndSettle();

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is FadeTransition &&
            widget.opacity.value == 1.0 &&
            widget.child == givenChild,
      ),
      findsOneWidget,
    );

    expect(callCounter, equals(0));
  });

  testWidgets(
      'GIVEN pumped [ReorderableAnimatedInsert] '
      'WHEN reorderableEntity is updated but isNew = false '
      'THEN should call onOpacityFinished only one time (from initState)',
      (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity(
      key: '0',
      originalOrderId: -1,
    );
    final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
      key: '1',
    );
    int callCounter = 0;

    void onAnimationStarted() => callCounter++;

    await pumpWidget(
      tester,
      reorderableEntity: givenReorderableEntity,
      onAnimationStarted: onAnimationStarted,
    );
    await tester.pumpAndSettle();

    // when
    await pumpWidget(
      tester,
      reorderableEntity: givenUpdatedReorderableEntity,
      onAnimationStarted: onAnimationStarted,
    );
    await tester.pumpAndSettle();

    // then
    expect(callCounter, equals(1));
  });

  testWidgets(
      'GIVEN pumped [ReorderableAnimatedInsert] '
      'WHEN reorderableEntity is updated and isNew = true '
      'THEN should call onOpacityFinished two times (from initState)',
      (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity(
      key: '0',
      originalOrderId: -1,
    );
    final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
      key: '1',
      originalOrderId: -1,
    );
    int callCounter = 0;

    void onAnimationStarted() => callCounter++;

    await pumpWidget(
      tester,
      reorderableEntity: givenReorderableEntity,
      onAnimationStarted: onAnimationStarted,
    );
    await tester.pumpAndSettle();

    // when
    await pumpWidget(
      tester,
      reorderableEntity: givenUpdatedReorderableEntity,
      onAnimationStarted: onAnimationStarted,
    );
    await tester.pumpAndSettle();

    // then
    expect(callCounter, equals(2));
  });
}
