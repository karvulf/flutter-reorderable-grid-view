import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_item_builder_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reorderable_builder.dart';

void main() {
  late ReorderableItemBuilderController controller;

  final reorderableBuilder = ReorderableBuilder();

  setUp(() {
    controller = ReorderableItemBuilderController();
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
      itemCount: null,
    );
  }

  group('#buildItem', () {
    test(
        'GIVEN draggedEntity != null and existing in childrenKeyMap '
        'WHEN calling buildItem '
        'THEN should return reorderableEntity in childrenKeyMap', () {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(key: '1');
      controller.childrenKeyMap.addAll({
        '1': givenReorderableEntity,
      });
      setUpDragStarted(reorderableEntity: givenReorderableEntity);

      // when
      final actual = controller.buildItem(
        key: const ValueKey('1'),
        index: 999,
      );

      // then
      expect(actual, equals(givenReorderableEntity));
    });

    test(
        'GIVEN draggedEntity != null but NOT existing in childrenKeyMap '
        'WHEN calling buildItem '
        'THEN should return expected reorderableEntity and '
        'update childrenKeyMap and childrenOrderMap in controller', () {
      // given
      const givenKey = ValueKey('1');
      final givenReorderableEntity = reorderableBuilder.getEntity(
        key: givenKey.value,
      );
      setUpDragStarted(reorderableEntity: givenReorderableEntity);

      // when
      final actual = controller.buildItem(
        key: givenKey,
        index: 999,
      );

      // then
      final expectedReorderableEntity = ReorderableEntity.create(
        key: givenKey,
        updatedOrderId: 999,
        offset: null,
        size: null,
      );
      expect(actual, equals(expectedReorderableEntity));

      final expectedChildrenKeyMap = {
        givenKey.value: expectedReorderableEntity,
      };
      expect(controller.childrenKeyMap, equals(expectedChildrenKeyMap));

      final expectedChildrenOrderMap = {-1: expectedReorderableEntity};
      expect(controller.childrenOrderMap, equals(expectedChildrenOrderMap));
    });

    test(
        'GIVEN draggedEntity = null and key existing in childrenKeyMap '
        'WHEN calling buildItem '
        'THEN should return expected reorderableEntity and '
        'update childrenKeyMap and childrenOrderMap in controller', () {
      // given
      const givenKey = ValueKey('1');
      final givenReorderableEntity = reorderableBuilder.getEntity(
        key: givenKey.value,
        originalOrderId: 0,
      );
      controller.childrenKeyMap.addAll({
        givenKey.value: givenReorderableEntity,
      });

      // when
      final actual = controller.buildItem(
        key: givenKey,
        index: 999,
      );

      // then
      final expectedReorderableEntity = givenReorderableEntity.updated(
        updatedOrderId: 999,
        updatedOffset: null,
        size: null,
      );
      expect(actual, equals(expectedReorderableEntity));

      final expectedChildrenKeyMap = {
        givenKey.value: expectedReorderableEntity,
      };
      expect(controller.childrenKeyMap, equals(expectedChildrenKeyMap));

      final expectedChildrenOrderMap = {
        expectedReorderableEntity.originalOrderId: expectedReorderableEntity,
      };
      expect(controller.childrenOrderMap, equals(expectedChildrenOrderMap));
    });
  });
}
