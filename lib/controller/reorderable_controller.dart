import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

/// TODO: add comment
abstract class ReorderableController {
// todo nochmal prüfen, ob die orderId hier immer über die updated oder originalOrderId gesetzt wird, falls nicht riecht das nach fehleranfälligkeit
  final childrenOrderMap = <int, ReorderableEntity>{};

  final childrenKeyMap = <String, ReorderableEntity>{};

  final offsetMap = <int, Offset>{};

  /// Creates or updates [ReorderableEntity] related to [key] and returns it.
  ///
  /// Looks for [ReorderableEntity] in [childrenKeyMap] and updates it if found.
  /// Otherwise it will be created with offset and size.
  ReorderableEntity getReorderableEntity({
    required ValueKey key,
    required int index,
  }) {
    final childInKeyMap = childrenKeyMap[key.value];
    final offset = offsetMap[index];
    // todo warum child aus der anderen map genommen?
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

  /// Updates specific values of [reorderableEntity] and update maps.
  ///
  /// When the child was created, [offset] will be added to [offsetMap]
  /// to simplify the access to the offset of the order id of [reorderableEntity].
  ///
  /// Then #creationFinished is called that updates some important values.
  ///
  /// In the end, the [childrenOrderMap] and [childrenKeyMap] are updated.
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

  /// Updates offset and order id of [reorderableEntity] faded in.
  ///
  /// Should be called when the fade in was finished. Then the original
  /// offset and orderId are overwritten with the updated values of the entity.
  ReorderableEntity handleOpacityFinished(
      {required ReorderableEntity reorderableEntity}) {
    final updatedEntity = reorderableEntity.fadedIn();
    _updateMaps(reorderableEntity: updatedEntity);
    return updatedEntity;
  }

  /// TODO das fadedIn und positionUpdated scheint identisch zu sein, ergo ist diese methode mit der obigen gleich und kann vielleicht zusammengeführt werden
  /// Updates offset and order id of [reorderableEntity] faded in.
  ///
  /// Should be called when the fade in was finished. Then the original
  /// offset and orderId are overwritten with the updated values of the entity.
  ReorderableEntity handleMovingFinished({required ReorderableEntity reorderableEntity}) {
    final updatedEntity = reorderableEntity.positionUpdated();
    _updateMaps(reorderableEntity: updatedEntity);

    return updatedEntity;
  }

  /// Resets all entities in [childrenOrderMap] and [childrenKeyMap].
  ///
  /// Clears [offsetMap] and rebuilds all entities in [childrenOrderMap] and
  /// [childrenKeyMap] because after the orientation change, the children
  /// will have new offsets that has to be recalculated.
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

  /// Iterates through [childrenKeyMap] and updates [ReorderableEntity].
  ///
  /// The original offset and orderId of [ReorderableEntity] will be set
  /// to the updated offset and orderId.
  ///
  /// At the end [childrenKeyMap] and [childrenOrderMap] are replaced with the
  /// updated maps.
  void updateToActualPositions() {
    var updatedChildrenKeyMap = <String, ReorderableEntity>{};
    var updatedChildrenOrderMap = <int, ReorderableEntity>{};

    for (final entry in childrenKeyMap.entries) {
      final updatedReorderableEntity = entry.value.positionUpdated();
      final originalOrderId = updatedReorderableEntity.originalOrderId;
      updatedChildrenOrderMap[originalOrderId] = updatedReorderableEntity;
      updatedChildrenKeyMap[entry.key] = updatedReorderableEntity;
    }

    replaceMaps(
      updatedChildrenKeyMap: updatedChildrenKeyMap,
      updatedChildrenOrderMap: updatedChildrenOrderMap,
    );
  }

  void replaceMaps({
    required Map<String, ReorderableEntity> updatedChildrenKeyMap,
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
