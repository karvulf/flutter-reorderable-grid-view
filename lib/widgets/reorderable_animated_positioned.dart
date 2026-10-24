import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_grid_view/entities/dragging_animation_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

/// Responsible for the animation when the [child] changes his position.
///
/// There are two types of animation when the position changes:
/// - after a drag and drop
/// - when the [child] was just moved to another position
///
/// The drag and drop animation is always showing a position that the [child]
/// still hasn't.
///
/// When the [child] changes his position, then the animation is reversing the
/// new position and animates the way to the new position.
class ReorderableAnimatedPositioned extends StatefulWidget {
  /// [child] that could have changed his position.
  final Widget child;

  /// Contains all information to animate the new position.
  final ReorderableEntity reorderableEntity;

  /// The child that is currently dragged, null if nothing is dragged.
  final ReorderableEntity? draggedEntity;

  /// Visible offsets of all children animated while dragging, by their key.
  ///
  /// Used to continue these animations after releasing the dragged child
  /// because the reordered child can be shown by another widget afterwards.
  final Map<ValueKey, DraggingAnimationEntity> draggingAnimationMap;

  /// Callback for the animation after moving the [child].
  ///
  /// Important: This callback is only fired when the [child] changed
  /// his position. When position change was triggered while drag and drop,
  /// then the callback won't be fired.
  final VoidCallback onMovingFinished;

  final ReorderableAnimationConfig animationConfig;

  const ReorderableAnimatedPositioned({
    required this.child,
    required this.reorderableEntity,
    required this.draggedEntity,
    required this.draggingAnimationMap,
    required this.onMovingFinished,
    required this.animationConfig,
    super.key,
  });

  @override
  State<ReorderableAnimatedPositioned> createState() =>
      _ReorderableAnimatedPositionedState();
}

class _ReorderableAnimatedPositionedState
    extends State<ReorderableAnimatedPositioned>
    with SingleTickerProviderStateMixin {
  /// This controller will be used for the animation when the position changes.
  late final AnimationController _animationController;

  /// Animation value for the position change.
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this)
      ..addListener(() {
        setState(() {});
        _updateDraggingAnimationMap();
      });

    if (_isDragging) {
      _animateDragOffset(begin: Offset.zero, end: Offset.zero);
    } else {
      _animatePositionChange();
    }
  }

  @override
  void didUpdateWidget(covariant ReorderableAnimatedPositioned oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.draggedEntity != null && !_isDragging) {
      _continueAnimationAfterDragging(
        isDraggedChild:
            oldWidget.draggedEntity?.key == widget.reorderableEntity.key,
      );
      return;
    }

    _compareUpdatedReorderableEntity(
      oldEntity: oldWidget.reorderableEntity,
      newEntity: widget.reorderableEntity,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offset = _offsetAnimation.value;
    return Container(
      transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
      child: widget.child,
    );
  }

  /// Compares values of [newEntity] and [oldEntity] to calculate animations for the position.
  ///
  /// There are some criteria before showing an animation:
  /// - updatedOffset has to be different
  /// - isBuildingOffset has to be different
  /// - the key has to be different
  ///
  /// If the criteria is true, then there is a new animation in the position.
  /// The animation approach is different if the position change was triggered
  /// while dragging.
  ///
  /// If the animation change was not triggered while dragging, then the animation
  /// depends on a position change (hasSwappedOrder) or just a new position.
  void _compareUpdatedReorderableEntity({
    required ReorderableEntity oldEntity,
    required ReorderableEntity newEntity,
  }) {
    final hasChanged = oldEntity.updatedOffset != newEntity.updatedOffset ||
        oldEntity.isBuildingOffset != newEntity.isBuildingOffset ||
        oldEntity.key != newEntity.key;
    if (!hasChanged) return;

    // if it is new, this can lead to a wrong position
    if (_isDragging && !newEntity.isNew) {
      _animateDragOffset(
        begin: _offsetAnimation.value,
        end: newEntity.updatedOffset - newEntity.originalOffset,
      );
    } else if (!newEntity.isBuildingOffset) {
      if (newEntity.hasSwappedOrder) {
        // important to prevent flickering for calculating new offsets
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _animatePositionChange();
        });
      } else {
        _animatePositionChange(reset: false);
      }
    }
  }

  /// Continues the running drag animation after the dragged child was released.
  ///
  /// After the release, the children are reordered and rendered at their new
  /// positions, often by another widget than before. Without this, the
  /// remaining part of the drag animation would be lost and the child would
  /// jump to its new position.
  ///
  /// The visible offset of the child is taken from
  /// [ReorderableAnimatedPositioned.draggingAnimationMap] and the remaining
  /// offset is animated with the remaining drag duration.
  void _continueAnimationAfterDragging({required bool isDraggedChild}) {
    final entity = widget.reorderableEntity;

    // the released container is animating the dragged child
    final draggingAnimation =
        isDraggedChild ? null : widget.draggingAnimationMap.remove(entity.key);
    final progress = draggingAnimation?.progress ?? 1.0;
    final config = widget.animationConfig;

    _animate(
      begin: draggingAnimation == null
          ? Offset.zero
          : draggingAnimation.offset - entity.updatedOffset,
      end: Offset.zero,
      duration: config.draggingPositionChangeDuration * (1.0 - progress),
      curve: config.draggingPositionChangeCurve,
    );
  }

  /// Animates the offset while another child is dragged.
  ///
  /// The new offset is still not rendered and will be shown like a preview.
  void _animateDragOffset({required Offset begin, required Offset end}) {
    final config = widget.animationConfig;
    _animate(
      begin: begin,
      end: end,
      duration: config.draggingPositionChangeDuration,
      curve: config.draggingPositionChangeCurve,
    );
  }

  /// Animates from the original offset to the updated offset.
  ///
  /// Only updated children get an animation because a new child comes
  /// with a new position.
  Future<void> _animatePositionChange({bool reset = true}) async {
    final entity = widget.reorderableEntity;
    final begin = entity.isNew
        ? Offset.zero
        : entity.originalOffset - entity.updatedOffset;
    final config = widget.animationConfig;

    await _animate(
      begin: begin,
      end: Offset.zero,
      duration: config.positionChangeDuration,
      curve: config.positionChangeCurve,
      reset: reset,
    );

    // there is no need to call the callback if the widget didn't change his position.
    if (begin != Offset.zero) {
      widget.onMovingFinished();
    }
  }

  /// Starts [_animationController] to animate from [begin] to [end].
  ///
  /// Without [reset], a running animation continues from its current value.
  TickerFuture _animate({
    required Offset begin,
    required Offset end,
    required Duration duration,
    required Curve? curve,
    bool reset = true,
  }) {
    final parent = curve == null
        ? _animationController
        : CurvedAnimation(parent: _animationController, curve: curve);
    _offsetAnimation = Tween<Offset>(begin: begin, end: end).animate(parent);

    _animationController.duration = duration;
    if (reset) _animationController.reset();
    return _animationController.forward();
  }

  /// Saves the visible offset of this child while another child is dragged.
  void _updateDraggingAnimationMap() {
    if (!_isDragging) return;

    final entity = widget.reorderableEntity;
    widget.draggingAnimationMap[entity.key] = DraggingAnimationEntity(
      offset: entity.originalOffset + _offsetAnimation.value,
      progress: _animationController.value,
    );
  }

  /// Indicator to know if the child changed his position while drag and drop.
  bool get _isDragging => widget.draggedEntity != null;
}
