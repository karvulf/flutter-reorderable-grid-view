import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/release_4/controller/reorderable_controller.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';

class ReorderableDragAndDropController extends ReorderableController {
  ReorderableEntity? _draggedEntity;

  /// Holding this value for better performance.
  ///
  /// After dragging a child, [_scrollPositionPixels] is always updated.
  double _scrollPositionPixels = 0.0;

  void handleDragStarted({
    required ReorderableEntity reorderableEntity,
    required double currentScrollPixels,
  }) {
    _draggedEntity = childrenKeyMap[reorderableEntity.key.value];
    _scrollPositionPixels = currentScrollPixels;
  }

  bool handleDragUpdate({
    required PointerMoveEvent pointerMoveEvent,
    required List<int> lockedIndices,
  }) {
    final draggedKey = draggedEntity?.key;
    if (draggedKey == null) return false;

    final position = pointerMoveEvent.position;
    var draggedOffset = Offset(
      position.dx,
      position.dy + _scrollPositionPixels,
    );

    final collisionReorderableEntity = _getCollisionReorderableEntity(
      keyValue: draggedKey.value,
      draggedOffset: draggedOffset,
    );
    final collisionOrderId = collisionReorderableEntity?.updatedOrderId;

    if (collisionOrderId != null && !lockedIndices.contains(collisionOrderId)) {
      final draggedOrderId = _draggedEntity!.updatedOrderId;

      final difference = draggedOrderId - collisionOrderId;
      if (difference > 1) {
        _updateMultipleCollisions(
          collisionReorderableEntity: collisionReorderableEntity!,
          draggedKey: draggedKey,
          isBackwards: true,
          lockedIndices: lockedIndices,
        );
      } else if (difference < -1) {
        _updateMultipleCollisions(
          collisionReorderableEntity: collisionReorderableEntity!,
          draggedKey: draggedKey,
          isBackwards: false,
          lockedIndices: lockedIndices,
        );
      } else {
        _updateCollision(
          collisionReorderableEntity: collisionReorderableEntity!,
          lockedIndices: lockedIndices,
        );
      }
      return true;
    }

    return false;
  }

  void handleScrollUpdate({required double scrollPixels}) {
    _scrollPositionPixels = scrollPixels;
  }

  void handleDragEnd() {
    _draggedEntity = null;
  }

  ReorderableEntity? get draggedEntity => _draggedEntity;

  /// private

  /// Updates all children that were between the collision and dragged child position.
  void _updateMultipleCollisions({
    required Key draggedKey,
    required ReorderableEntity collisionReorderableEntity,
    required bool isBackwards,
    required List<int> lockedIndices,
  }) {
    final summands = isBackwards ? -1 : 1;
    final collisionOrderId = collisionReorderableEntity.updatedOrderId;
    var currentCollisionOrderId = _draggedEntity!.updatedOrderId;

    while (currentCollisionOrderId != collisionOrderId) {
      currentCollisionOrderId += summands;

      if (!lockedIndices.contains(currentCollisionOrderId)) {
        final collisionMapEntry = childrenOrderMap[currentCollisionOrderId];
        /*final collisionMapEntry2 = childrenKeyMap.entries
            .firstWhere(
              (entry) => entry.value.updatedOrderId == currentCollisionOrderId,
            )
            .value;*/
        _updateCollision(
          collisionReorderableEntity: collisionMapEntry!,
          lockedIndices: lockedIndices,
        );
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
    required List<int> lockedIndices,
  }) {
    final draggedEntity = _draggedEntity;
    if (draggedEntity == null) return;

    final collisionOrderId = collisionReorderableEntity.updatedOrderId;
    if (lockedIndices.contains(collisionOrderId)) return;
    if (collisionReorderableEntity.updatedOrderId ==
        _draggedEntity!.updatedOrderId) {
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

    ///
    /// some prints for me
    ///
    final draggedOrderIdBefore = updatedDraggedEntity.originalOrderId;
    final draggedOrderIdAfter = updatedDraggedEntity.updatedOrderId;

    final draggedOffsetBefore = updatedDraggedEntity.originalOffset;
    final draggedOffsetAfter = updatedDraggedEntity.updatedOffset;

    final collisionOrderIdBefore = updatedCollisionEntity.originalOrderId;
    final collisionOrderIdAfter = updatedCollisionEntity.updatedOrderId;

    final collisionOffsetBefore = updatedCollisionEntity.originalOffset;
    final collisionOffsetAfter = updatedCollisionEntity.updatedOffset;

    print('');
    print('---- Dragged child at position $draggedOrderIdBefore ----');
    print('Dragged Entity: $updatedDraggedEntity');
    print('----');
    print('Collisioned Entity: $collisionReorderableEntity');
    print('---- END ----');
    print('');
    /*
    print('');
    print('---- Dragged child at position $draggedOrderIdBefore ----');
    print(
        'Dragged child from position $draggedOrderIdBefore to $draggedOrderIdAfter');
    print(
        'Dragged child from offset $draggedOffsetBefore to $draggedOffsetAfter');
    print('----');
    print(
        'Collisioned child from position $collisionOrderIdBefore to $collisionOrderIdAfter');
    print(
        'Collisioned child from offset $collisionOffsetBefore to $collisionOffsetAfter');
    print('---- END ----');
    print('');*/

    _draggedEntity = updatedDraggedEntity;

    final collisionKeyValue = collisionReorderableEntity.key.value;
    final collisionUpdatedOrderId = collisionReorderableEntity.updatedOrderId;

    childrenKeyMap[collisionKeyValue] = updatedCollisionEntity;
    childrenOrderMap[collisionUpdatedOrderId] = updatedCollisionEntity;

    childrenKeyMap[draggedEntity.key.value] = updatedDraggedEntity;
    childrenOrderMap[draggedEntity.updatedOrderId] = updatedDraggedEntity;
  }

  /// Checking if the dragged child collision with another child in [_childrenMap].
  ReorderableEntity? _getCollisionReorderableEntity({
    required dynamic keyValue,
    required Offset draggedOffset,
  }) {
    for (final entry in childrenKeyMap.entries) {
      final localPosition = entry.value.updatedOffset;
      final size = entry.value.size;

      if (entry.key == keyValue) {
        continue;
      }

      // checking collision with full item size and local position
      if (draggedOffset.dx >= localPosition.dx &&
          draggedOffset.dy >= localPosition.dy &&
          draggedOffset.dx <= localPosition.dx + size.width &&
          draggedOffset.dy <= localPosition.dy + size.height) {
        return entry.value;
      }
    }
    return null;
  }
}
