import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/definitions.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_opcacity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_positioned.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_released_container.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_init_child.dart';

class ReorderableBuilderItem extends StatefulWidget {
  ///
  /// For [ReorderableAnimatedOpacity]
  ///

  final ReorderableEntity reorderableEntity;
  final Duration fadeInDuration;
  final ReorderableEntityCallback2 onOpacityFinished;

  ///
  /// For [ReorderableAnimatedPositioned]
  ///
  final Duration positionDuration;
  final ReorderableEntityCallback onMovingFinished;

  ///
  /// For [ReorderableInitChild]
  ///
  final OnCreatedFunction onCreated;

  ///
  /// For [ReorderableAnimatedReleasedContainer]
  ///
  final ReleasedReorderableEntity? releasedReorderableEntity;
  final Offset scrollOffset;
  final Duration releasedChildDuration;

  ///
  /// For [ReorderableDraggable]
  ///
  final bool enableDraggable;
  final ReorderableEntity? currentDraggedEntity;
  final bool enableLongPress;
  final Duration longPressDelay;
  final BoxDecoration? dragChildBoxDecoration;
  final ReorderableEntityCallback onDragStarted;
  final OnDragEndFunction onDragEnd;
  final OnDragCanceledFunction onDragCanceled;
  final Widget child;

  const ReorderableBuilderItem({
    required this.reorderableEntity,
    required this.fadeInDuration,
    required this.onOpacityFinished,
    required this.currentDraggedEntity,
    required this.positionDuration,
    required this.onMovingFinished,
    required this.onCreated,
    required this.releasedReorderableEntity,
    required this.scrollOffset,
    required this.releasedChildDuration,
    required this.enableDraggable,
    required this.enableLongPress,
    required this.longPressDelay,
    this.dragChildBoxDecoration,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onDragCanceled,
    required this.child,
    super.key,
  });

  @override
  State<ReorderableBuilderItem> createState() => _ReorderableBuilderItemState();
}

class _ReorderableBuilderItemState extends State<ReorderableBuilderItem> {
  @override
  Widget build(BuildContext context) {
    return ReorderableAnimatedOpacity(
      reorderableEntity: widget.reorderableEntity,
      fadeInDuration: widget.fadeInDuration,
      onOpacityFinished: widget.onOpacityFinished,
      builder: (reorderableEntity) => ReorderableAnimatedPositioned(
        reorderableEntity: reorderableEntity,
        isDragging: widget.currentDraggedEntity != null,
        positionDuration: widget.positionDuration,
        onMovingFinished: widget.onMovingFinished,
        child: ReorderableInitChild(
          reorderableEntity: reorderableEntity,
          onCreated: widget.onCreated,
          child: ReorderableAnimatedReleasedContainer(
            reorderableEntity: reorderableEntity,
            releasedReorderableEntity: widget.releasedReorderableEntity,
            scrollOffset: widget.scrollOffset,
            releasedChildDuration: widget.releasedChildDuration,
            child: ReorderableDraggable(
              reorderableEntity: reorderableEntity,
              enableDraggable: widget.enableDraggable,
              currentDraggedEntity: widget.currentDraggedEntity,
              enableLongPress: widget.enableLongPress,
              longPressDelay: widget.longPressDelay,
              dragChildBoxDecoration: widget.dragChildBoxDecoration,
              onDragStarted: widget.onDragStarted,
              onDragEnd: widget.onDragEnd,
              onDragCanceled: widget.onDragCanceled,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
