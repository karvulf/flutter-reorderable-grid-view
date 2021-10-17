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
  required int id,
  required Offset position,
  required Map<int, GridItemEntity> childrenIdMap,
  required List<int> lockedChildren,
  required double scrollPixelsY,
}) {
  int? collisionId;

  // child does not exist or is locked
  if (childrenIdMap[id] == null || lockedChildren.contains(id)) {
    return null;
  }

  for (final entry in childrenIdMap.entries) {
    final item = entry.value;
    final itemDx = item.globalPosition.dx;
    final itemDy = item.globalPosition.dy;
    final itemWidth = item.size.width;
    final itemHeight = item.size.height;
    final detailsDx = position.dx;
    final detailsDy = position.dy + scrollPixelsY;

    // checking collision with full item size and global position
    if (detailsDx >= itemDx &&
        detailsDy >= itemDy &&
        detailsDx <= itemDx + itemWidth &&
        detailsDy <= itemDy + itemHeight) {
      collisionId = entry.key;
      break;
    }
  }

  if (lockedChildren.contains(collisionId)) {
    return null;
  }

  return collisionId;
}

/// Swapping positions and orderId of items with [dragId] and [collisionId].
///
/// Usually this is called after a collision happens between two items while
/// dragging it.
/// The [dragId] and [collisionId] should be different and the [collisionId]
/// should not be in [lockedChildren].
/// If that is not the case, then the following values are swapped between
/// the two items with [dragId] and [collisionId]
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
  required int dragId,
  required int collisionId,
  required Map<int, GridItemEntity> childrenIdMap,
  required Map<int, GridItemEntity> childrenOrderIdMap,
  required List<int> lockedChildren,
}) {
  assert(dragId != collisionId);

  if (lockedChildren.contains(collisionId)) {
    return;
  }

  final entryA = childrenIdMap[dragId]!;
  final entryB = childrenIdMap[collisionId]!;

  final updatedEntryValueA = entryA.copyWith(
    localPosition: entryB.localPosition,
    globalPosition: entryB.globalPosition,
    orderId: entryB.orderId,
  );
  final updatedEntryValueB = entryB.copyWith(
    localPosition: entryA.localPosition,
    globalPosition: entryA.globalPosition,
    orderId: entryA.orderId,
  );

  childrenIdMap[dragId] = updatedEntryValueA;
  childrenIdMap[collisionId] = updatedEntryValueB;

  childrenOrderIdMap[entryA.orderId] = updatedEntryValueB;
  childrenOrderIdMap[entryB.orderId] = updatedEntryValueA;
}

/// Called when the item changes his position between more than one item.
///
/// After the user drags the item with the given [dragItemOrderId] to another
/// position above the current item and there would be more than one update of
/// the positions, then this method should be called.
///
/// It loops over all items that are between [dragItemOrderId] and
/// [collisionItemOrderId] and handles every collision of them.
///
/// The Map [childrenOrderIdMap] is important to improve the performance for
/// searching children with a specific orderId.
///
/// There is no return value because [childrenIdMap] and [childrenOrderIdMap]
/// gets immediately updated.
void handleMultipleCollisionsBackward({
  required int dragItemOrderId,
  required int collisionItemOrderId,
  required Map<int, GridItemEntity> childrenIdMap,
  required Map<int, GridItemEntity> childrenOrderIdMap,
  required List<int> lockedChildren,
}) {
  for (int i = dragItemOrderId; i > collisionItemOrderId; i--) {
    int? dragId = childrenOrderIdMap[i]?.id;
    int? collisionId = childrenOrderIdMap[i - 1]?.id;

    if (lockedChildren.contains(collisionId)) {
      while (i - 2 >= collisionItemOrderId &&
          lockedChildren.contains(collisionId)) {
        collisionId = childrenOrderIdMap[i - 2]?.id;
        i--;
      }
    }

    if (dragId != null && collisionId != null) {
      handleOneCollision(
        dragId: dragId,
        collisionId: collisionId,
        childrenIdMap: childrenIdMap,
        childrenOrderIdMap: childrenOrderIdMap,
        lockedChildren: lockedChildren,
      );
    }
  }
}

/// Called when the item changes his position between more than one item.
///
/// After the user drags the item with the given [dragItemOrderId] to another
/// position under the current item and there would be more than one update of
/// the positions, then this method should be called.
///
/// It loops over all items that are between [dragItemOrderId] and
/// [collisionItemOrderId] and handles every collision of them.
///
/// The Map [childrenOrderIdMap] is important to improve the performance for
/// searching children with a specific orderId.
///
/// There is no return value because [childrenIdMap] and [childrenOrderIdMap]
/// gets immediately updated.
void handleMultipleCollisionsForward({
  required int dragItemOrderId,
  required int collisionItemOrderId,
  required Map<int, GridItemEntity> childrenIdMap,
  required Map<int, GridItemEntity> childrenOrderIdMap,
  required List<int> lockedChildren,
}) {
  for (int i = dragItemOrderId; i < collisionItemOrderId; i++) {
    int? dragId = childrenOrderIdMap[i]?.id;
    int? collisionId = childrenOrderIdMap[i + 1]?.id;

    // look for the next child that has a collision
    if (lockedChildren.contains(collisionId)) {
      while (i + 2 <= collisionItemOrderId &&
          lockedChildren.contains(collisionId)) {
        collisionId = childrenOrderIdMap[i + 2]?.id;
        i++;
      }
    }

    if (dragId != null && collisionId != null) {
      handleOneCollision(
        dragId: dragId,
        collisionId: collisionId,
        childrenIdMap: childrenIdMap,
        lockedChildren: lockedChildren,
        childrenOrderIdMap: childrenOrderIdMap,
      );
    }
  }
}
