import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorder_update_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';

/// Handles the drag and drop state of the children in [ReorderableBuilder].
///
/// While dragging, collisions between the dragged child and other children
/// swap their positions, skipping [lockedIndices]. Dragging before or after
/// all children moves the dragged child to the first or last unlocked
/// position. When the drag ends, the changed positions are returned as
/// [ReorderUpdateEntity]s so the children can be reordered.
class ReorderableDragAndDropController extends ReorderableController {
  /// Indices of children that cannot move while drag and drop.
  @visibleForTesting
  var lockedIndices = <int>[];

  /// Entity that is released after drag and drop.
  ///
  /// [ReleasedReorderableEntity] contains the offset where it was released.
  /// This value is required to animate the released item to his new position.
  ReleasedReorderableEntity? releasedReorderableEntity;

  /// Defines if the scrollable part is outside of the widget.
  ///
  /// The scrollable part can be a SingleChildScrollView that contains a
  /// GridView. In that case the GridView wouldn't be scrollable and this
  /// parameter should be true.
  ///
  /// If the GridView is scrollable, then this will be true.
  @visibleForTesting
  bool isScrollableOutside = false;

  /// Saves the state of scroll [Offset] when the drag and drop is starting.
  ///
  /// This is need to calculate with correct values later when doing
  /// drag and drop while scrolling and the scrolling is outside of
  /// [ReorderableBuilder].
  @visibleForTesting
  Offset startDraggingScrollOffset = Offset.zero;

  /// Holding this value for better performance.
  ///
  /// After dragging a child, [scrollOffset] is always updated.
  Offset scrollOffset = Offset.zero;

  /// Main axis of the grid, used when dragging before/after all children.
  Axis? scrollDirection;

  void handleDragStarted({
    required ReorderableEntity reorderableEntity,
    required Offset currentScrollOffset,
    required List<int> lockedIndices,
    required bool isScrollableOutside,
    required int? itemCount,
    required Axis? scrollDirection,
  }) {
    this.scrollDirection = scrollDirection;
    releasedReorderableEntity = null;
    draggingAnimationMap.clear();
    this.lockedIndices = lockedIndices;
    _settleMovingChildren();
    draggedEntity = childrenKeyMap[reorderableEntity.key.value];
    scrollOffset = currentScrollOffset;
    this.isScrollableOutside = isScrollableOutside;
    startDraggingScrollOffset = currentScrollOffset;
    if (itemCount != null) super.shortenMapsToItemCount(itemCount: itemCount);
  }

  bool handleDragUpdate({required PointerMoveEvent pointerMoveEvent}) {
    final draggedKey = draggedEntity?.key;
    if (draggedKey == null) return false;

    final localOffset = pointerMoveEvent.localPosition;
    late final Offset offset;

    if (isScrollableOutside) {
      offset = localOffset + (scrollOffset - startDraggingScrollOffset);
    } else {
      offset = localOffset + scrollOffset;
    }

    final collisionReorderableEntity = filterCollision(
      _getCollisionReorderableEntity(
        keyValue: draggedKey.value,
        draggedOffset: offset,
      ),
    );
    final collisionOrderId = collisionReorderableEntity?.updatedOrderId;

    if (collisionOrderId != null && !lockedIndices.contains(collisionOrderId)) {
      final draggedOrderId = draggedEntity!.updatedOrderId;
      _updateMultipleCollisions(
        collisionReorderableEntity: collisionReorderableEntity!,
        isBackwards: draggedOrderId > collisionOrderId,
      );
      updatePositionsAfterCollision();
      return true;
    }

    return false;
  }

  /// Returns the child the dragged child should collide with.
  ///
  /// [collision] is the child found under the dragged child. Layouts with
  /// children of different sizes, e.g. [Wrap], override this to ignore
  /// collisions that would swap the children back and forth.
  @protected
  ReorderableEntity? filterCollision(ReorderableEntity? collision) => collision;

  /// Called after the dragged child changed its order with other children.
  ///
  /// The colliding children already swapped their positions, which is only
  /// correct if all children have the same size. Layouts with children of
  /// different sizes, e.g. [Wrap], override this to recalculate the positions.
  @protected
  void updatePositionsAfterCollision() {}

  List<ReorderUpdateEntity>? handleDragEnd() {
    final draggedEntity = this.draggedEntity;
    if (draggedEntity == null) return null;

    final oldIndex = draggedEntity.originalOrderId;
    final newIndex = draggedEntity.updatedOrderId;

    this.draggedEntity = null;

    if (oldIndex == newIndex) return null;

    final orderUpdateEntities = _getOrderUpdateEntities(
      oldIndex: oldIndex,
      newIndex: newIndex,
    );

    updateToActualPositions();
    return orderUpdateEntities;
  }

