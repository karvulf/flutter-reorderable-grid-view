import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';

abstract class ReorderableController {
  final childrenOrderMap = <int, ReorderableEntity>{};
  final childrenKeyMap = <dynamic, ReorderableEntity>{};
  final offsetMap = <int, Offset>{};

  ReorderableEntity getReorderableEntity({
    required ValueKey key,
    required int index,
  }) {
    final childInKeyMap = childrenKeyMap[key.value];
    final offset = offsetMap[index];
    late final ReorderableEntity reorderableEntity;

    if (childInKeyMap == null) {
      reorderableEntity = ReorderableEntity.create(
        key: key,
        updatedOrderId: index,
        offset: offset,
      );
    } else {
      reorderableEntity = childInKeyMap.updated(
        updatedOrderId: index,
        updatedOffset: offset,
      );
    }
    return reorderableEntity;
  }

  void handleCreatedChild({
    required Offset? offset,
    required ReorderableEntity reorderableEntity,
  }) {
    if (offset != null) {
      offsetMap[reorderableEntity.updatedOrderId] = offset;
    }
    final updatedEntity = reorderableEntity.creationFinished(offset: offset);
    _updateMaps(reorderableEntity: updatedEntity);
  }

  void handleOpacityFinished({required ReorderableEntity reorderableEntity}) {
    final updatedEntity = reorderableEntity.fadedIn();
    _updateMaps(reorderableEntity: updatedEntity);
  }

  void handleMovingFinished({required ReorderableEntity reorderableEntity}) {
    final updatedEntity = reorderableEntity.positionUpdated();
    _updateMaps(reorderableEntity: updatedEntity);
  }

  void _updateMaps({required ReorderableEntity reorderableEntity}) {
    childrenOrderMap[reorderableEntity.originalOrderId] = reorderableEntity;
    childrenKeyMap[reorderableEntity.key.value] = reorderableEntity;
  }
}
