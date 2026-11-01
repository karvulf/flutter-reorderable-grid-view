import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_builder_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/reorder_update_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';

/// Handles drag and drop of the children in [ReorderableBuilder.wrap].
///
/// Children in a [Wrap] can have different sizes, so swapping the positions
/// of two colliding children would let them overlap. Instead, the positions
/// of all children are recalculated like a [Wrap] would lay them out.
class ReorderableWrapController extends ReorderableBuilderController {
  /// Key of the [Wrap] returned by [ReorderableBuilder.builder].
  ///
  /// [ReorderableBuilder] sets the key manually to ensure to have access
  /// to [Wrap].
  final wrapKey = GlobalKey();

  /// Key of the child that collided last with the dragged child.
  Key? _lastCollisionKey;

  /// Updates the children and measures the ones with a new position again.
  ///
  /// [offsetMap] caches the offset of every index. That only works if every
  /// index keeps its position, like in a grid. In a [Wrap], the position of
  /// an index depends on the sizes of all children before it, so the cached
  /// offsets would belong to other children after they changed their order.
  /// Instead, the positions are taken from [getReorderableEntity] which is
  /// also overridden.
  @override
  void updateChildren({required List<Widget> children}) {
    offsetMap.clear();
    super.updateChildren(children: children);
  }

  /// Returns the entity of [key] at [index] with its known position.
  ///
  /// After dropping a child, every child already has its new position
  /// calculated while dragging. Only children with an unknown position at
  /// [index], e.g. new children or children moved by adding or removing
  /// another child, are measured again.
  @override
  ReorderableEntity getReorderableEntity({
    required ValueKey key,
    required int index,
  }) {
    final entity = childrenKeyMap[key.value];

    if (entity == null) {
      return ReorderableEntity.create(key: key, updatedOrderId: index);
    }

    final hasFinishedBuildingOffset =
        entity.updatedOrderId == index && !entity.isBuildingOffset;
    return entity.updated(
      updatedOrderId: index,
      updatedOffset: hasFinishedBuildingOffset ? entity.updatedOffset : null,
      size: entity.size,
    );
  }

  /// Marks a measured child that changed its order as moved to animate it.
  ///
  /// In a grid, the new position of a child is known before it is built
  /// again, so it is animated as a swapped child. In a [Wrap], children that
  /// changed their order, e.g. after removing another child, are measured
  /// first (see [getReorderableEntity]). Without marking them, they would
  /// jump to their new position.
  @override
  ReorderableEntity handleCreatedChild({
    required Offset? offset,
    required Size size,
    required ReorderableEntity reorderableEntity,
  }) {
    final entity = super.handleCreatedChild(
      offset: offset,
      size: size,
      reorderableEntity: reorderableEntity,
    );
    final hasMoved = draggedEntity == null &&
        !entity.isNew &&
        entity.originalOrderId != entity.updatedOrderId &&
        entity.originalOffset != entity.updatedOffset;

    if (!hasMoved) {
      return entity;
    }

    final movedEntity = entity.dragUpdated(
      updatedOrderId: entity.updatedOrderId,
      updatedOffset: entity.updatedOffset,
    );

    // same map keys as used by the base controller after creating a child
    childrenKeyMap[movedEntity.key.value] = movedEntity;
    childrenOrderMap[movedEntity.originalOrderId] = movedEntity;
    return movedEntity;
  }

  /// Exchanges the dragged child with [collision] and lays out all children.
  ///
  /// Children with different sizes change the line breaks, so the following
  /// children move to make space. [collision] can end up under the dragged
  /// child again, which would exchange both back and forth on every move.
  /// So the last [collision] is ignored until the dragged child left it.
  ///
  /// Locked children are never exchanged, so they keep their index.
  /// Without a child under the dragged child, e.g. when dragging outside of
  /// all children, the dragged child moves to the index of [collision] like
  /// in a grid.
  @override
  bool applyCollision({
    required ReorderableEntity? collision,
    required Offset draggedOffset,
  }) {
    if (collision?.key == _lastCollisionKey) {
      return false;
    }

    _lastCollisionKey = collision?.key;
    final draggedEntity = this.draggedEntity;

    if (collision == null ||
        draggedEntity == null ||
        _isLocked(entity: collision)) {
      return false;
    }

    final isOverCollision =
        (collision.updatedOffset & collision.size).contains(draggedOffset);
    if (isOverCollision) {
      _exchange(draggedEntity: draggedEntity, collision: collision);
    } else {
      super.applyCollision(collision: collision, draggedOffset: draggedOffset);
    }
    _updatePositions();
    return true;
  }

  /// Exchanges the index of [draggedEntity] with the one of [collision].
  void _exchange({
    required ReorderableEntity draggedEntity,
    required ReorderableEntity collision,
  }) {
    _updateEntity(
      entity: collision.dragUpdated(
        updatedOrderId: draggedEntity.updatedOrderId,
        updatedOffset: collision.updatedOffset,
      ),
    );
    _updateEntity(
      entity: draggedEntity.dragUpdated(
        updatedOrderId: collision.updatedOrderId,
        updatedOffset: draggedEntity.updatedOffset,
      ),
    );
  }

