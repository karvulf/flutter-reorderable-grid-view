import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/drag/drag_feedback_transition.dart';
import 'package:flutter_reorderable_grid_view/widgets/drag/reorderable_animated_released_container.dart';
import 'package:flutter_reorderable_grid_view/widgets/drag/reorderable_overlay_child.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../reorderable_builder.dart';

void main() {
  final reorderableBuilder = ReorderableBuilder();

  const givenReleasedItemDuration = Duration(milliseconds: 555);
  const givenFeedbackScaleFactor = 1.5;
  const givenScrollOffset = Offset(1.0, 2.0);
  const givenChild = Placeholder();
  final givenReorderableEntity = reorderableBuilder.getEntity(
    updatedOffset: const Offset(123.0, 456.0),
  );
  final givenReleasedEntity = reorderableBuilder.getReleasedEntity(
    dropOffset: const Offset(100.0, 200.0),
    reorderableEntity: givenReorderableEntity,
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    required ReleasedReorderableEntity? releasedEntity,
    Duration releasedItemDuration = givenReleasedItemDuration,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          home: ReorderableAnimatedReleasedContainer(
            animationConfig: ReorderableAnimationConfig(
              releasedItemDuration: releasedItemDuration,
            ),
            feedbackScaleFactor: givenFeedbackScaleFactor,
            releasedReorderableEntity: releasedEntity,
            reorderableEntity: givenReorderableEntity,
            scrollOffset: givenScrollOffset,
            child: givenChild,
          ),
        ),
      );

  testWidgets(
      'GIVEN releasedEntity '
      'WHEN pumping [ReorderableAnimatedReleasedContainer] '
      'THEN should show child without release animation',
      (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(tester, releasedEntity: givenReleasedEntity);

    // then
    expect(find.byWidget(givenChild), findsOneWidget);
    expect(find.byType(ReorderableOverlayChild), findsNothing);
  });

  group('#didUpdateWidget', () {
    testWidgets(
        'GIVEN pumped [ReorderableAnimatedReleasedContainer] '
        'WHEN updating with same releasedEntity '
        'THEN should show child without release animation',
        (WidgetTester tester) async {
      // given
      await pumpWidget(tester, releasedEntity: givenReleasedEntity);

      // when
      await pumpWidget(tester, releasedEntity: givenReleasedEntity);

      // then
      expect(find.byWidget(givenChild), findsOneWidget);
      expect(find.byType(ReorderableOverlayChild), findsNothing);
    });

    testWidgets(
        'GIVEN pumped [ReorderableAnimatedReleasedContainer] '
        'WHEN updating with releasedEntity = null '
        'THEN should show child without release animation',
        (WidgetTester tester) async {
      // given
      await pumpWidget(tester, releasedEntity: givenReleasedEntity);

      // when
      await pumpWidget(tester, releasedEntity: null);

      // then
      expect(find.byWidget(givenChild), findsOneWidget);
      expect(find.byType(ReorderableOverlayChild), findsNothing);
    });

    testWidgets(
        'GIVEN pumped [ReorderableAnimatedReleasedContainer] '
        'WHEN updating with releasedEntity of another key '
        'THEN should show child without release animation',
        (WidgetTester tester) async {
      // given
      final givenUpdatedReleasedEntity = reorderableBuilder.getReleasedEntity(
        dropOffset: const Offset(111.0, 222.0),
        reorderableEntity: reorderableBuilder.getEntity(key: 'updated'),
      );
      await pumpWidget(tester, releasedEntity: givenReleasedEntity);

      // when
      await pumpWidget(tester, releasedEntity: givenUpdatedReleasedEntity);

      // then
      expect(find.byWidget(givenChild), findsOneWidget);
      expect(find.byType(ReorderableOverlayChild), findsNothing);
    });

    testWidgets(
        'GIVEN pumped [ReorderableAnimatedReleasedContainer] '
        'WHEN updating with new releasedEntity of same key '
        'THEN should show child in overlay at drop offset with lifted feedback',
        (WidgetTester tester) async {
      // given
      final givenUpdatedReleasedEntity = reorderableBuilder.getReleasedEntity(
        dropOffset: const Offset(111.0, 222.0),
        reorderableEntity: givenReorderableEntity,
      );
      await pumpWidget(tester, releasedEntity: givenReleasedEntity);

      // when
      await pumpWidget(tester, releasedEntity: givenUpdatedReleasedEntity);
      await tester.pump();

      // then
      final expectedOffset = givenUpdatedReleasedEntity.dropOffset -
          givenReorderableEntity.updatedOffset +
          givenScrollOffset;
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableOverlayChild &&
              widget.size == givenReorderableEntity.size &&
              widget.child is Transform &&
              (widget.child as Transform).transform ==
                  Matrix4.translationValues(
                    expectedOffset.dx,
                    expectedOffset.dy,
                    0.0,
                  ),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is DragFeedbackTransition &&
              widget.feedbackScaleFactor == givenFeedbackScaleFactor &&
              widget.animation.value == 1.0,
        ),
        findsOneWidget,
      );
      expect(find.byWidget(givenChild), findsOneWidget);
    });

    testWidgets(
        'GIVEN started release animation '
        'WHEN waiting until animation was done '
        'THEN should show child without release animation',
        (WidgetTester tester) async {
      // given
      final givenUpdatedReleasedEntity = reorderableBuilder.getReleasedEntity(
        dropOffset: const Offset(111.0, 222.0),
        reorderableEntity: givenReorderableEntity,
      );
      await pumpWidget(tester, releasedEntity: givenReleasedEntity);
      await pumpWidget(tester, releasedEntity: givenUpdatedReleasedEntity);

      // when
      await tester.pumpAndSettle();

      // then
      expect(find.byWidget(givenChild), findsOneWidget);
      expect(find.byType(ReorderableOverlayChild), findsNothing);
    });
  });
}
