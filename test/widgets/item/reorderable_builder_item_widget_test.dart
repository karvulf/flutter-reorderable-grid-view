import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/dragging_animation_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/definitions.dart';
import 'package:flutter_reorderable_grid_view/widgets/item/reorderable_animated_insert.dart';
import 'package:flutter_reorderable_grid_view/widgets/item/reorderable_animated_positioned.dart';
import 'package:flutter_reorderable_grid_view/widgets/drag/reorderable_animated_released_container.dart';
import 'package:flutter_reorderable_grid_view/widgets/item/reorderable_builder_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/drag/reorderable_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/item/reorderable_init_child.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helper/widget_test_helper.dart';
import '../../reorderable_builder.dart';

void main() {
  final reorderableBuilder = ReorderableBuilder();

  final givenReorderableEntity = reorderableBuilder.getEntity(
    key: 'initial',
  );
  final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
    key: 'Updated',
  );
  const givenInsertDuration = Duration(milliseconds: 300);
  const givenPositionDuration = Duration(milliseconds: 400);
  const givenReleasedChildDuration = Duration(milliseconds: 500);
  const givenAnimationConfig = ReorderableAnimationConfig(
    insert: ReorderableItemTransition(duration: givenInsertDuration),
    positionChangeDuration: givenPositionDuration,
    releasedItemDuration: givenReleasedChildDuration,
  );
  final givenReleasedReorderableEntity = reorderableBuilder.getReleasedEntity();
  const givenScrollOffset = Offset(11.1, 12.2);
  const givenEnableDraggable = true;
  const givenEnableLongPress = false;
  const givenLongPressDelay = Duration(milliseconds: 600);
  const givenDragChildBoxDecoration = BoxDecoration();
  const givenFeedbackScaleFactor = 1.31;
  const givenChild = Placeholder();
  final givenDraggingAnimationMap = <ValueKey, DraggingAnimationEntity>{};

  // functions
  ReorderableEntity givenOnOpacityFinished(
    ReorderableEntity reorderableEntity,
  ) {
    return givenReorderableEntity;
  }

  ReorderableEntity givenOnMovingFinished(
    ReorderableEntity reorderableEntity,
  ) {
    return givenReorderableEntity;
  }

  Duration givenPositionChangeDelay() => const Duration(milliseconds: 100);

  ReorderableEntity givenOnCreated(
    ReorderableEntity reorderableEntity,
    GlobalKey key,
  ) {
    return givenReorderableEntity;
  }

  void givenOnDragStarted(
    ReorderableEntity reorderableEntity,
  ) {}

  void givenOnDragEnd(
    ReorderableEntity reorderableEntity,
    Offset? globalOffset,
  ) {}

  void givenOnDragCanceled(
    ReorderableEntity reorderableEntity,
  ) {}

  Future<void> pumpWidget(
    WidgetTester tester, {
    ReorderableEntity? reorderableEntity,
    ReorderableEntity? currentDraggedEntity,
    ReturnReorderableEntityCallback? onOpacityFinished,
    ReturnReorderableEntityCallback? onMovingFinished,
    ReturnOnCreatedFunction? onCreated,
    ReorderableEntityCallback? onDragStarted,
    OnDragEndFunction? onDragEnd,
    ReorderableEntityCallback? onDragCanceled,
    VoidCallback? onDisposed,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: ReorderableBuilderItem(
            reorderableEntity: reorderableEntity ?? givenReorderableEntity,
            animationConfig: givenAnimationConfig,
            onOpacityFinished: onOpacityFinished ?? givenOnOpacityFinished,
            currentDraggedEntity: currentDraggedEntity,
            onMovingFinished: onMovingFinished ?? givenOnMovingFinished,
            draggingAnimationMap: givenDraggingAnimationMap,
            positionChangeDelay: givenPositionChangeDelay,
            onDisposed: onDisposed,
            onCreated: onCreated ?? givenOnCreated,
            releasedReorderableEntity: givenReleasedReorderableEntity,
            scrollOffset: givenScrollOffset,
            enableDraggable: givenEnableDraggable,
            enableLongPress: givenEnableLongPress,
            longPressDelay: givenLongPressDelay,
            dragChildBoxDecoration: givenDragChildBoxDecoration,
            feedbackScaleFactor: givenFeedbackScaleFactor,
            onDragStarted: onDragStarted ?? givenOnDragStarted,
            onDragEnd: onDragEnd ?? givenOnDragEnd,
            onDragCanceled: onDragCanceled ?? givenOnDragCanceled,
            child: givenChild,
          ),
        ),
      );

  testWidgets(
      "GIVEN values with currentDraggedEntity == null "
      "WHEN pumping [ReorderableBuilderItem] "
      "THEN should show expected widgets", (tester) async {
    // given

    // when
    await pumpWidget(
      tester,
      currentDraggedEntity: null,
    );

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ReorderableAnimatedPositioned &&
            widget.reorderableEntity == givenReorderableEntity &&
            widget.draggedEntity == null &&
            identical(widget.draggingAnimationMap, givenDraggingAnimationMap) &&
            widget.positionChangeDelay == givenPositionChangeDelay &&
            widget.animationConfig == givenAnimationConfig &&
            widget.child is ReorderableAnimatedInsert,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ReorderableInitChild &&
            widget.reorderableEntity == givenReorderableEntity &&
            widget.child is ReorderableAnimatedPositioned,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ReorderableAnimatedInsert &&
            widget.reorderableEntity == givenReorderableEntity &&
            widget.animationConfig == givenAnimationConfig &&
            widget.child is ReorderableAnimatedReleasedContainer,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ReorderableAnimatedReleasedContainer &&
            widget.reorderableEntity == givenReorderableEntity &&
            widget.releasedReorderableEntity ==
                givenReleasedReorderableEntity &&
            widget.scrollOffset == givenScrollOffset &&
            widget.animationConfig == givenAnimationConfig &&
            widget.feedbackScaleFactor == givenFeedbackScaleFactor &&
            widget.child is ReorderableDraggable,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ReorderableDraggable &&
            widget.reorderableEntity == givenReorderableEntity &&
            widget.enableDraggable == givenEnableDraggable &&
            widget.currentDraggedEntity == null &&
            widget.enableLongPress == givenEnableLongPress &&
            widget.longPressDelay == givenLongPressDelay &&
            widget.feedbackScaleFactor == givenFeedbackScaleFactor &&
            widget.dragChildBoxDecoration == givenDragChildBoxDecoration &&
            widget.animationConfig == givenAnimationConfig &&
            widget.child == givenChild,
      ),
      findsOneWidget,
    );
  });

  testWidgets(
      "GIVEN values with currentDraggedEntity != null "
      "WHEN pumping [ReorderableBuilderItem] "
      "THEN should show expected widgets", (tester) async {
    // given

    // when
    await pumpWidget(
      tester,
      currentDraggedEntity: givenReorderableEntity,
    );

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ReorderableAnimatedPositioned &&
            widget.draggedEntity == givenReorderableEntity,
      ),
      findsOneWidget,
    );
  });

  group('#calling functions', () {
    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN removing it from the widget tree "
        "THEN should call onDisposed once", (tester) async {
      // given
      int callCounter = 0;
      await pumpWidget(tester, onDisposed: () => callCounter++);

      // when
      await tester.pumpWidget(const SizedBox());

      // then
      expect(callCounter, equals(1));
    });

    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN calling onAnimationStarted "
        "THEN should update reorderableEntity and call onOpacityFinished",
        (tester) async {
      // given
      ReorderableEntity? actualReorderableEntity;

      await pumpWidget(
        tester,
        onOpacityFinished: (reorderableEntity) {
          actualReorderableEntity = reorderableEntity;
          return givenUpdatedReorderableEntity;
        },
      );

      // when
      findWidget<ReorderableAnimatedInsert>().onAnimationStarted();
      // calling pumpAndSettle would init the normal fade in
      await tester.pump();

      // then
      expect(actualReorderableEntity, equals(givenReorderableEntity));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableDraggable &&
              widget.reorderableEntity == givenUpdatedReorderableEntity,
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN calling onMovingFinished "
        "THEN should update reorderableEntity and call onMovingFinished",
        (tester) async {
      // given
      ReorderableEntity? actualReorderableEntity;

      await pumpWidget(
        tester,
        onMovingFinished: (reorderableEntity) {
          actualReorderableEntity = reorderableEntity;
          return givenUpdatedReorderableEntity;
        },
      );

      // when
      findWidget<ReorderableAnimatedPositioned>().onMovingFinished();
      await tester.pump();

      // then
      expect(actualReorderableEntity, equals(givenReorderableEntity));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableDraggable &&
              widget.reorderableEntity == givenUpdatedReorderableEntity,
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN calling onCreated "
        "THEN should update reorderableEntity and call onCreated",
        (tester) async {
      // given
      final givenKey = GlobalKey();
      ReorderableEntity? actualReorderableEntity;
      GlobalKey? actualKey;

      await pumpWidget(
        tester,
        onCreated: (reorderableEntity, key) {
          actualReorderableEntity = reorderableEntity;
          actualKey = key;
          return givenUpdatedReorderableEntity;
        },
      );
      await tester.pumpAndSettle();

      // when
      findWidget<ReorderableInitChild>().onCreated(givenKey);
      await tester.pump();

      // then
      expect(actualReorderableEntity, equals(givenReorderableEntity));
      expect(actualKey, equals(givenKey));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableDraggable &&
              widget.reorderableEntity == givenUpdatedReorderableEntity,
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN calling onDragStarted "
        "THEN should call onDragStarted", (tester) async {
      // given
      ReorderableEntity? actualReorderableEntity;

      await pumpWidget(
        tester,
        onDragStarted: (reorderableEntity) {
          actualReorderableEntity = reorderableEntity;
        },
      );
      await tester.pumpAndSettle();

      // when
      findWidget<ReorderableDraggable>().onDragStarted();
      await tester.pump();

      // then
      expect(actualReorderableEntity, equals(givenReorderableEntity));
    });

    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN calling onDragEnd "
        "THEN should call onDragEnd", (tester) async {
      // given
      const givenOffset = Offset(12.34, 56.78);
      ReorderableEntity? actualReorderableEntity;
      Offset? actualGlobalOffset;

      await pumpWidget(
        tester,
        onDragEnd: (reorderableEntity, globalOffset) {
          actualReorderableEntity = reorderableEntity;
          actualGlobalOffset = globalOffset;
        },
      );
      await tester.pumpAndSettle();

      // when
      findWidget<ReorderableDraggable>().onDragEnd(givenOffset);
      await tester.pump();

      // then
      expect(actualReorderableEntity, equals(givenReorderableEntity));
      expect(actualGlobalOffset, equals(givenOffset));
    });

    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN calling onDragCanceled "
        "THEN should call onDragCanceled", (tester) async {
      // given
      ReorderableEntity? actualReorderableEntity;

      await pumpWidget(
        tester,
        onDragCanceled: (reorderableEntity) {
          actualReorderableEntity = reorderableEntity;
        },
      );
      await tester.pumpAndSettle();

      // when
      findWidget<ReorderableDraggable>().onDragCanceled();
      await tester.pump();

      // then
      expect(actualReorderableEntity, equals(givenReorderableEntity));
    });
  });

  group('#didUpdateWidget', () {
    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN updating with different reorderableEntity "
        "THEN should update reorderableEntity", (tester) async {
      // given
      await pumpWidget(tester);
      await tester.pumpAndSettle();

      // when
      await pumpWidget(
        tester,
        reorderableEntity: givenUpdatedReorderableEntity,
      );

      // then
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableDraggable &&
              widget.reorderableEntity == givenUpdatedReorderableEntity,
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        "GIVEN [ReorderableBuilderItem] with internally updated reorderableEntity "
        "WHEN updating with the same reorderableEntity "
        "THEN should keep reorderableEntity", (tester) async {
      // given
      ReorderableEntity onMovingFinished(ReorderableEntity _) =>
          givenUpdatedReorderableEntity;

      await pumpWidget(tester, onMovingFinished: onMovingFinished);
      findWidget<ReorderableAnimatedPositioned>().onMovingFinished();
      await tester.pump();

      // when
      await pumpWidget(
        tester,
        reorderableEntity: givenUpdatedReorderableEntity,
        onMovingFinished: onMovingFinished,
      );

      // then
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableDraggable &&
              widget.reorderableEntity == givenUpdatedReorderableEntity,
        ),
        findsOneWidget,
      );
    });
  });
}
