import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/reorderable_grid_view_builder.dart';

void main() {
  final builder = ReorderableGridViewBuilder();

  test(
      'GIVEN '
      'WHEN calling [ReorderableEntity.oncreate] '
      'THEN should instantiate entity with expected values', () {
    // given

    // when
    final actual = ReorderableEntity.create();

    // then
    expect(actual.idMap, isEmpty);
    expect(actual.children, isEmpty);
  });

  test(
      'GIVEN [ReorderableEntity] '
      'WHEN calling #copyWith '
      'THEN should return expected [ReorderableEntity]', () {
    // given
    final givenReorderableEntity = ReorderableEntity.create();
    final givenIdMap = {
      0: builder.getGridItemEntity(),
    };
    final givenChildren = [Container()];

    // when
    final actual = givenReorderableEntity.copyWith(
      children: givenChildren,
      idMap: givenIdMap,
    );

    // then
    expect(actual.idMap, equals(givenIdMap));
    expect(actual.children, equals(givenChildren));
  });

  test(
      'GIVEN [ReorderableEntity] '
      'WHEN calling #clear '
      'THEN should have cleared values', () {
    // given
    final givenIdMap = {
      0: builder.getGridItemEntity(),
    };
    final givenChildren = [Container()];
    final givenReorderableEntity = ReorderableEntity(
      children: givenChildren,
      idMap: givenIdMap,
    );

    // when
    givenReorderableEntity.clear();

    // then
    expect(givenReorderableEntity.idMap, isEmpty);
    expect(givenReorderableEntity.children, isEmpty);
  });

  test(
      'GIVEN [ReorderableEntity] '
      'WHEN calling #addEntry '
      'THEN should add entry to [ReorderableEntity]', () {
    // given
    final givenEntry = MapEntry(0, builder.getGridItemEntity());
    final givenReorderableEntity = ReorderableEntity.create();

    // when
    givenReorderableEntity.addEntry(givenEntry);

    // then
    final expectedIdMap = {givenEntry.key: givenEntry.value};
    expect(givenReorderableEntity.idMap, equals(expectedIdMap));
    expect(givenReorderableEntity.children, isEmpty);
  });
}
