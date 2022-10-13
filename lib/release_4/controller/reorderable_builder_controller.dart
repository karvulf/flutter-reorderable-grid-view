import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/release_4/controller/reorderable_controller.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';

class ReorderableBuilderController extends ReorderableController {
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
    super.childrenOrderMap.clear();
    super.childrenOrderMap.addAll(updatedChildrenOrderMap);
    super.childrenKeyMap.clear();
    super.childrenKeyMap.addAll(updatedChildrenKeyMap);
  }
}