  /// Returns the moves from the order before dragging to the current order.
  ///
  /// Children can be exchanged, so the new order is not only one move of the
  /// dragged child. Every child is moved to its new index one after the
  /// other, like [reorderList] applies them.
  @override
  List<ReorderUpdateEntity>? handleDragEnd() {
    _lastCollisionKey = null;

    if (draggedEntity == null) {
      return null;
    }

    final previousKeys = (childrenKeyMap.values.toList()
          ..sort((a, b) => a.originalOrderId.compareTo(b.originalOrderId)))
        .map((entity) => entity.key)
        .toList();
    final reorderUpdateEntities = <ReorderUpdateEntity>[];

    for (final (newIndex, entity) in _getOrderedEntities().indexed) {
      final oldIndex = previousKeys.indexOf(entity.key);

      if (oldIndex == newIndex) {
        continue;
      }

      reorderUpdateEntities.add(
        ReorderUpdateEntity(oldIndex: oldIndex, newIndex: newIndex),
      );
      previousKeys.insert(newIndex, previousKeys.removeAt(oldIndex));
    }

    draggedEntity = null;

    if (reorderUpdateEntities.isEmpty) {
      return null;
    }

    updateToActualPositions();
    return reorderUpdateEntities;
  }

  bool _isLocked({required ReorderableEntity entity}) =>
      lockedIndices.contains(entity.updatedOrderId);

  /// Lays out all children in their current order like the [Wrap].
  void _updatePositions() {
    final renderWrap = _getRenderWrap();

    if (renderWrap == null) {
      return;
    }

    final entities = _getOrderedEntities();
    final offsets = _calculateOffsets(
      orderedEntities: entities,
      renderWrap: renderWrap,
    );

    for (final (index, entity) in entities.indexed) {
      final updatedOffset = offsets[index];

      if (updatedOffset == entity.updatedOffset) {
        continue;
      }

      _updateEntity(
        entity: entity.dragUpdated(
          updatedOrderId: entity.updatedOrderId,
          updatedOffset: updatedOffset,
        ),
      );
    }
  }

  /// Returns all children sorted by their current order.
  List<ReorderableEntity> _getOrderedEntities() =>
      childrenKeyMap.values.toList()
        ..sort((a, b) => a.updatedOrderId.compareTo(b.updatedOrderId));

  /// Returns the offsets of [orderedEntities] laid out by [renderWrap].
  ///
  /// The offsets are in the same coordinates as [ReorderableEntity.updatedOffset].
  List<Offset> _calculateOffsets({
    required List<ReorderableEntity> orderedEntities,
    required RenderWrap renderWrap,
  }) {
    final wrapOffset = _getWrapOffset(renderWrap: renderWrap);
    final offsets = calculateWrapOffsets(
      sizes: orderedEntities.map((e) => e.size).toList(),
      renderWrap: renderWrap,
    );
    return offsets.map((e) => e + wrapOffset).toList();
  }

  /// Calculates the offsets of children with [sizes] like [renderWrap] would do.
  ///
  /// A copy of [renderWrap] with the same layout values lays out empty boxes
  /// with [sizes], so every layout of [Wrap] is supported. [renderWrap] has
  /// to be laid out to know its constraints. The offsets are relative to the
  /// top left of the [Wrap] and in the same order as [sizes].
  @visibleForTesting
  List<Offset> calculateWrapOffsets({
    required List<Size> sizes,
    required RenderWrap renderWrap,
  }) {
    final layoutWrap = RenderWrap(
      direction: renderWrap.direction,
      alignment: renderWrap.alignment,
      spacing: renderWrap.spacing,
      runAlignment: renderWrap.runAlignment,
      runSpacing: renderWrap.runSpacing,
      crossAxisAlignment: renderWrap.crossAxisAlignment,
      textDirection: renderWrap.textDirection,
      verticalDirection: renderWrap.verticalDirection,
    );
    final boxes = sizes
        .map(
          (size) => RenderConstrainedBox(
            additionalConstraints: BoxConstraints.tight(size),
          ),
        )
        .toList();
    layoutWrap
      ..addAll(boxes)
      ..layout(renderWrap.constraints);

    final offsets =
        boxes.map((box) => (box.parentData! as WrapParentData).offset).toList();
    layoutWrap.dispose();
    return offsets;
  }

  /// Returns the rendered [Wrap] of [wrapKey].
  RenderWrap? _getRenderWrap() {
    final renderWrap = wrapKey.currentContext?.findRenderObject();
    assert(
      renderWrap is RenderWrap,
      'The builder of ReorderableBuilder.wrap has to return a Wrap.',
    );

    if (renderWrap is! RenderWrap) {
      return null;
    }

    return renderWrap;
  }

  /// Returns the top left position of the [Wrap].
  ///
  /// The original offsets were measured before dragging and don't change
  /// while dragging. Laying out the children in their original order gives
  /// their offsets inside the [Wrap], the difference to a measured offset is
  /// the position of the [Wrap].
  Offset _getWrapOffset({required RenderWrap renderWrap}) {
    // new children have no original offset
    final originalEntities = childrenKeyMap.values
        .where((entity) => !entity.isNew)
        .toList()
      ..sort((a, b) => a.originalOrderId.compareTo(b.originalOrderId));
    if (originalEntities.isEmpty) {
      return Offset.zero;
    }

    final offsets = calculateWrapOffsets(
      sizes: originalEntities.map((e) => e.size).toList(),
      renderWrap: renderWrap,
    );

    return originalEntities.first.originalOffset - offsets.first;
  }

  /// Replaces the entity in both maps and in [draggedEntity] if it's dragged.
  void _updateEntity({required ReorderableEntity entity}) {
    childrenKeyMap[entity.key.value] = entity;
    childrenOrderMap[entity.updatedOrderId] = entity;

    if (entity.key == draggedEntity?.key) {
      draggedEntity = entity;
    }
  }
}
