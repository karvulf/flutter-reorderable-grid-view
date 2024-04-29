import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_drag_and_drop_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

class ReorderableItemBuilderController
    extends ReorderableDragAndDropController {
  /// Returns [ReorderableEntity] that is related to [key] and [index].
  ReorderableEntity buildItem({
    required ValueKey key,
    required int index,
  }) {
    if (draggedEntity != null) {
      final reorderableEntity = super.childrenKeyMap[key.value];
      if (reorderableEntity != null) {
        return reorderableEntity;
      }
    }
    final reorderableEntity = super.getReorderableEntity(
      key: key,
      index: index,
    );
    final originalOrderId = reorderableEntity.originalOrderId;
    super.childrenOrderMap[originalOrderId] = reorderableEntity;
    super.childrenKeyMap[reorderableEntity.key.value] = reorderableEntity;

    return reorderableEntity;
  }
}
