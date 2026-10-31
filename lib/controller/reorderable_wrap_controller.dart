import 'dart:math';

import 'package:flutter/rendering.dart' show RenderWrap;
import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_builder_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/reorder_update_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/reorderable_wrap_layout.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';

/// Handles drag and drop of the children in [ReorderableBuilder.wrap].
///
/// Children in a [Wrap] can have different sizes, so swapping the positions
/// of two colliding children would let them overlap. Instead, the positions
/// of all children are recalculated like a [Wrap] would lay them out.
class ReorderableWrapController extends ReorderableBuilderController {
  /// Key of the [Wrap] returned by [ReorderableBuilder.builder].
  ///
  /// Used to read the layout values of the [Wrap], so they are always the
  /// same as the ones of the user.
  final wrapKey = GlobalKey();

  /// Key of the child that is exchanged with the dragged child.
  ///
  /// Set by [filterCollision] if the dragged child can't be moved to an index
  /// without moving a locked child, but can be exchanged with the child at
  /// its position.
  ValueKey? _exchangeKey;

  /// Updates the children and measures the ones with a new position again.
  ///
  /// [offsetMap] caches the offset of every index. That only works if every
  /// index keeps its position, like in a grid. In a [Wrap], the position of
  /// an index depends on the sizes of all children before it, so the cached
  /// offsets would belong to other children after they changed their order.
  /// Instead, the positions are taken from [getReorderableEntity].
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

    final hasKnownPosition =
        entity.updatedOrderId == index && !entity.isBuildingOffset;
    return entity.updated(
      updatedOrderId: index,
      updatedOffset: hasKnownPosition ? entity.updatedOffset : null,
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
    if (!hasMoved) return entity;

    final movedEntity = entity.dragUpdated(
      updatedOrderId: entity.updatedOrderId,
      updatedOffset: entity.updatedOffset,
    );
    // same map keys as used by the base controller after creating a child
    childrenKeyMap[movedEntity.key.value] = movedEntity;
    childrenOrderMap[movedEntity.originalOrderId] = movedEntity;
    return movedEntity;
  }

  /// Returns the child whose index moves the dragged child to [draggedOffset].
  ///
  /// Children with different sizes change the line breaks of the [Wrap], so
  /// taking the index of the child under [draggedOffset] could move the
  /// dragged child somewhere else. Instead, the dragged child takes the index
  /// where it would be laid out at [draggedOffset].
  ///
  /// If no index is possible, the dragged child is exchanged with [collision]
  /// if that lays it out at [draggedOffset], see [updateOrderAfterCollision].
  ///
  /// Collisions without a child at [draggedOffset], e.g. when dragging
  /// outside of all children, keep the index of [collision].
  ///
  /// An order is never used if it would move a locked child on the screen.
  /// Returns null if there is no such order or the dragged child is already
  /// there.
  // ponytail: lays out all children for every index on each move (O(n²)),
  // only check indices near the pointer if big wraps get slow
  @override
  ReorderableEntity? filterCollision(
    ReorderableEntity? collision, {
    required Offset draggedOffset,
  }) {
    _exchangeKey = null;
    final draggedEntity = this.draggedEntity;
    if (collision == null || draggedEntity == null) return collision;

    final renderWrap = _getRenderWrap();
    if (renderWrap == null) return collision;

    final isOverCollision =
        (collision.updatedOffset & collision.size).contains(draggedOffset);
    bool isAllowed(List<ReorderableEntity> orderedEntities) => _isAllowedOrder(
          orderedEntities,
          renderWrap: renderWrap,
          draggedOffset: isOverCollision ? draggedOffset : null,
        );

    final targets = isOverCollision
        ? _getOrderedEntities().where((entity) => !_isLocked(entity))
        : [collision];
    for (final target in targets) {
      final orderedEntities = _getOrderAfterCollision(
        draggedEntity: draggedEntity,
        collision: target,
      );
      if (!isAllowed(orderedEntities)) continue;

      return target.key == draggedEntity.key ? null : target;
    }

    final canExchange = isOverCollision &&
        !_isLocked(collision) &&
        isAllowed(_getOrderAfterExchange(collision));
    if (!canExchange) return null;

    _exchangeKey = collision.key;
    return collision;
  }

