import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

    test(
        'GIVEN drag started with collision that is two indices behind dragged child '
        'WHEN calling handleDragUpdate '
        'THEN should return true and have expected maps', () {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        updatedOffset: const Offset(12.0, 13.0),
        updatedOrderId: 3,
        key: '3',
      );
      final givenBehindReorderableEntity = reorderableBuilder.getEntity(
        updatedOffset: const Offset(11.0, 12.0),
        updatedOrderId: 1,
        key: '1',
      );
      final givenBehindReorderableEntity2 = reorderableBuilder.getEntity(
        updatedOffset: const Offset(100.0, 200.0),
        updatedOrderId: 2,
        key: '2',
      );
      controller.childrenKeyMap.addAll({
        '3': givenReorderableEntity,
        '1': givenBehindReorderableEntity,
        '2': givenBehindReorderableEntity2,
      });
      controller.childrenOrderMap.addAll({
        1: givenBehindReorderableEntity,
        2: givenBehindReorderableEntity2,
        3: givenReorderableEntity,
      });
      setUpDragStarted(
        reorderableEntity: givenReorderableEntity,
        isScrollableOutside: true,
      );

      // when
      final actual = controller.handleDragUpdate(
        pointerMoveEvent: PointerMoveEvent(
          position: givenBehindReorderableEntity.updatedOffset,
        ),
      );

      // then
      expect(actual, isTrue);

      final expectedChildrenKeyMap = {
        '3': givenReorderableEntity.dragUpdated(
          updatedOffset: givenBehindReorderableEntity.updatedOffset,
          updatedOrderId: 1,
        ),
        '1': givenBehindReorderableEntity.dragUpdated(
          updatedOffset: givenBehindReorderableEntity2.updatedOffset,
          updatedOrderId: 2,
        ),
        '2': givenBehindReorderableEntity2.dragUpdated(
          updatedOffset: givenReorderableEntity.updatedOffset,
          updatedOrderId: 3,
        ),
      };
      expect(controller.childrenKeyMap, equals(expectedChildrenKeyMap));

      final expectedChildrenOrderMap = {
        1: givenReorderableEntity.dragUpdated(
          updatedOffset: givenBehindReorderableEntity.updatedOffset,
          updatedOrderId: 1,
        ),
        2: givenBehindReorderableEntity.dragUpdated(
          updatedOffset: givenBehindReorderableEntity2.updatedOffset,
          updatedOrderId: 2,
        ),
        3: givenBehindReorderableEntity2.dragUpdated(
          updatedOffset: givenReorderableEntity.updatedOffset,
          updatedOrderId: 3,
        ),
      };
      expect(controller.childrenOrderMap, equals(expectedChildrenOrderMap));
    });

    test(
        'GIVEN drag started with collision that is two indices in front dragged child '
        'WHEN calling handleDragUpdate '
        'THEN should return true and have expected maps', () {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        updatedOffset: const Offset(11.0, 12.0),
        updatedOrderId: 1,
        key: '1',
      );
      final givenBehindReorderableEntity = reorderableBuilder.getEntity(
        updatedOffset: const Offset(100.0, 200.0),
        updatedOrderId: 2,
        key: '2',
      );
      final givenBehindReorderableEntity2 = reorderableBuilder.getEntity(
        updatedOffset: const Offset(12.0, 13.0),
        updatedOrderId: 3,
        key: '3',
      );
      controller.childrenKeyMap.addAll({
        '1': givenReorderableEntity,
        '2': givenBehindReorderableEntity,
        '3': givenBehindReorderableEntity2,
      });
      controller.childrenOrderMap.addAll({
        1: givenReorderableEntity,
        2: givenBehindReorderableEntity,
        3: givenBehindReorderableEntity2,
      });
      setUpDragStarted(
        reorderableEntity: givenReorderableEntity,
        isScrollableOutside: false,
      );

      // when
      final actual = controller.handleDragUpdate(
        pointerMoveEvent: PointerMoveEvent(
          position: givenBehindReorderableEntity2.updatedOffset,
        ),
      );

      // then
      expect(actual, isTrue);

      final expectedChildrenKeyMap = {
        '1': givenReorderableEntity.dragUpdated(
          updatedOffset: givenBehindReorderableEntity2.updatedOffset,
          updatedOrderId: 3,
        ),
        '2': givenBehindReorderableEntity.dragUpdated(
          updatedOffset: givenReorderableEntity.updatedOffset,
          updatedOrderId: 1,
        ),
        '3': givenBehindReorderableEntity2.dragUpdated(
          updatedOffset: givenBehindReorderableEntity.updatedOffset,
          updatedOrderId: 2,
        ),
      };
      expect(controller.childrenKeyMap, equals(expectedChildrenKeyMap));

      final expectedChildrenOrderMap = {
        1: givenBehindReorderableEntity.dragUpdated(
          updatedOffset: givenReorderableEntity.updatedOffset,
          updatedOrderId: 1,
        ),
        2: givenBehindReorderableEntity2.dragUpdated(
          updatedOffset: givenBehindReorderableEntity.updatedOffset,
          updatedOrderId: 2,
        ),
        3: givenReorderableEntity.dragUpdated(
          updatedOffset: givenBehindReorderableEntity2.updatedOffset,
          updatedOrderId: 3,
        ),
      };
      expect(controller.childrenOrderMap, equals(expectedChildrenOrderMap));
    });

    test(
        'GIVEN drag started with collision that is one index in front dragged child '
        'WHEN calling handleDragUpdate '
        'THEN should return true and have expected maps', () {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        updatedOffset: const Offset(11.0, 12.0),
        updatedOrderId: 1,
        key: '1',
      );
      final givenBehindReorderableEntity = reorderableBuilder.getEntity(
        updatedOffset: const Offset(100.0, 200.0),
        updatedOrderId: 2,
        key: '2',
      );
      final givenBehindReorderableEntity2 = reorderableBuilder.getEntity(
        updatedOffset: const Offset(12.0, 13.0),
        updatedOrderId: 3,
        key: '3',
      );
      controller.childrenKeyMap.addAll({
        '1': givenReorderableEntity,
        '2': givenBehindReorderableEntity,
        '3': givenBehindReorderableEntity2,
      });
      controller.childrenOrderMap.addAll({
        1: givenReorderableEntity,
        2: givenBehindReorderableEntity,
        3: givenBehindReorderableEntity2,
      });
      setUpDragStarted(
        reorderableEntity: givenReorderableEntity,
        isScrollableOutside: false,
      );

      // when
      final actual = controller.handleDragUpdate(
        pointerMoveEvent: PointerMoveEvent(
          position: givenBehindReorderableEntity.updatedOffset,
        ),
      );

      // then
      expect(actual, isTrue);

      final expectedChildrenKeyMap = {
        '1': givenReorderableEntity.dragUpdated(
          updatedOffset: givenBehindReorderableEntity.updatedOffset,
          updatedOrderId: 2,
        ),
        '2': givenBehindReorderableEntity.dragUpdated(
          updatedOffset: givenReorderableEntity.updatedOffset,
          updatedOrderId: 1,
        ),
        '3': givenBehindReorderableEntity2,
      };
      expect(controller.childrenKeyMap, equals(expectedChildrenKeyMap));

      final expectedChildrenOrderMap = {
        1: givenBehindReorderableEntity.dragUpdated(
          updatedOffset: givenReorderableEntity.updatedOffset,
          updatedOrderId: 1,
        ),
        2: givenReorderableEntity.dragUpdated(
          updatedOffset: givenBehindReorderableEntity.updatedOffset,
          updatedOrderId: 2,
        ),
        3: givenBehindReorderableEntity2,
      };
      expect(controller.childrenOrderMap, equals(expectedChildrenOrderMap));
    });
  });

  group('#handleDragEnd', () {
    test(
        'GIVEN draggedEntity = null '
        'WHEN calling handleDragEnd '
        'THEN should return null', () {
      // given

      // when
      final actual = controller.handleDragEnd();

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN draggedEntity != null but original and updated orderId is the same '
        'WHEN calling handleDragEnd '
        'THEN should return null', () {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOrderId: 0,
        updatedOrderId: 0,
      );
      setUpDragStarted(reorderableEntity: givenReorderableEntity);

      // when
      final actual = controller.handleDragEnd();

      // then
      expect(actual, isNull);
    });


    test(
        'GIVEN draggedEntity '
            'WHEN calling handleDragEnd '
            'THEN should return null', () {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOrderId: 0,
        updatedOrderId: 0,
      );
      setUpDragStarted(reorderableEntity: givenReorderableEntity);

      // when
      final actual = controller.handleDragEnd();

      // then
      expect(actual, isNull);
    });
  });
}
