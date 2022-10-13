import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/release_4/controller/reorderable_controller.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';

class ReorderableItemBuilderController extends ReorderableController {
  ReorderableEntity buildItem({
    required ValueKey key,
    required int index,
  }) {
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
