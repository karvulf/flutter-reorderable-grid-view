import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenKey = ValueKey('key');
  const givenOriginalOrderId = 0;
  const givenUpdatedOrderId = 1;
  const givenOriginalOffset = Offset(0.0, 1.0);
  const givenUpdatedOffset = Offset(2.0, 3.0);
  const givenSize = Size(10.0, 11.0);
  const givenIsBuildingOffset = true;
  const givenHasSwappedOrder = false;

  group('#create', () {
    test(
        'GIVEN required values '
        'WHEN calling create '
        'THEN should return expected ReorderableEntity', () {
      // given

      // when
      final actual = ReorderableEntity.create(
        key: givenKey,
        updatedOrderId: givenUpdatedOrderId,
      );

      // then
      const expectedReorderableEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: -1,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: Offset.zero,
        updatedOffset: Offset.zero,
        size: Size.zero,
        isBuildingOffset: true,
        hasSwappedOrder: false,
      );
      expect(actual, equals(expectedReorderableEntity));
    });

    test(
        'GIVEN required and optional values '
        'WHEN calling create '
        'THEN should return expected ReorderableEntity', () {
      // given

      // when
      final actual = ReorderableEntity.create(
        key: givenKey,
        updatedOrderId: givenUpdatedOrderId,
        offset: givenOriginalOffset,
        size: givenSize,
      );

      // then
      const expectedReorderableEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: -1,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenOriginalOffset,
        size: givenSize,
        isBuildingOffset: false,
        hasSwappedOrder: false,
      );
      expect(actual, equals(expectedReorderableEntity));
    });
  });

  group('#operator', () {
    test(
        'GIVEN two entities '
        'WHEN comparing them '
        'THEN should return true', () {
      // given
      const givenEntity1 = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: givenIsBuildingOffset,
        hasSwappedOrder: givenHasSwappedOrder,
      );
      const givenEntity2 = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: givenIsBuildingOffset,
        hasSwappedOrder: givenHasSwappedOrder,
      );

      // when
      final actual = givenEntity1 == givenEntity2;

      // then
      expect(actual, isTrue);
    });
  });

  group('#hashCode', () {
    test(
        'GIVEN entity '
        'WHEN calling hashCode '
        'THEN should return expected hashCode', () {
      // given
      const givenEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: givenIsBuildingOffset,
        hasSwappedOrder: givenHasSwappedOrder,
      );

      // when
      final actual = givenEntity.hashCode;

      // then
      expect(actual, equals(givenOriginalOrderId + givenUpdatedOrderId));
    });
  });

  group('#toString', () {
    test(
        'GIVEN entity '
        'WHEN calling toString '
        'THEN should return expected String', () {
      // given
      const givenEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: givenIsBuildingOffset,
        hasSwappedOrder: givenHasSwappedOrder,
      );

      // when
      final actual = givenEntity.toString();

      // then
      expect(
        actual,
        equals(
          '[$givenKey]: Original OrderId: $givenOriginalOrderId, Updated OrderId: $givenUpdatedOrderId, Original Offset: $givenOriginalOffset, Updated Offset: $givenUpdatedOffset',
        ),
      );
    });
  });

  group('#fadedIn', () {
    test(
        'GIVEN entity '
        'WHEN calling fadedIn '
        'THEN should return expected entity', () {
      // given
      const givenEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: true,
        hasSwappedOrder: true,
      );

      // when
      final actual = givenEntity.fadedIn();

      // then
      const expectedEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenUpdatedOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenUpdatedOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: false,
        hasSwappedOrder: false,
      );
      expect(actual, equals(expectedEntity));
    });
  });

  group('#creationFinished', () {
    const givenUpdatedSize = Size(12.3, 4.56);

    test(
        'GIVEN entity, size and offset = null '
        'WHEN calling creationFinished '
        'THEN should return expected entity', () {
      // given
      const givenEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: true,
        hasSwappedOrder: true,
      );

      // when
      final actual = givenEntity.creationFinished(
        offset: null,
        size: givenUpdatedSize,
      );

      // then
      const expectedEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenUpdatedSize,
        isBuildingOffset: false,
        hasSwappedOrder: false,
      );
      expect(actual, equals(expectedEntity));
    });

    test(
        'GIVEN entity, size and offset != null'
        'WHEN calling creationFinished '
        'THEN should return expected entity', () {
      // given
      const givenNewOffset = Offset(123.1, 234.5);
      const givenEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: true,
        hasSwappedOrder: true,
      );

      // when
      final actual = givenEntity.creationFinished(
        offset: givenNewOffset,
        size: givenUpdatedSize,
      );

      // then
      const expectedEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenNewOffset,
        size: givenUpdatedSize,
        isBuildingOffset: false,
        hasSwappedOrder: false,
      );
      expect(actual, equals(expectedEntity));
    });
  });

  group('#updated', () {
    test(
        'GIVEN entity and updatedOrderId is different to old one '
        'WHEN calling updated '
        'THEN should return expected entity', () {
      // given
      const givenNewUpdatedOrderId = 999;
      const givenEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: true,
        hasSwappedOrder: true,
      );

      // when
      final actual = givenEntity.updated(
        size: null,
        updatedOrderId: givenNewUpdatedOrderId,
        updatedOffset: null,
      );

      // then
      const expectedEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenUpdatedOrderId,
        updatedOrderId: givenNewUpdatedOrderId,
        originalOffset: givenUpdatedOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: true,
        hasSwappedOrder: false,
      );
      expect(actual, equals(expectedEntity));
    });

    test(
        'GIVEN entity, size and updatedOffset '
        'WHEN calling updated '
        'THEN should return expected entity', () {
      // given
      const givenNewSize = Size(321.0, 123.0);
      const givenNewUpdatedOffset = Offset(234.0, 432.0);
      const givenEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenUpdatedOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: true,
        hasSwappedOrder: true,
      );

      // when
      final actual = givenEntity.updated(
        size: givenNewSize,
        updatedOrderId: givenUpdatedOrderId,
        updatedOffset: givenNewUpdatedOffset,
      );

      // then
      const expectedEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenUpdatedOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenNewUpdatedOffset,
        size: givenNewSize,
        isBuildingOffset: false,
        hasSwappedOrder: false,
      );
      expect(actual, equals(expectedEntity));
    });

    test(
        'GIVEN entity, size and updatedOffset '
        'WHEN calling updated '
        'THEN should return expected entity', () {
      // given
      const givenNewSize = Size(321.0, 123.0);
      const givenNewUpdatedOffset = Offset(234.0, 432.0);
      const givenEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: true,
        hasSwappedOrder: true,
      );

      // when
      final actual = givenEntity.updated(
        size: givenNewSize,
        updatedOrderId: givenUpdatedOrderId,
        updatedOffset: givenNewUpdatedOffset,
      );

      // then
      const expectedEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenNewUpdatedOffset,
        size: givenNewSize,
        isBuildingOffset: false,
        hasSwappedOrder: true,
      );
      expect(actual, equals(expectedEntity));
    });
  });

  group('#positionUpdated', () {
    test(
        'GIVEN entity '
        'WHEN calling positionUpdated '
        'THEN should return expected entity', () {
      // given
      const givenEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: true,
        hasSwappedOrder: true,
      );

      // when
      final actual = givenEntity.positionUpdated();

      // then
      const expectedEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenUpdatedOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenUpdatedOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: false,
        hasSwappedOrder: false,
      );
      expect(actual, equals(expectedEntity));
    });
  });

  group('#dragUpdated', () {
    test(
        'GIVEN entity, updatedOffset and updatedOrderId '
        'WHEN calling dragUpdated '
        'THEN should return expected entity', () {
      // given
      const givenNewUpdatedOffset = Offset(21.0, 32.2);
      const givenNewUpdatedOrderId = 2;
      const givenEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: true,
        hasSwappedOrder: false,
      );

      // when
      final actual = givenEntity.dragUpdated(
        updatedOffset: givenNewUpdatedOffset,
        updatedOrderId: givenNewUpdatedOrderId,
      );

      // then
      const expectedEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenNewUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenNewUpdatedOffset,
        size: givenSize,
        isBuildingOffset: true,
        hasSwappedOrder: true,
      );
      expect(actual, equals(expectedEntity));
    });
  });

  group('#copyWith', () {
    test(
        'GIVEN entity and size '
        'WHEN calling copyWith '
        'THEN should return expected entity', () {
      // given
      const givenNewSize = Size(123.2, 452.3);
      const givenEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: true,
        hasSwappedOrder: true,
      );

      // when
      final actual = givenEntity.copyWith(size: givenNewSize);

      // then
      const expectedEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: givenOriginalOrderId,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenNewSize,
        isBuildingOffset: true,
        hasSwappedOrder: true,
      );
      expect(actual, equals(expectedEntity));
    });
  });

  group('#isNew', () {
    test(
        'GIVEN entity where originalOrderId = -1 '
        'WHEN calling isNew '
        'THEN should return true', () {
      // given
      const givenEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: -1,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: true,
        hasSwappedOrder: true,
      );

      // when
      final actual = givenEntity.isNew;

      // then
      expect(actual, isTrue);
    });

    test(
        'GIVEN entity where originalOrderId = 0 '
        'WHEN calling isNew '
        'THEN should return false', () {
      // given
      const givenEntity = ReorderableEntity(
        key: givenKey,
        originalOrderId: 0,
        updatedOrderId: givenUpdatedOrderId,
        originalOffset: givenOriginalOffset,
        updatedOffset: givenUpdatedOffset,
        size: givenSize,
        isBuildingOffset: true,
        hasSwappedOrder: true,
      );

      // when
      final actual = givenEntity.isNew;

      // then
      expect(actual, isFalse);
    });
  });
}
