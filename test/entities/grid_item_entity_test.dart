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
    final givenChild = Container();

    // when
    final actual = GridItemEntity(
      localPosition: givenLocalPosition,
      size: givenSize,
      orderId: givenOrderId,
      child: givenChild,
    );

    // then
    expect(actual.localPosition, equals(givenLocalPosition));
    expect(actual.size, equals(givenSize));
    expect(actual.orderId, equals(givenOrderId));
    expect(actual.child, equals(givenChild));
  });

  test(
      'GIVEN [GridItemEntity] '
      'WHEN calling #copyWith without values '
      'THEN should have copy entity with same values', () {
    // given
    const givenSize = Size(100, 100);
    const givenLocalPosition = Offset(0, 0);
    const givenOrderId = 0;
    final givenChild = Container();

    final givenGridItemEntity = GridItemEntity(
      localPosition: givenLocalPosition,
      size: givenSize,
      orderId: givenOrderId,
      child: givenChild,
    );

    // when
    final actual = givenGridItemEntity.copyWith();

    // then
    expect(actual.localPosition, equals(givenLocalPosition));
    expect(actual.size, equals(givenSize));
    expect(actual.orderId, equals(givenOrderId));
    expect(actual.child, equals(givenChild));
  });

  test(
      'GIVEN [GridItemEntity] '
      'WHEN calling #copyWith with all values '
      'THEN should have updated values', () {
    // given
    final givenGridItemEntity = GridItemEntity(
      localPosition: const Offset(0, 0),
      size: const Size(100, 100),
      orderId: 0,
      child: Container(),
    );

    const givenUpdatedLocalPosition = Offset(3, 3);
    const givenUpdatedOrderId = 1;
    const givenUpdatedChild = Text('text');
    const givenUpdatedSize = Size(400, 400);

    // when
    final actual = givenGridItemEntity.copyWith(
      localPosition: givenUpdatedLocalPosition,
      orderId: givenUpdatedOrderId,
      child: givenUpdatedChild,
      size: givenUpdatedSize,
    );

    // then
    expect(actual.localPosition, equals(givenUpdatedLocalPosition));
    expect(actual.orderId, equals(givenUpdatedOrderId));
    expect(actual.size, equals(givenUpdatedSize));
    expect(actual.child, equals(givenUpdatedChild));
  });
}
