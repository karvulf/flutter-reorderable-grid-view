import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_drag_and_drop_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

/// Handles logic to set all [ReorderableEntity] that are related to the children.
///
/// Every child gets a [ReorderableEntity] that contains information about
/// the position, the size and so on. This is need for calculations later when
/// the children are moving or changing their position.
class ReorderableBuilderController extends ReorderableDragAndDropController {
  /// Adds [ReorderableEntity] for all [children] to two maps.
  ///
  /// This is called when the [children] are created for the first time.
  void initChildren({required List<Widget> children}) {
    var index = 0;

    for (final child in children) {
      final key = child.key! as ValueKey;
      assert(!childrenKeyMap.containsKey(key.value), "Key is duplicated!");
      final reorderableEntity = ReorderableEntity.create(
        key: key,
        updatedOrderId: index,
      );
      // todo: macht iwie keinen sinn, weil beim ersten erstellen alle die originalOrderId von -1 haben
      super.childrenOrderMap[reorderableEntity.originalOrderId] =
          reorderableEntity;
      super.childrenKeyMap[reorderableEntity.key.value] = reorderableEntity;
      index++;
    }
  }

  /// Iterates through [children] and updates [childrenKeyMap] and [childrenOrderMap].
  ///
  /// The update should always be called when the children are changing.
  /// With this update, it is possible to have correct animations later to move
  /// the [children] visually.
  void updateChildren({required List<Widget> children}) {
    var updatedChildrenKeyMap = <String, ReorderableEntity>{};
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
