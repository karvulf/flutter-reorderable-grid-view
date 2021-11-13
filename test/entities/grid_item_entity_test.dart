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
    const givenSize = Size(100, 100);
    const givenOrderId = 0;

    // when
    const actual = GridItemEntity(
      localPosition: givenLocalPosition,
      size: givenSize,
      orderId: givenOrderId,
    );

    // then
    expect(actual.localPosition, equals(givenLocalPosition));
    expect(actual.size, equals(givenSize));
    expect(actual.orderId, equals(givenOrderId));
  });

  test(
      'GIVEN [GridItemEntity] '
      'WHEN calling #copyWith without values '
      'THEN should have copy entity with same values', () {
    // given
    const givenSize = Size(100, 100);
    const givenLocalPosition = Offset(0, 0);
    const givenOrderId = 0;

    const givenGridItemEntity = GridItemEntity(
      localPosition: givenLocalPosition,
      size: givenSize,
      orderId: givenOrderId,
    );

    // when
    final actual = givenGridItemEntity.copyWith();

    // then
    expect(actual.localPosition, equals(givenLocalPosition));
    expect(actual.size, equals(givenSize));
    expect(actual.orderId, equals(givenOrderId));
  });

  test(
      'GIVEN [GridItemEntity] '
      'WHEN calling #copyWith with all values '
      'THEN should have updated values', () {
    // given
    const givenGridItemEntity = GridItemEntity(
      localPosition: Offset(0, 0),
      size: Size(100, 100),
      orderId: 0,
    );

    const givenUpdatedLocalPosition = Offset(3, 3);
    const givenUpdatedOrderId = 1;
    const givenUpdatedSize = Size(400, 400);

    // when
    final actual = givenGridItemEntity.copyWith(
      localPosition: givenUpdatedLocalPosition,
      orderId: givenUpdatedOrderId,
      size: givenUpdatedSize,
    );

    // then
    expect(actual.localPosition, equals(givenUpdatedLocalPosition));
    expect(actual.orderId, equals(givenUpdatedOrderId));
    expect(actual.size, equals(givenUpdatedSize));
  });
}
