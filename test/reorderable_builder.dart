import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

class ReorderableBuilder {
  List<ReorderableEntity> getUniqueEntities({int count = 0}) {
    return List.generate(
      count,
      (index) => getEntity(key: 'key_$index'),
    ).toList();
  }

  ReorderableEntity getEntity({String key = 'key'}) {
    return ReorderableEntity(
      key: ValueKey(key),
      originalOrderId: 0,
      updatedOrderId: 1,
      originalOffset: const Offset(20.0, 21.0),
      updatedOffset: const Offset(30.0, 31.0),
      size: const Size(10.0, 11.0),
      isBuildingOffset: true,
      hasSwappedOrder: true,
    );
  }
}
