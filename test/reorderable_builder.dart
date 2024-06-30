import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

class ReorderableBuilder {
  List<ReorderableEntity> getUniqueEntities({int count = 0}) {
    return List.generate(
      count,
      (index) => getEntity(key: 'key_$index'),
    ).toList();
  }

  ReorderableEntity getEntity({
    String key = 'key',
    int originalOrderId = 0,
    int updatedOrderId = 1,
    Offset originalOffset = const Offset(20.0, 21.0),
    Offset updatedOffset = const Offset(30.0, 31.0),
    bool isBuildingOffset = true,
    bool hasSwappedOrder = true,
  }) {
    return ReorderableEntity(
      key: ValueKey(key),
      originalOrderId: originalOrderId,
      updatedOrderId: updatedOrderId,
      originalOffset: originalOffset,
      updatedOffset: updatedOffset,
      size: const Size(10.0, 11.0),
      isBuildingOffset: isBuildingOffset,
      hasSwappedOrder: hasSwappedOrder,
    );
  }

  ReleasedReorderableEntity getReleasedEntity({
    Offset dropOffset = Offset.zero,
    ReorderableEntity? reorderableEntity,
  }) {
    return ReleasedReorderableEntity(
      reorderableEntity: reorderableEntity ?? getEntity(),
      dropOffset: dropOffset,
    );
  }
}
