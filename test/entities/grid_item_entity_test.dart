import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'GIVEN values '
      'WHEN instantiating [GridItemEntity] '
      'THEN should have given values', () {
    // given
    const givenLocalPosition = Offset(0, 0);
    const givenGlobalPosition = Offset(1, 1);
    const givenSize = Size(100, 100);
    final givenItem = Container();
    const givenOrderId = 0;

    // when
    final actual = GridItemEntity(
      localPosition: givenLocalPosition,
      globalPosition: givenGlobalPosition,
      size: givenSize,
      item: givenItem,
      orderId: givenOrderId,
    );

    // then
    expect(actual.localPosition, equals(givenLocalPosition));
    expect(actual.globalPosition, equals(givenGlobalPosition));
    expect(actual.size, equals(givenSize));
    expect(actual.item, equals(givenItem));
    expect(actual.orderId, equals(givenOrderId));
  });

  test(
      'GIVEN [GridItemEntity] '
      'WHEN calling #copyWith '
      'THEN should have updated values', () {
    // given
    const givenSize = Size(100, 100);
    final givenItem = Container();

    final givenGridItemEntity = GridItemEntity(
      localPosition: const Offset(0, 0),
      globalPosition: const Offset(1, 1),
      size: givenSize,
      item: givenItem,
      orderId: 0,
    );

    const givenUpdatedGlobalPosition = Offset(2, 2);
    const givenUpdatedLocalPosition = Offset(3, 3);
    const givenUpdatedOrderId = 1;

    // when
    final actual = givenGridItemEntity.copyWith(
      localPosition: givenUpdatedLocalPosition,
      globalPosition: givenUpdatedGlobalPosition,
      orderId: givenUpdatedOrderId,
    );

    // then
    expect(actual.localPosition, equals(givenUpdatedLocalPosition));
    expect(actual.globalPosition, equals(givenUpdatedGlobalPosition));
    expect(actual.size, equals(givenSize));
    expect(actual.item, equals(givenItem));
    expect(actual.orderId, equals(givenUpdatedOrderId));
  });
}
