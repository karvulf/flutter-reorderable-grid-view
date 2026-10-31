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

  /// Key of the child that collided last with the dragged child.
  Key? _lastCollisionKey;

  /// Ignores the child that just swapped with the dragged child.
  ///
  /// After swapping with a child of a different size, the positions are
  /// recalculated and that child can end up under the dragged child again.
  /// Without ignoring it, both would swap back and forth on every move.
  /// The child collides again after the dragged child has left it.
  // ponytail: only remembers the last child, children moving under the
  // dragged child after the recalculation could still swap once more
  @override
  ReorderableEntity? filterCollision(ReorderableEntity? collision) {
    if (collision?.key == _lastCollisionKey) return null;

    _lastCollisionKey = collision?.key;
    return collision;
  }

  @override
  List<ReorderUpdateEntity>? handleDragEnd() {
    _lastCollisionKey = null;
    return super.handleDragEnd();
  }

  @override
  void updatePositionsAfterCollision() {
    final renderWrap = _getRenderWrap();
    if (renderWrap == null) return;

    final entities = childrenKeyMap.values.toList()
      ..sort((a, b) => a.updatedOrderId.compareTo(b.updatedOrderId));
    final offsets = calculateWrapOffsets(
      sizes: [for (final entity in entities) entity.size],
      maxWidth: renderWrap.constraints.maxWidth,
      spacing: renderWrap.spacing,
      runSpacing: renderWrap.runSpacing,
    );
    final wrapOffset = _getWrapOffset();

    for (final (index, entity) in entities.indexed) {
      final updatedOffset = wrapOffset + offsets[index];
      if (updatedOffset == entity.updatedOffset) continue;

      _updateEntity(
        entity.dragUpdated(
          updatedOrderId: entity.updatedOrderId,
          updatedOffset: updatedOffset,
        ),
      );
    }
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
