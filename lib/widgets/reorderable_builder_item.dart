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

  /// Contains all info to enable animations and drag and drop.
  final ReorderableEntity reorderableEntity;

  /// Duration for the fade in animation when [child] appears for the first time.
  final Duration fadeInDuration;

  /// Called when the fade in animation was finished.
  ///
  /// Should add updated [ReorderableEntity] with updated size.
  final ReturnReorderableEntityCallback onOpacityFinished;

  ///
  /// For [ReorderableAnimatedPositioned]
  ///

  /// Duration for the position change of [child] (won't be used while dragging!).
  final Duration positionDuration;

  /// Callback for the animation after moving the [child].
  final ReturnReorderableEntityCallback onMovingFinished;

  ///
  /// For [ReorderableInitChild]
  ///

  /// Called when the child in his position is built for the first time.
  final ReturnOnCreatedFunction onCreated;

  ///
  /// For [ReorderableAnimatedReleasedContainer]
  ///

  /// Describes [reorderableEntity] that is released after drag and drop.
  final ReleasedReorderableEntity? releasedReorderableEntity;

  /// Current scrolling offset for vertical and horizontal scrolling.
  final Offset scrollOffset;

  /// [Duration] for the position animation when a dragged child was released.
  final Duration releasedChildDuration;

  ///
  /// For [ReorderableDraggable]
  ///

  /// When disabling draggable, the drag and drop behavior is not working.
  final bool enableDraggable;

  /// Will be assigned after starting to drag.
  final ReorderableEntity? currentDraggedEntity;

  /// The drag of a child will be started with a long press.
  final bool enableLongPress;

  /// Specify the [Duration] for the pressed child before starting the dragging.
  final Duration longPressDelay;

  /// [BoxDecoration] for the child that is dragged around.
  final BoxDecoration? dragChildBoxDecoration;

  /// The scale factor applied to the feedback widget during a drag operation.
  final double feedbackScaleFactor;

  /// Callback when dragging starts.
  final ReorderableEntityCallback onDragStarted;

  /// Callback when the dragged child was released.
  final OnDragEndFunction onDragEnd;

  /// Called after the dragged child was canceled, e.g. deleted.
  final ReorderableEntityCallback onDragCanceled;

  /// The item that will be displayed in the GridView.
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
    required this.dragChildBoxDecoration,
    required this.feedbackScaleFactor,
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
  /// Holding the newest instance of [_reorderableEntity] here.
  ///
  /// The advantage of holding the instance here is a better performance
  /// and control when the entity is updated.
  /// Previously it was added in ReorderableBuilder which caused to rebuild
  /// every child in the GridView.
  /// Now only this widget will be rebuilt after updating the entity e.g.
  /// when the child was created or the position changed after
  /// the drag and drop.
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

    // only updating if the entity is different to the previous one
    // and the current entity is also different otherwise no update required
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
              feedbackScaleFactor: widget.feedbackScaleFactor,
              // all three dragging functions will trigger a setState for all children
              // that's why the single entity won't be updated here because
              // the drag and drop effects much more children
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
