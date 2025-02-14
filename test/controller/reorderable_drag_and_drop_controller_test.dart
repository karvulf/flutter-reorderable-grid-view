import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_drag_and_drop_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/reorder_update_entity.dart';
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
    int? itemCount,
  }) {
    controller.handleDragStarted(
      reorderableEntity: reorderableEntity ?? reorderableBuilder.getEntity(),
      currentScrollOffset: currentScrollOffset,
      lockedIndices: lockedIndices,
      isScrollableOutside: isScrollableOutside,
      itemCount: itemCount,
    );
  }

  group('#handleDragStarted', () {
    test(
        'GIVEN dragged entity, offset, lockedIndices, isScrollableOutside, '
        'childrenKeyMap has givenDraggedEntity and itemCount '
        'WHEN calling handleDragStarted '
        'THEN should assign given values to expected values of controller and'
        'should remove the children which have a higher position than the itemCount',
        () {
      // given
      const givenItemCount = 1;
      const givenDraggedKeyValue = 'dragged_key';
      const givenRemoveKeyValue1 = 'remove1';
      const givenRemoveKeyValue2 = 'remove2';
      final givenDraggedEntity = reorderableBuilder.getEntity(
        originalOrderId: givenItemCount - 1,
        key: givenDraggedKeyValue,
      );
      final givenChildToRemove1 = reorderableBuilder.getEntity(
        originalOrderId: givenItemCount,
        key: givenRemoveKeyValue1,
      );
      final givenChildToRemove2 = reorderableBuilder.getEntity(
        originalOrderId: givenItemCount + 1,
        key: givenRemoveKeyValue2,
      );
      const givenOffset = Offset(100.0, 200.0);
      const givenLockedIndices = [0, 1, 2, 3];
      const givenIsScrollableOutside = true;

      controller.childrenKeyMap[givenDraggedKeyValue] = givenDraggedEntity;
      controller.childrenKeyMap[givenRemoveKeyValue1] = givenChildToRemove1;
      controller.childrenKeyMap[givenRemoveKeyValue2] = givenChildToRemove2;

      // when
      controller.handleDragStarted(
        reorderableEntity: givenDraggedEntity,
        currentScrollOffset: givenOffset,
        lockedIndices: givenLockedIndices,
        isScrollableOutside: givenIsScrollableOutside,
        itemCount: givenItemCount,
      );

      // then
      expect(controller.releasedReorderableEntity, isNull);
      expect(controller.lockedIndices, equals(givenLockedIndices));
      expect(controller.draggedEntity, equals(givenDraggedEntity));
      expect(controller.scrollOffset, equals(givenOffset));
      expect(controller.isScrollableOutside, equals(givenIsScrollableOutside));
      expect(controller.startDraggingScrollOffset, equals(givenOffset));
      final expectedMap = {givenDraggedKeyValue: givenDraggedEntity};
      expect(controller.childrenKeyMap, equals(expectedMap));
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
    void compareReorderUpdateEntities(
      List<ReorderUpdateEntity> actual,
      List<ReorderUpdateEntity> expected,
    ) {
      expect(actual.length, equals(expected.length));

      var index = 0;
      for (final expectedOrderUpdateEntity in expected) {
        final actualOldIndex = actual[index].oldIndex;
        final actualNewIndex = actual[index].newIndex;
        expect(actualOldIndex, equals(expectedOrderUpdateEntity.oldIndex));
        expect(actualNewIndex, equals(expectedOrderUpdateEntity.newIndex));
        index++;
      }
    }

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
        'GIVEN draggedEntity with originalOrderId = 0 and updatedOrderId = 1 '
        'WHEN calling handleDragEnd '
        'THEN should return list with one ReorderUpdateEntity', () {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOrderId: 0,
        updatedOrderId: 1,
        key: '1',
      );
      controller.childrenKeyMap.addAll({
        givenReorderableEntity.key.value: givenReorderableEntity,
      });
      controller.childrenOrderMap.addAll({
        0: givenReorderableEntity,
      });
      setUpDragStarted(reorderableEntity: givenReorderableEntity);

      // when
      final actual = controller.handleDragEnd();

      // then
      final expectedOrderUpdateEntities = [
        const ReorderUpdateEntity(oldIndex: 0, newIndex: 1),
      ];
      compareReorderUpdateEntities(actual!, expectedOrderUpdateEntities);
      final expectedKeyMap = {
        '1': givenReorderableEntity.positionUpdated(),
      };
      final expectedOrderMap = {
        1: givenReorderableEntity.positionUpdated(),
      };
      expect(controller.childrenKeyMap, equals(expectedKeyMap));
      expect(controller.childrenOrderMap, equals(expectedOrderMap));
    });

    test(
        'GIVEN draggedEntity with originalOrderId = 5 and updatedOrderId = 0 and '
        'lockedIndices = [1, 3] '
        'WHEN calling handleDragEnd '
        'THEN should return list with three ReorderUpdateEntity', () {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOrderId: 5,
        updatedOrderId: 0,
      );
      controller.childrenKeyMap.addAll({
        givenReorderableEntity.key.value: givenReorderableEntity,
      });
      setUpDragStarted(
        reorderableEntity: givenReorderableEntity,
        lockedIndices: [1, 3],
      );

      // when
      final actual = controller.handleDragEnd();

      // then
      final expectedOrderUpdateEntities = [
        const ReorderUpdateEntity(oldIndex: 5, newIndex: 0),
        const ReorderUpdateEntity(oldIndex: 3, newIndex: 4),
        const ReorderUpdateEntity(oldIndex: 1, newIndex: 2),
      ];
      compareReorderUpdateEntities(actual!, expectedOrderUpdateEntities);
    });
  });

  group('#reorderList', () {
    test(
        'GIVEN items with 5 ints and a list of three OrderUpdateEntity '
        'WHEN calling handleDragEnd '
        'THEN should return list with three ReorderUpdateEntity', () {
      // given
      final givenItems = [0, 1, 2, 3, 4, 5];
      final givenOrderUpdateEntities = [
        const ReorderUpdateEntity(oldIndex: 5, newIndex: 0),
        const ReorderUpdateEntity(oldIndex: 3, newIndex: 4),
        const ReorderUpdateEntity(oldIndex: 1, newIndex: 2),
      ];

      // when
      final actual = controller.reorderList(
        items: givenItems,
        reorderUpdateEntities: givenOrderUpdateEntities,
      );

      // then
      final expectedList = [5, 1, 0, 3, 2, 4];
      expect(actual, equals(expectedList));
    });
  });
}
