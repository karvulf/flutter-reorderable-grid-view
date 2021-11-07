import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';

/// Checks collision of item with given [id] with another one in [childrenIdMap].
///
/// Expects that the [id] is existing in [childrenIdMap] and is not locked
/// inside of [lockedChildren].
///
/// Depending of the current position of the item, it's possible that
/// there is a collision with another one in [childrenIdMap].
/// That happens if the dragged item lays above another one.
/// It's also possible that the item has a collision with itself. In that case
/// you should check if the returned id is equal to the given [id] because most
/// of the cases you don't want to update sth if nothing changes.
///
/// If there was no collision or the collision item is found in
/// [lockedChildren], then null will be returned.
/// Otherwise the id of the collision item in [childrenIdMap].
int? getItemsCollision({
  required int orderId,
  required Offset position,
  required Size size,
  required Map<int, GridItemEntity> childrenIdMap,
  required List<int> lockedChildren,
}) {
  int? collisionOrderId;

  // child does not exist or is locked
  if (lockedChildren.contains(orderId)) {
    return null;
  }

  final currentDx = position.dx + size.width / 2;
  final currentDy = position.dy + size.height / 2;

  for (final entry in childrenIdMap.entries) {
    final item = entry.value;
    final itemDx = item.localPosition.dx;
    final itemDy = item.localPosition.dy;
    final itemWidth = item.size.width;
    final itemHeight = item.size.height;

    // checking collision with full item size and local position
    if (currentDx >= itemDx &&
        currentDy >= itemDy &&
        currentDx <= itemDx + itemWidth &&
        currentDy <= itemDy + itemHeight) {
      collisionOrderId = entry.value.orderId;
      break;
    }
  }

  if (lockedChildren.contains(collisionOrderId)) {
    return null;
  }

  return collisionOrderId;
}

/// Swapping positions and orderId of items with [dragOrderId] and [collisionOrderId].
///
/// Usually this is called after a collision happens between two items while
/// dragging it.
/// The [dragOrderId] and [collisionOrderId] should be different and the [collisionOrderId]
/// should not be in [lockedChildren].
/// If that is not the case, then the following values are swapped between
/// the two items with [dragOrderId] and [collisionOrderId]
/// -> localPosition, globalPosition and orderId.
///
/// Also [childrenOrderIdMap] gets an update by swapping the values of the
/// dragged and collision item.
///
/// It's important that the id does not change because this value is needed to
/// animate the new position of the given [childrenIdMap].
///
/// There is no return value because [childrenIdMap] and [childrenOrderIdMap]
/// gets immediately updated.
void handleOneCollision({
  required int dragOrderId,
  required int collisionOrderId,
  required Map<int, GridItemEntity> childrenIdMap,
  required List<int> lockedChildren,
  required ReorderCallback onReorder,
}) {
  assert(dragOrderId != collisionOrderId);

  if (lockedChildren.contains(collisionOrderId)) {
    return;
  }

  final entryA = childrenIdMap.entries.firstWhere(
    (entry) => entry.value.orderId == dragOrderId,
  );
  final entryB = childrenIdMap.entries.firstWhere(
    (entry) => entry.value.orderId == collisionOrderId,
  );

  final updatedEntryValueA = entryA.value.copyWith(
    localPosition: entryB.value.localPosition,
    orderId: entryB.value.orderId,
  );
  final updatedEntryValueB = entryB.value.copyWith(
    localPosition: entryA.value.localPosition,
    orderId: entryA.value.orderId,
  );

  childrenIdMap[entryA.key] = updatedEntryValueA;
  childrenIdMap[entryB.key] = updatedEntryValueB;

  onReorder(entryA.value.orderId, entryB.value.orderId);
}

/// Called when the item changes his position between more than one item.
///
/// After the user drags the item with the given [dragOrderId] to another
/// position above the current item and there would be more than one update of
/// the positions, then this method should be called.
///
/// It loops over all items that are between [dragOrderId] and
/// [collisionOrderId] and handles every collision of them.
///
/// The Map [childrenOrderIdMap] is important to improve the performance for
/// searching children with a specific orderId.
///
/// There is no return value because [childrenIdMap] and [childrenOrderIdMap]
/// gets immediately updated.
void handleMultipleCollisionsBackward({
  required int dragOrderId,
  required int collisionOrderId,
  required Map<int, GridItemEntity> childrenIdMap,
  required List<int> lockedChildren,
  required ReorderCallback onReorder,
}) {
  for (int i = dragOrderId; i > collisionOrderId; i--) {
    int currentDragOrderId = i;
    int foundCollisionOrderId = i - 1;

    if (lockedChildren.contains(foundCollisionOrderId)) {
      while (i - 2 >= collisionOrderId &&
          lockedChildren.contains(foundCollisionOrderId)) {
        foundCollisionOrderId = i - 2;
        i--;
      }
    }

    if (foundCollisionOrderId >= collisionOrderId) {
      handleOneCollision(
        dragOrderId: currentDragOrderId,
        collisionOrderId: foundCollisionOrderId,
        childrenIdMap: childrenIdMap,
        lockedChildren: lockedChildren,
        onReorder: onReorder,
      );
    }
  }
}

/// Called when the item changes his position between more than one item.
///
/// After the user drags the item with the given [dragOrderId] to another
/// position under the current item and there would be more than one update of
/// the positions, then this method should be called.
///
/// It loops over all items that are between [dragOrderId] and
/// [collisionOrderId] and handles every collision of them.
///
/// The Map [childrenOrderIdMap] is important to improve the performance for
/// searching children with a specific orderId.
///
/// There is no return value because [childrenIdMap] and [childrenOrderIdMap]
/// gets immediately updated.
void handleMultipleCollisionsForward({
  required int dragOrderId,
  required int collisionOrderId,
  required Map<int, GridItemEntity> childrenIdMap,
  required List<int> lockedChildren,
  required ReorderCallback onReorder,
}) {
  for (int i = dragOrderId; i < collisionOrderId; i++) {
    int currentDragOrderId = i;
    int foundCollisionOrderId = i + 1;

    // look for the next child that has a collision
    if (lockedChildren.contains(foundCollisionOrderId)) {
      while (i + 2 <= collisionOrderId &&
          lockedChildren.contains(foundCollisionOrderId)) {
        foundCollisionOrderId = i + 2;
        i++;
      }
    }

    if (foundCollisionOrderId <= collisionOrderId) {
      handleOneCollision(
        dragOrderId: currentDragOrderId,
        collisionOrderId: foundCollisionOrderId,
        childrenIdMap: childrenIdMap,
        lockedChildren: lockedChildren,
        onReorder: onReorder,
      );
    }
  }
}