  /// Exchanges the dragged child with [collision] if chosen by [filterCollision].
  ///
  /// Only the two children change their index. That keeps the other children
  /// and especially the locked ones at their position if both have the
  /// same size.
  @override
  void updateOrderAfterCollision(ReorderableEntity collision) {
    final draggedEntity = this.draggedEntity;
    if (collision.key != _exchangeKey || draggedEntity == null) {
      super.updateOrderAfterCollision(collision);
      return;
    }

    _updateEntity(
      collision.dragUpdated(
        updatedOrderId: draggedEntity.updatedOrderId,
        updatedOffset: collision.updatedOffset,
      ),
    );
    _updateEntity(
      draggedEntity.dragUpdated(
        updatedOrderId: collision.updatedOrderId,
        updatedOffset: draggedEntity.updatedOffset,
      ),
    );
  }

  /// Returns the moves from the order before dragging to the current order.
  ///
  /// The dragged child can be moved to an index or exchanged with another
  /// child, so the new order is not only one move of the dragged child.
  /// Every child is moved to its new index one after the other, like
  /// [reorderList] applies them.
  @override
  List<ReorderUpdateEntity>? handleDragEnd() {
    if (draggedEntity == null) return null;

    final previousKeys = (childrenKeyMap.values.toList()
          ..sort((a, b) => a.originalOrderId.compareTo(b.originalOrderId)))
        .map((entity) => entity.key)
        .toList();
    final reorderUpdateEntities = <ReorderUpdateEntity>[];
    for (final (newIndex, entity) in _getOrderedEntities().indexed) {
      final oldIndex = previousKeys.indexOf(entity.key);
      if (oldIndex == newIndex) continue;

      reorderUpdateEntities.add(
        ReorderUpdateEntity(oldIndex: oldIndex, newIndex: newIndex),
      );
      previousKeys.insert(newIndex, previousKeys.removeAt(oldIndex));
    }

    draggedEntity = null;
    _exchangeKey = null;
    if (reorderUpdateEntities.isEmpty) return null;

    updateToActualPositions();
    return reorderUpdateEntities;
  }

  /// Checks if [orderedEntities] can be used as the new order.
  ///
  /// A locked child must keep its position. If [draggedOffset] is given, the
  /// dragged child has to be laid out there.
  bool _isAllowedOrder(
    List<ReorderableEntity> orderedEntities, {
    required RenderWrap renderWrap,
    required Offset? draggedOffset,
  }) {
    final offsets = _calculateOffsets(orderedEntities, renderWrap);
    if (_movesLockedChild(orderedEntities, offsets)) return false;
    if (draggedOffset == null) return true;

    final draggedIndex = orderedEntities.indexWhere(
      (entity) => entity.key == draggedEntity?.key,
    );
    final draggedRect =
        offsets[draggedIndex] & orderedEntities[draggedIndex].size;
    return draggedRect.contains(draggedOffset);
  }

  /// Checks if a locked child of [orderedEntities] would leave its position.
  ///
  /// [offsets] are the new positions of [orderedEntities] in the same order.
  bool _movesLockedChild(
    List<ReorderableEntity> orderedEntities,
    List<Offset> offsets,
  ) {
    for (final (index, entity) in orderedEntities.indexed) {
      final distance = (offsets[index] - entity.updatedOffset).distance;
      // tolerance for measured offsets with small rounding differences
      if (_isLocked(entity) && distance > 0.01) return true;
    }
    return false;
  }

  bool _isLocked(ReorderableEntity entity) =>
      lockedIndices.contains(entity.updatedOrderId);

