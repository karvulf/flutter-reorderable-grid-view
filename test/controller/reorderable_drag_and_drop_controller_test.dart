import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_drag_and_drop_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reorderable_builder.dart';

void main() {
  late ReorderableDragAndDropController controller;

  final reorderableBuilder = ReorderableBuilder();

  setUp(() {
    controller = ReorderableDragAndDropController();
  });

  void setUpDragStarted({
    ReorderableEntity? reorderableEntity,
    Offset currentScrollOffset = Offset.zero,
    List<int> lockedIndices = const [],
    bool isScrollableOutside = false,
  }) {
    controller.handleDragStarted(
      reorderableEntity: reorderableEntity ?? reorderableBuilder.getEntity(),
      currentScrollOffset: currentScrollOffset,
      lockedIndices: lockedIndices,
      isScrollableOutside: isScrollableOutside,
    );
  }

  group('#handleDragStarted', () {
    test(
        'GIVEN dragged entity, offset, lockedIndices, isScrollableOutside and '
        'childrenKeyMap has givenDraggedEntity '
        'WHEN calling handleDragStarted '
        'THEN should assign given values to expected values of controller', () {
      // given
      final givenDraggedEntity = reorderableBuilder.getEntity();
      const givenOffset = Offset(100.0, 200.0);
      const givenLockedIndices = [0, 1, 2, 3];
      const givenIsScrollableOutside = true;
      final givenDraggedKeyValue = givenDraggedEntity.key.value;
      controller.childrenKeyMap[givenDraggedKeyValue] = givenDraggedEntity;

      // when
      controller.handleDragStarted(
        reorderableEntity: givenDraggedEntity,
        currentScrollOffset: givenOffset,
        lockedIndices: givenLockedIndices,
        isScrollableOutside: givenIsScrollableOutside,
      );

      // then
      expect(controller.releasedReorderableEntity, isNull);
      expect(controller.lockedIndices, equals(givenLockedIndices));
      expect(controller.draggedEntity, equals(givenDraggedEntity));
      expect(controller.scrollOffset, equals(givenOffset));
      expect(controller.isScrollableOutside, equals(givenIsScrollableOutside));
      expect(controller.startDraggingScrollOffset, equals(givenOffset));
    });
  });

  group('#handleDragUpdate', () {
    test(
        'GIVEN pointerMoveEvent and draggedEntity = null '
        'WHEN calling handleDragUpdate '
        'THEN should return false', () {
      // given

      // when
      final actual = controller.handleDragUpdate(
        pointerMoveEvent: const PointerMoveEvent(),
      );

      // then
      expect(actual, isFalse);
    });

    test(
        'GIVEN drag started but no collision entity found '
        'WHEN calling handleDragUpdate '
        'THEN should return false', () {
      // given
      setUpDragStarted(
        reorderableEntity: reorderableBuilder.getEntity(),
      );

      // when
      final actual = controller.handleDragUpdate(
        pointerMoveEvent: const PointerMoveEvent(),
      );

      // then
      expect(actual, isFalse);
    });

    test(
        'GIVEN drag started, collision entity found '
        'but updated orderId is in lockedIndices '
        'WHEN calling handleDragUpdate '
        'THEN should return false', () {
      // given
      const givenOffset = Offset(12.0, 13.0);
      const givenUpdatedOrderId = 3;
      final givenReorderableEntity = reorderableBuilder.getEntity(
        updatedOffset: givenOffset,
        updatedOrderId: givenUpdatedOrderId,
      );
      controller.childrenKeyMap.addAll({
        givenReorderableEntity.key.value: givenReorderableEntity,
        'other': givenReorderableEntity,
      });
      setUpDragStarted(
        reorderableEntity: givenReorderableEntity,
        isScrollableOutside: true,
        lockedIndices: [givenUpdatedOrderId],
      );

      // when
      final actual = controller.handleDragUpdate(
        pointerMoveEvent: const PointerMoveEvent(position: givenOffset),
      );

      // then
      expect(actual, isFalse);
    });
  });
}
