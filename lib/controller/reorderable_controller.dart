import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

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
    // todo: only working for gridviews because every child has the same size
    final size = childrenOrderMap[index]?.size;
    late final ReorderableEntity reorderableEntity;

    if (childInKeyMap == null) {
      reorderableEntity = ReorderableEntity.create(
        key: key,
        updatedOrderId: index,
        offset: offset,
        size: size,
      );
    } else {
      reorderableEntity = childInKeyMap.updated(
        updatedOrderId: index,
        updatedOffset: offset,
        size: size,
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
    final updatedEntity = reorderableEntity.creationFinished(
      offset: offset,
    );
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

  void handleDeviceOrientationChanged() {
    offsetMap.clear();

    for (final entry in childrenOrderMap.entries) {
      final value = entry.value;
      childrenOrderMap[entry.key] = ReorderableEntity.create(
        key: value.key,
        updatedOrderId: value.updatedOrderId,
      );
    }

    for (final entry in childrenKeyMap.entries) {
      final value = entry.value;
      childrenKeyMap[entry.key] = ReorderableEntity.create(
        key: value.key,
        updatedOrderId: value.updatedOrderId,
      );
    }
  }

  void updateToActualPositions() {
    var updatedChildrenKeyMap = <dynamic, ReorderableEntity>{};
    var updatedChildrenOrderMap = <int, ReorderableEntity>{};

    for (final entry in childrenKeyMap.entries) {
      final key = entry.key;
      final updatedReorderableEntity = entry.value.positionUpdated();
      final originalOrderId = updatedReorderableEntity.originalOrderId;
      updatedChildrenOrderMap[originalOrderId] = updatedReorderableEntity;
      updatedChildrenKeyMap[key] = updatedReorderableEntity;
    }
    replaceMaps(
      updatedChildrenKeyMap: updatedChildrenKeyMap,
      updatedChildrenOrderMap: updatedChildrenOrderMap,
    );
  }

  void replaceMaps({
    required Map<dynamic, ReorderableEntity> updatedChildrenKeyMap,
    required Map<int, ReorderableEntity> updatedChildrenOrderMap,
  }) {
    childrenOrderMap.clear();
    childrenOrderMap.addAll(updatedChildrenOrderMap);
    childrenKeyMap.clear();
    childrenKeyMap.addAll(updatedChildrenKeyMap);
  }

  void _updateMaps({required ReorderableEntity reorderableEntity}) {
    // removes deprecated values in maps
    childrenKeyMap.removeWhere(
      (key, value) => value.updatedOrderId == reorderableEntity.updatedOrderId,
    );
    childrenOrderMap.removeWhere(
      (key, value) => value.updatedOrderId == reorderableEntity.updatedOrderId,
    );
    childrenOrderMap[reorderableEntity.originalOrderId] = reorderableEntity;
    childrenKeyMap[reorderableEntity.key.value] = reorderableEntity;
  }
}
