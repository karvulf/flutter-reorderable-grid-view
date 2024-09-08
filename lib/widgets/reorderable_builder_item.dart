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
  final ReturnReorderableEntityCallback onOpacityFinished;

  ///
  /// For [ReorderableAnimatedPositioned]
  ///
  final Duration positionDuration;
  final ReturnReorderableEntityCallback onMovingFinished;

  ///
  /// For [ReorderableInitChild]
  ///
  final ReturnOnCreatedFunction onCreated;

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
  final void Function(
    ReorderableEntity reorderableEntity,
    Offset globalOffset,
  ) onDragEnd;
  final ReorderableEntityCallback onDragCanceled;
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
  late ReorderableEntity _reorderableEntity;

  @override
  void initState() {
    super.initState();
    _reorderableEntity = widget.reorderableEntity;
  }

  @override
  void didUpdateWidget(covariant ReorderableBuilderItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEntity = oldWidget.reorderableEntity;
    final entity = widget.reorderableEntity;

    if (entity != oldEntity && entity != _reorderableEntity) {
      _updateReorderableEntity(widget.reorderableEntity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableAnimatedOpacity(
      reorderableEntity: widget.reorderableEntity,
      fadeInDuration: widget.fadeInDuration,
      onOpacityFinished: (size) {
        _reorderableEntity = _reorderableEntity.copyWith(size: size);
        final updatedEntity = widget.onOpacityFinished(_reorderableEntity);
        _updateReorderableEntity(updatedEntity);
      },
      child: ReorderableAnimatedPositioned(
        reorderableEntity: _reorderableEntity,
        isDragging: widget.currentDraggedEntity != null,
        positionDuration: widget.positionDuration,
        onMovingFinished: () {
          final updatedEntity = widget.onMovingFinished(_reorderableEntity);
          _updateReorderableEntity(updatedEntity);
        },
        child: ReorderableInitChild(
          reorderableEntity: _reorderableEntity,
          onCreated: (globalKey) {
            final updatedEntity = widget.onCreated(
              _reorderableEntity,
              globalKey,
            );
            _updateReorderableEntity(updatedEntity);
          },
          child: ReorderableAnimatedReleasedContainer(
            reorderableEntity: _reorderableEntity,
            releasedReorderableEntity: widget.releasedReorderableEntity,
            scrollOffset: widget.scrollOffset,
            releasedChildDuration: widget.releasedChildDuration,
            child: ReorderableDraggable(
              reorderableEntity: _reorderableEntity,
              enableDraggable: widget.enableDraggable,
              currentDraggedEntity: widget.currentDraggedEntity,
              enableLongPress: widget.enableLongPress,
              longPressDelay: widget.longPressDelay,
              dragChildBoxDecoration: widget.dragChildBoxDecoration,
              onDragStarted: () => widget.onDragStarted(_reorderableEntity),
              onDragEnd: (globalOffset) => widget.onDragEnd(
                _reorderableEntity,
                globalOffset,
              ),
              onDragCanceled: () => widget.onDragCanceled(_reorderableEntity),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  void _updateReorderableEntity(ReorderableEntity reorderableEntity) {
    if (mounted) {
      setState(() {
        _reorderableEntity = reorderableEntity;
      });
    }
  }
}
