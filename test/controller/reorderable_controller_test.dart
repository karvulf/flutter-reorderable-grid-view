import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reorderable_builder.dart';

void main() {
  late ReorderableController controller;

  final reorderableBuilder = ReorderableBuilder();

  setUp(() {
    controller = _TestReorderableController();
  });

  void checkMaps({
    required ReorderableEntity expectedReorderableEntity,
  }) {
    expect(
      controller.childrenOrderMap[expectedReorderableEntity.originalOrderId],
      equals(expectedReorderableEntity),
    );
    expect(
      controller.childrenKeyMap[expectedReorderableEntity.key.value],
      equals(expectedReorderableEntity),
    );
  }

  group('#getReorderableEntity', () {
    const givenKey = ValueKey('id');
    const givenIndex = 0;
    const givenOffset = Offset(1.0, 2.0);
    const givenSize = Size(100.0, 200.0);

    test(
        'GIVEN key is not in map and has no offset and no size '
        'WHEN calling #getReorderableEntity '
        'THEN should return created ReorderableEntity', () {
      // given

      // when
      final actual = controller.getReorderableEntity(
        key: givenKey,
        index: givenIndex,
      );

      // then
      final expectedReorderableEntity = ReorderableEntity.create(
        key: givenKey,
        updatedOrderId: givenIndex,
        size: null,
        offset: null,
      );
      expect(actual, equals(expectedReorderableEntity));
    });

    test(
        'GIVEN key is not in map and has offset and size '
        'WHEN calling #getReorderableEntity '
        'THEN should return created ReorderableEntity', () {
      // given
      controller.offsetMap[givenIndex] = givenOffset;
      controller.childrenOrderMap[givenIndex] = ReorderableEntity.create(
        key: givenKey,
        updatedOrderId: givenIndex,
        size: givenSize,
      );

      // when
      final actual = controller.getReorderableEntity(
        key: givenKey,
        index: givenIndex,
      );

      // then
      final expectedReorderableEntity = ReorderableEntity.create(
        key: givenKey,
        updatedOrderId: givenIndex,
        size: givenSize,
        offset: givenOffset,
      );
      expect(actual, equals(expectedReorderableEntity));
    });

    test(
        'GIVEN key is in map and has offset and size '
        'WHEN calling #getReorderableEntity '
        'THEN should return updated ReorderableEntity', () {
      // given
      const givenReorderableEntity = ReorderableEntity(
        key: givenKey,
        updatedOrderId: -999,
        size: givenSize,
        hasSwappedOrder: false,
        isBuildingOffset: false,
        originalOffset: Offset.zero,
        originalOrderId: -999,
        updatedOffset: Offset(345.0, 678.0),
      );
      controller.childrenKeyMap[givenKey.value] = givenReorderableEntity;
      controller.offsetMap[givenIndex] = givenOffset;
      controller.childrenOrderMap[givenIndex] = givenReorderableEntity;

      // when
      final actual = controller.getReorderableEntity(
        key: givenKey,
        index: givenIndex,
      );

      // then
      final expectedReorderableEntity = givenReorderableEntity.updated(
        updatedOrderId: givenIndex,
        size: givenSize,
        updatedOffset: givenOffset,
      );
      expect(actual, equals(expectedReorderableEntity));
    });
  });

  group('#handleCreatedChild', () {
    const givenOffset = Offset(0.0, 1.0);
    const givenSize = Size(10.0, 20.3);
    const givenKey = ValueKey('child1');
    const givenUpdatedOrderId = 11;
    final givenReorderableEntity = ReorderableEntity.create(
      key: givenKey,
      updatedOrderId: givenUpdatedOrderId,
    );

    test(
        'GIVEN offset != null, size != null and reorderableEntity '
        'WHEN calling #handleCreatedChild '
        'THEN should update maps as expected', () {
      // given

      // when
      controller.handleCreatedChild(
        offset: givenOffset,
        size: givenSize,
        reorderableEntity: givenReorderableEntity,
      );

      // then
      final expectedUpdatedEntity = givenReorderableEntity.creationFinished(
        offset: givenOffset,
        size: givenSize,
      );
      expect(controller.offsetMap[givenUpdatedOrderId], equals(givenOffset));
      checkMaps(expectedReorderableEntity: expectedUpdatedEntity);
    });

    test(
        'GIVEN offset = null, size = null and reorderableEntity '
        'WHEN calling #handleCreatedChild '
        'THEN should update maps as expected', () {
      // given

      // when
      controller.handleCreatedChild(
        offset: null,
        size: null,
        reorderableEntity: givenReorderableEntity,
      );

      // then
      final expectedUpdatedEntity = givenReorderableEntity.creationFinished(
        offset: null,
        size: null,
      );
      expect(controller.offsetMap[givenUpdatedOrderId], isNull);
      checkMaps(expectedReorderableEntity: expectedUpdatedEntity);
    });
  });

  group('#handleOpacityFinished', () {
    final givenReorderableEntity = ReorderableEntity.create(
      key: const ValueKey('hello'),
      updatedOrderId: 12,
    );

    test(
        'GIVEN reorderableEntity '
        'WHEN calling #handleOpacityFinished '
        'THEN should update maps as expected', () {
      // given

      // when
      controller.handleOpacityFinished(
        reorderableEntity: givenReorderableEntity,
      );

      // then
      final expectedUpdatedEntity = givenReorderableEntity.fadedIn();
      checkMaps(expectedReorderableEntity: expectedUpdatedEntity);
    });
  });

  group('#handleMovingFinished', () {
    final givenReorderableEntity = ReorderableEntity.create(
      key: const ValueKey('hello'),
      updatedOrderId: 12,
    );

    test(
        'GIVEN reorderableEntity '
        'WHEN calling #handleMovingFinished '
        'THEN should update maps as expected', () {
      // given

      // when
      controller.handleMovingFinished(
        reorderableEntity: givenReorderableEntity,
      );

      // then
      final expectedUpdatedEntity = givenReorderableEntity.positionUpdated();
      checkMaps(expectedReorderableEntity: expectedUpdatedEntity);
    });
  });

  group('#handleDeviceOrientationChanged', () {
    final givenEntities = reorderableBuilder.getUniqueEntities(count: 5);

    test(
        'GIVEN reorderableEntity '
        'WHEN calling #handleMovingFinished '
        'THEN should update maps as expected', () {
      // given
      controller.offsetMap[0] = Offset.zero;
      controller.offsetMap[1] = Offset.zero;

      for (final entity in givenEntities) {
        controller.childrenKeyMap[entity.key.value] = entity;
        controller.childrenOrderMap[entity.updatedOrderId] = entity;
      }

      // when
      // controller.handleDeviceOrientationChanged();

      // then
    });
  });

  group('#updateToActualPositions', () {});

  group('#replaceMaps', () {});
}

class _TestReorderableController extends ReorderableController {}
