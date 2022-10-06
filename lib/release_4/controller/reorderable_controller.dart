import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';

abstract class ReorderableController {
  final childrenOrderMap = <int, ReorderableEntity>{};
  final childrenKeyMap = <dynamic, ReorderableEntity>{};
  final offsetMap = <int, Offset>{};

  void handleCreatedChild({
    required Offset? offset,
    required ReorderableEntity reorderableEntity,
  }) {
    if (offset != null) {
      offsetMap[reorderableEntity.updatedOrderId] = offset;
    }
    _updateMaps(
      reorderableEntity: reorderableEntity.creationFinished(
        offset: offset,
      ),
    );
  }

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

  void handleMovingFinished(ReorderableEntity reorderableEntity) {
    _updateMaps(
      reorderableEntity: reorderableEntity.positionUpdated(),
    );
  }

  void handleOpacityFinished(ReorderableEntity reorderableEntity) {
    _updateMaps(
      reorderableEntity: reorderableEntity.fadedIn(),
    );
  }

  void _updateMaps({required ReorderableEntity reorderableEntity}) {
    childrenOrderMap[reorderableEntity.originalOrderId] = reorderableEntity;
    childrenKeyMap[reorderableEntity.key.value] = reorderableEntity;
  }
}