  /// Applies the target position of children still moving to it.
  ///
  /// E.g. after a child was removed, the others animate to their new position
  /// and still keep their old orderId and offset as original values. Dragging
  /// treats the original values as the position of the child, so it would
  /// animate them from the wrong offset and report a wrong old index.
  /// The running move animations still end at the target position.
  /// New children and children without a measured offset are skipped.
  void _settleMovingChildren() {
    final settledKeyMap = <String, ReorderableEntity>{};
    final settledOrderMap = <int, ReorderableEntity>{};

    for (final entry in childrenKeyMap.entries) {
      final entity = entry.value;
      final settled = entity.isNew || entity.isBuildingOffset
          ? entity
          : entity.positionUpdated();
      settledKeyMap[entry.key] = settled;
      settledOrderMap[settled.updatedOrderId] = settled;
    }

    replaceMaps(
      updatedChildrenKeyMap: settledKeyMap,
      updatedChildrenOrderMap: settledOrderMap,
    );
  }

  /// Updates all children that were between the collision and dragged child position.
  void _updateMultipleCollisions({
    required ReorderableEntity collisionReorderableEntity,
    required bool isBackwards,
  }) {
    final summands = isBackwards ? -1 : 1;
    final collisionOrderId = collisionReorderableEntity.updatedOrderId;
    var currentCollisionOrderId = draggedEntity!.updatedOrderId;

    while (currentCollisionOrderId != collisionOrderId) {
      currentCollisionOrderId += summands;

      if (!lockedIndices.contains(currentCollisionOrderId)) {
        final collisionMapEntry = childrenOrderMap[currentCollisionOrderId];

        // can happen if the collision item is still building
        if (collisionMapEntry == null) {
          return;
        }

        _updateCollision(collisionReorderableEntity: collisionMapEntry);
      }
    }
  }

  /// Swapping position and offset between dragged child and collision child.
  ///
  /// The collision is only valid when the orderId of the child is not found in
  /// [widget.lockedIndices].
  ///
  /// When a collision was detected, then the collision child and dragged child
  /// are swapping the position and orderId. At that moment, only the value
  /// updatedOrderId and updatedOffset of [ReorderableEntity] will be updated
  /// to ensure that an animation will be shown.
  void _updateCollision({
    required ReorderableEntity collisionReorderableEntity,
  }) {
    final draggedEntity = this.draggedEntity;
    if (draggedEntity == null) return;

    if (collisionReorderableEntity.updatedOrderId ==
        draggedEntity.updatedOrderId) {
      return;
    }

    // update for collision entity
    final updatedCollisionEntity = collisionReorderableEntity.dragUpdated(
      updatedOffset: draggedEntity.updatedOffset,
      updatedOrderId: draggedEntity.updatedOrderId,
    );

    // update for dragged entity
    final updatedDraggedEntity = draggedEntity.dragUpdated(
      updatedOffset: collisionReorderableEntity.updatedOffset,
      updatedOrderId: collisionReorderableEntity.updatedOrderId,
    );

    this.draggedEntity = updatedDraggedEntity;

    final collisionKeyValue = updatedCollisionEntity.key.value;
    final collisionUpdatedOrderId = updatedCollisionEntity.updatedOrderId;

    childrenKeyMap[collisionKeyValue] = updatedCollisionEntity;
    childrenOrderMap[collisionUpdatedOrderId] = updatedCollisionEntity;

    final draggedKeyValue = updatedDraggedEntity.key.value;
    final draggedUpdatedOrderId = updatedDraggedEntity.updatedOrderId;

    childrenKeyMap[draggedKeyValue] = updatedDraggedEntity;
    childrenOrderMap[draggedUpdatedOrderId] = updatedDraggedEntity;
  }

  /// Checking if the dragged child collision with another child in [_childrenMap].
  ReorderableEntity? _getCollisionReorderableEntity({
    required dynamic keyValue,
    required Offset draggedOffset,
  }) {
    for (final entry in childrenKeyMap.entries) {
      if (entry.key == keyValue) {
        continue;
      }

      // checking collision with full item size and local position
      final childRect = entry.value.updatedOffset & entry.value.size;
      if (childRect.contains(draggedOffset)) {
        return entry.value;
      }
    }

    final outsideEntity = _getOutsideReorderableEntity(
      draggedOffset: draggedOffset,
    );

    if (outsideEntity?.key.value == keyValue) {
      return null;
    }
    return outsideEntity;
  }

