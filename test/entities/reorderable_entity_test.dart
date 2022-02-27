import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'GIVEN only default values'
      'WHEN instantiating [ReorderableEntity] '
      'THEN should have expected values', () {
    // given
    const givenChild = Text('hallo');

    // when
    const actual = ReorderableEntity(
      child: givenChild,
      originalOrderId: 0,
      updatedOrderId: 1,
      isBuilding: false,
    );

    // then
    expect(actual.child, equals(givenChild));
    expect(actual.originalOrderId, equals(0));
    expect(actual.updatedOrderId, equals(1));
    expect(actual.isBuilding, isFalse);
    expect(actual.originalOffset, equals(Offset.zero));
    expect(actual.updatedOffset, equals(Offset.zero));
    expect(actual.size, equals(Size.zero));
    expect(actual.isNew, isFalse);
    expect(actual.hasSwappedOrder, isFalse);
  });

  group('#copyWith', () {
    test(
        'GIVEN reorderableEntity '
        'WHEN calling #copyWith '
        'THEN should add new values', () {
      // given
      const givenReorderableEntity = ReorderableEntity(
        child: Text('hallo'),
        originalOrderId: 0,
        updatedOrderId: 0,
        isBuilding: false,
        hasSwappedOrder: false,
        updatedOffset: Offset.zero,
        originalOffset: Offset.zero,
        isNew: false,
        size: Size.zero,
      );
      const givenUpdatedHasSwappedOrder = true;
      const givenUpdatedSize = Size(50, 50);
      const givenUpdatedIsNew = true;
      const givenUpdatedOriginalOffset = Offset(100, 100);
      const givenUpdatedUpdatedOffset = Offset(20, 23);
      const givenUpdatedChild = Text('copyWith');
      const givenUpdatedIsBuilding = true;
      const givenUpdatedUpdatedOrderId = 99;
      const givenUpdatedOriginalOrderId = 98;

      // when
      final actual = givenReorderableEntity.copyWith(
        hasSwappedOrder: givenUpdatedHasSwappedOrder,
        size: givenUpdatedSize,
        isNew: givenUpdatedIsNew,
        originalOffset: givenUpdatedOriginalOffset,
        updatedOffset: givenUpdatedUpdatedOffset,
        child: givenUpdatedChild,
        isBuilding: givenUpdatedIsBuilding,
        updatedOrderId: givenUpdatedUpdatedOrderId,
        originalOrderId: givenUpdatedOriginalOrderId,
      );

      // then
      expect(actual.child, equals(givenUpdatedChild));
      expect(actual.originalOrderId, equals(givenUpdatedOriginalOrderId));
      expect(actual.updatedOrderId, equals(givenUpdatedUpdatedOrderId));
      expect(actual.isBuilding, equals(givenUpdatedIsBuilding));
      expect(actual.originalOffset, equals(givenUpdatedOriginalOffset));
      expect(actual.updatedOffset, equals(givenUpdatedUpdatedOffset));
      expect(actual.size, equals(givenUpdatedSize));
      expect(actual.isNew, equals(givenUpdatedIsNew));
      expect(actual.hasSwappedOrder, equals(givenUpdatedHasSwappedOrder));
    });
  });
}
