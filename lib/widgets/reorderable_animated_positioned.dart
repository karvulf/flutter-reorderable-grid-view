import 'package:flutter/cupertino.dart';
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

  /// Indicator to know if the [child] changed his position while drag and drop.
  final bool isDragging;

  /// Callback for the animation after moving the [child].
  ///
  /// Important: This callback is only fired when the [child] changed
  /// his position. When position change was triggered while drag and drop,
  /// then the callback won't be fired.
  final VoidCallback onMovingFinished;

  /// Duration for the position change of [child] (won't be used while dragging!).
  final Duration positionDuration;

  const ReorderableAnimatedPositioned({
    required this.child,
    required this.reorderableEntity,
    required this.isDragging,
    required this.onMovingFinished,
    required this.positionDuration,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableAnimatedPositioned> createState() =>
      _ReorderableAnimatedPositionedState();
}

class _ReorderableAnimatedPositionedState
    extends State<ReorderableAnimatedPositioned>
    with SingleTickerProviderStateMixin {
  /// Default duration when an item changes his position.
  ///
  /// This duration will be used for position changes while draggong or not
  /// dragging.
  final _defaultAnimationDuration = const Duration(milliseconds: 200);

  /// This controller will be used for the animation when the position changes.
  late AnimationController _animationController;

  /// Animation value for the position change.
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: _defaultAnimationDuration,
      vsync: this,
    );

    if (widget.isDragging) {
      _updateDragOffsetAnimation();
    } else {
      _updateOffsetAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant ReorderableAnimatedPositioned oldWidget) {
    super.didUpdateWidget(oldWidget);

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
    return Container(
      transform: Matrix4.translationValues(
        _offsetAnimation.value.dx,
        _offsetAnimation.value.dy,
        0.0,
      ),
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
    if (oldEntity.updatedOffset != newEntity.updatedOffset ||
        oldEntity.isBuildingOffset != newEntity.isBuildingOffset ||
        oldEntity.key != newEntity.key) {
      // if it is new, this can lead to a wrong position
      if (widget.isDragging && !widget.reorderableEntity.isNew) {
        final currentAnimationValue = _offsetAnimation.value;
        _animationController.reset();
        _updateDragOffsetAnimation(
          begin: currentAnimationValue,
          end: newEntity.updatedOffset - newEntity.originalOffset,
        );
      } else if (!newEntity.isBuildingOffset) {
        if (newEntity.hasSwappedOrder) {
          // important to prevent flickering for calculating new offsets
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _animationController.reset();
            _updateOffsetAnimation();
          });
        } else {
          _updateOffsetAnimation();
        }
      }
    }
  }

  /// Updates [_offsetAnimation] for the position change.
  ///
  /// The new offset is still not rendered and will be shown like a preview.
  Future<void> _updateDragOffsetAnimation({
    Offset begin = Offset.zero,
    Offset end = Offset.zero,
  }) async {
    _animationController.duration = _defaultAnimationDuration;
    final tween = Tween<Offset>(begin: begin, end: end);
    _offsetAnimation = tween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    await _animationController.forward();
  }

  /// Calculates the old offset and animates from this position to the new one.
  ///
  /// The animation depends on the value isNew. Only updated children gets
  /// an animation because a new child comes with a new position.
  void _updateOffsetAnimation() {
    final reorderableEntity = widget.reorderableEntity;

    var offset = Offset.zero;
    if (!reorderableEntity.isNew) {
      offset =
          reorderableEntity.originalOffset - reorderableEntity.updatedOffset;
    }
    _animateOffset(begin: offset);
  }

  /// Helper function to start the animation with [begin].
  ///
  /// Important, this function is only added when [widget.child] updates his
  /// position, not while dragging.
  Future<void> _animateOffset({required Offset begin}) async {
    _animationController.duration = widget.positionDuration;

    final tween = Tween<Offset>(begin: begin, end: Offset.zero);
    _offsetAnimation = tween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    await _animationController.forward();

    // there is no need to call the callback if the widget didn't change his position.
    if (begin != Offset.zero) {
      widget.onMovingFinished();
    }
  }
}