  /// Returns the first or last unlocked child when dragged outside of all.
  ///
  /// The dragged child is outside when [draggedOffset] is before or after all
  /// children along the main axis ([scrollDirection]).
  ReorderableEntity? _getOutsideReorderableEntity({
    required Offset draggedOffset,
  }) {
    final unlockedEntities = _getUnlockedEntitiesInDisplayOrder();
    if (unlockedEntities.isEmpty) {
      return null;
    }

    final draggedPosition = scrollDirection == Axis.horizontal
        ? draggedOffset.dx
        : draggedOffset.dy;

    if (draggedPosition < _getMinStartPosition()) {
      return unlockedEntities.first;
    }
    if (draggedPosition > _getMaxEndPosition()) {
      return unlockedEntities.last;
    }

    return null;
  }

  /// Returns all unlocked children in the order they are shown.
  ///
  /// The children are sorted by their order id. Reversed grids show the first
  /// child at the end, so the list is reversed in that case.
  List<ReorderableEntity> _getUnlockedEntitiesInDisplayOrder() {
    final unlockedEntities = childrenKeyMap.values
        .where((entity) => !lockedIndices.contains(entity.updatedOrderId))
        .toList()
      ..sort((a, b) => a.updatedOrderId.compareTo(b.updatedOrderId));
    if (unlockedEntities.isEmpty) {
      return unlockedEntities;
    }

    final startPosition = _getStartPosition(entity: unlockedEntities.first);
    final endPosition = _getStartPosition(entity: unlockedEntities.last);
    final isReversed = startPosition > endPosition;
    return isReversed ? unlockedEntities.reversed.toList() : unlockedEntities;
  }

  /// Returns the smallest start position of all children along the main axis.
  double _getMinStartPosition() => childrenKeyMap.values
      .map((child) => _getStartPosition(entity: child))
      .reduce(min);

  /// Returns the largest end position of all children along the main axis.
  double _getMaxEndPosition() => childrenKeyMap.values
      .map((child) => _getEndPosition(entity: child))
      .reduce(max);

  /// Returns the start position of [entity] along the main axis.
  double _getStartPosition({required ReorderableEntity entity}) =>
      scrollDirection == Axis.horizontal
          ? entity.updatedOffset.dx
          : entity.updatedOffset.dy;

  /// Returns the end position of [entity] along the main axis.
  double _getEndPosition({required ReorderableEntity entity}) =>
      _getStartPosition(entity: entity) +
      (scrollDirection == Axis.horizontal
          ? entity.size.width
          : entity.size.height);