  @override
  void updatePositionsAfterCollision() {
    final renderWrap = _getRenderWrap();
    if (renderWrap == null) return;

    final entities = _getOrderedEntities();
    final offsets = _calculateOffsets(entities, renderWrap);

    for (final (index, entity) in entities.indexed) {
      final updatedOffset = offsets[index];
      if (updatedOffset == entity.updatedOffset) continue;

      _updateEntity(
        entity.dragUpdated(
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

  /// Returns all children in the order after [draggedEntity] collided with
  /// [collision].
  ///
  /// Same result as the collision handling of the base controller: the
  /// dragged child moves to the index of [collision] and the children in
  /// between move by one, except the children in [lockedIndices].
  List<ReorderableEntity> _getOrderAfterCollision({
    required ReorderableEntity draggedEntity,
    required ReorderableEntity collision,
  }) {
    final orderedEntities = _getOrderedEntities();
    final movableEntities =
        orderedEntities.where((entity) => !_isLocked(entity)).toList();
    final collisionIndex = movableEntities.indexOf(collision);
    movableEntities
      ..removeWhere((entity) => entity.key == draggedEntity.key)
      ..insert(collisionIndex, draggedEntity);

    final movableIterator = movableEntities.iterator;
    return [
      for (final entity in orderedEntities)
        if (_isLocked(entity))
          entity
        else if (movableIterator.moveNext())
          movableIterator.current,
    ];
  }

  /// Returns all children in the order after the dragged child was exchanged
  /// with [collision].
  List<ReorderableEntity> _getOrderAfterExchange(ReorderableEntity collision) {
    return [
      for (final entity in _getOrderedEntities())
        if (entity.key == collision.key)
          draggedEntity!
        else if (entity.key == draggedEntity!.key)
          collision
        else
          entity,
    ];
  }

  /// Returns the offsets of [orderedEntities] laid out by [renderWrap].
  ///
  /// The offsets are in the same coordinates as [ReorderableEntity.updatedOffset].
  List<Offset> _calculateOffsets(
    List<ReorderableEntity> orderedEntities,
    RenderWrap renderWrap,
  ) {
    final wrapOffset = _getWrapOffset();
    final offsets = calculateWrapOffsets(
      sizes: [for (final entity in orderedEntities) entity.size],
      maxWidth: renderWrap.constraints.maxWidth,
      spacing: renderWrap.spacing,
      runSpacing: renderWrap.runSpacing,
    );
    return [for (final offset in offsets) wrapOffset + offset];
  }

  /// Returns the rendered [Wrap] of [wrapKey].
  ///
  /// Returns null if the [Wrap] isn't rendered.
  RenderWrap? _getRenderWrap() {
    final renderWrap = wrapKey.currentContext?.findRenderObject();
    assert(
      renderWrap is RenderWrap,
      'The builder of ReorderableBuilder.wrap has to return a Wrap.',
    );
    if (renderWrap is! RenderWrap) return null;

    assert(
      _isDefaultWrapLayout(renderWrap),
      'ReorderableBuilder.wrap only supports the default layout of Wrap, '
      'only spacing and runSpacing can be changed.',
    );
    return renderWrap;
  }

  /// Checks if [renderWrap] uses the layout supported by [calculateWrapOffsets].
  // ponytail: only the default Wrap layout, extend calculateWrapOffsets
  // to support other alignments and directions
  bool _isDefaultWrapLayout(RenderWrap renderWrap) =>
      renderWrap.direction == Axis.horizontal &&
      renderWrap.alignment == WrapAlignment.start &&
      renderWrap.runAlignment == WrapAlignment.start &&
      renderWrap.crossAxisAlignment == WrapCrossAlignment.start &&
      renderWrap.textDirection != TextDirection.rtl &&
      renderWrap.verticalDirection == VerticalDirection.down;

  /// Returns the top left position of the [Wrap].
  ///
  /// The original offsets don't change while dragging. With the default
  /// [Wrap] layout, every run starts at the left and the first run at the top.
  Offset _getWrapOffset() {
    final originalOffsets = childrenKeyMap.values.map((e) => e.originalOffset);
    return Offset(
      originalOffsets.map((offset) => offset.dx).reduce(min),
      originalOffsets.map((offset) => offset.dy).reduce(min),
    );
  }

  /// Replaces the entity in both maps and in [draggedEntity] if it's dragged.
  void _updateEntity(ReorderableEntity entity) {
    childrenKeyMap[entity.key.value] = entity;
    childrenOrderMap[entity.updatedOrderId] = entity;
    if (entity.key == draggedEntity?.key) {
      draggedEntity = entity;
    }
  }
}
