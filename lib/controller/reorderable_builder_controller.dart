import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_drag_and_drop_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

class ReorderableBuilderController extends ReorderableDragAndDropController {
  void initChildren({required List<Widget> children}) {
    var index = 0;

    for (final child in children) {
      assert(!childrenKeyMap.containsKey(child.key), "Key is duplicated!");
      final key = child.key! as ValueKey;
      final reorderableEntity = ReorderableEntity.create(
        key: key,
        updatedOrderId: index,
      );
      super.childrenOrderMap[reorderableEntity.originalOrderId] =
          reorderableEntity;
      super.childrenKeyMap[reorderableEntity.key.value] = reorderableEntity;
      index++;
    }
  }

  void updateChildren({required List<Widget> children}) {
    var updatedChildrenKeyMap = <dynamic, ReorderableEntity>{};
    var updatedChildrenOrderMap = <int, ReorderableEntity>{};

    var index = 0;
    for (final child in children) {
      final reorderableEntity = getReorderableEntity(
        key: child.key as ValueKey,
        index: index++,
      );
      final originalOrderId = reorderableEntity.originalOrderId;
      updatedChildrenOrderMap[originalOrderId] = reorderableEntity;
      updatedChildrenKeyMap[reorderableEntity.key.value] = reorderableEntity;
    }
    replaceMaps(
      updatedChildrenKeyMap: updatedChildrenKeyMap,
      updatedChildrenOrderMap: updatedChildrenOrderMap,
    );
  }
}