  /// Returns a list of all updated positions containing old and new index.
  ///
  /// This method is a special case because of [widget.lockedIndices]. To ensure
  /// that the user reorder [widget.children] correctly, it has to be checked
  /// if there a locked indices between [oldIndex] and [newIndex].
  /// If that's the case, then at least one more [OrderUpdateEntity] will be
  /// added to that list.
  ///
  /// There are two ways when reordering. The order could have changed upwards or
  /// downwards. So if the variable summands is positive, that means the order
  /// changed upwards, e.g. the item was moved from order 0 (=oldIndex) to 4 (=newIndex).
  ///
  /// For every time in this ordering sequence, when a locked index was found,
  /// a new [OrderUpdateEntity] will be added to the returned list. This is
  /// important to reorder all items correctly afterwards.
  ///
  /// E.g. when the oldIndex was 0, the newIndex is 4 and index 2 is locked, then
  /// at least there are two [OrderUpdateEntity] in the list.
  ///
  /// The first one contains always the old and new index. The second one is added
  /// after the locked index.
  ///
  /// So if the oldIndex was 0 and the new index 4, and the locked index is 2,
  /// then the draggedOrderId would be 0. It will be updated after the locked index.
  /// The current collisionId is always the current orderId in the while loop.
  /// After looping through the old index until index 3, then a new [OrderUpdateEntity]
  /// is created. The old index would be the current collisionId with the summands.
  /// Because the summands can be -1 or 1, this calculation works in both directions.
  ///
  /// That means that the oldIndex is 2.
  ///
  /// The newIndex is the current draggedOrderId (= 0) with a notLockedIndicesCounter
  /// multiplied the summands.
  ///
  /// The notLockedIndicesCounter is the number of indices that were before the
  /// locked index. In this case, there are two of them: the index 0 and 1.
  /// So notLockedIndicesCounter would be 1 because the counting starts at index 1
  /// and goes on until 4.
  ///
  /// That results with a new index value of 1.
  ///
  /// So the list with two entities will be returend. The first one with
  /// (0, 4) and (2, 1).
  ///
  /// When the user has the following list items:
  /// ```dart
  /// final listItems = [0, 1, 2, 3, 4]
  /// ```
  /// with a locked index at 2.
  /// When reordering, the user has to iterate through the two items, that would
  /// results in the following code:
  ///
  /// ```dart
  /// for(final orderUpdateEntity in orderUpdateEntities) {
  ///   final item = listItems.removeAt(orderUpdateEntity.oldIndex);
  ///   listItems.insertAt(4, orderUpdateEntity.newIndex);
  /// }
  /// ```
  /// To explain what is happening in this loop:
  ///
  /// The first [OrderUpdateEntity] would order the list to the following list,
  /// when removing at the old index 0 and inserting at new index 4:
  ///
  /// ```dart
  /// [0, 1, 2, 3, 4] -> [1, 2, 3, 4, 0].
  /// ```
  ///
  /// Because the item at index 2 is locked, the number 2 shouldn't change the
  /// position. This is the reason, why there are more than one entity in the list
  /// when having a lockedIndex.
  ///
  /// The second [OrderUpdateEntity] has the oldIndex 2 and newIndex 1:
  ///
  /// ```dart
  /// [1, 2, 3, 4, 0] -> [1, 3, 2, 4, 0].
  /// ```
  ///
  /// Now the ordering is correct. The number 2 is still at the locked index 2.
  List<ReorderUpdateEntity> _getOrderUpdateEntities({
    required int oldIndex,
    required int newIndex,
  }) {
    final orderUpdateEntities = [
      ReorderUpdateEntity(
        oldIndex: oldIndex,
        newIndex: newIndex,
      ),
    ];

    // depends if ordering back or forwards
    final summands = oldIndex > newIndex ? -1 : 1;
    // when a locked index was found, this id will be updated to the index after the locked index
    var currentDraggedOrderId = oldIndex;
    // counting the id upwards or downwards until newIndex was reached
    var currentCollisionOrderId = oldIndex;

    var hasFoundLockedIndex = false;
    // important counter to get a correct value for newIndex when there were multiple not locked indices before a locked index
    var notLockedIndicesCounter = 0;

    // counting currentCollisionOrderId = oldIndex until newIndex
    while (currentCollisionOrderId != newIndex) {
      currentCollisionOrderId += summands;

      if (!lockedIndices.contains(currentCollisionOrderId)) {
        // if there was one or more locked indices, then a new OrderUpdateEntity has to be added
        // this prevents wrong ordering values when calling onReorder
        if (hasFoundLockedIndex) {
          orderUpdateEntities.add(
            ReorderUpdateEntity(
              oldIndex: currentCollisionOrderId - summands,
              newIndex:
                  currentDraggedOrderId + notLockedIndicesCounter * summands,
            ),
          );
          currentDraggedOrderId = currentCollisionOrderId;
          hasFoundLockedIndex = false;
          notLockedIndicesCounter = 0;
        } else {
          notLockedIndicesCounter++;
        }
      } else {
        hasFoundLockedIndex = true;
      }
    }

    return orderUpdateEntities;
  }

  /// Reorders list of [items] that depends on [reorderUpdateEntities].
  ///
  /// This function optimizes the reordering process of [items].
  /// This is very helpful when having big lists. The function only orders
  /// the items sublist that is affected of the reordered items.
  ///
  /// E. g. if you have the list = [0, 1, 2, 3, 4] and changes the position
  /// between "2" and "3", then it is more performant when only updating the
  /// items on position 2 and 3 by creating a sublist containing [2, 3] and
  /// changing them to [3, 2] and inserting this sublist afterwards to the list
  /// and getting [0, 1, 3, 2, 4].
  List<T> reorderList<T>({
    required List<T> items,
    required List<ReorderUpdateEntity> reorderUpdateEntities,
  }) {
    final updatedItems = items.toList();

    for (final reorder in reorderUpdateEntities) {
      final reorderLeftToRight = reorder.oldIndex < reorder.newIndex;
      final start = reorderLeftToRight ? reorder.oldIndex : reorder.newIndex;
      final end = reorderLeftToRight ? reorder.newIndex : reorder.oldIndex;
      final sublist = updatedItems.sublist(start, end + 1);
      final child =
          reorderLeftToRight ? sublist.removeAt(0) : sublist.removeLast();
      sublist.insert(reorderLeftToRight ? sublist.length : 0, child);
      updatedItems.replaceRange(start, end + 1, sublist);
    }

    return updatedItems;
  }
}
