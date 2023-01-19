import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/definitions.dart';

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
  final ReorderableEntityCallback onMovingFinished;

  const ReorderableAnimatedPositioned({
    required this.child,
    required this.reorderableEntity,
    required this.isDragging,
    required this.onMovingFinished,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableAnimatedPositioned> createState() =>
      _ReorderableAnimatedPositionedState();
}

class _ReorderableAnimatedPositionedState
    extends State<ReorderableAnimatedPositioned>
    with SingleTickerProviderStateMixin {
  /// This controller will be used for the animation when the position changes.
  late AnimationController _animationController;

  /// Animation value for the position change.
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      // Todo: duration zu den parametern hinzufügen
      duration: const Duration(milliseconds: 200),
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
    final oldEntity = oldWidget.reorderableEntity;
    final newEntity = widget.reorderableEntity;
    if (oldEntity.updatedOffset != newEntity.updatedOffset ||
        oldEntity.isBuildingOffset != newEntity.isBuildingOffset ||
        oldEntity.key != newEntity.key) {
      if (widget.isDragging) {
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

  Future<void> _updateDragOffsetAnimation({
    Offset begin = Offset.zero,
    Offset end = Offset.zero,
  }) async {
    final tween = Tween<Offset>(begin: begin, end: end);
    _offsetAnimation = tween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    await _animationController.forward();
  }

  void _updateOffsetAnimation() {
    final reorderableEntity = widget.reorderableEntity;

    var offset = Offset.zero;
    if (!reorderableEntity.isNew) {
      offset =
          reorderableEntity.originalOffset - reorderableEntity.updatedOffset;
    }
    _animateOffset(begin: offset);
  }

  Future<void> _animateOffset({required Offset begin}) async {
    final tween = Tween<Offset>(begin: begin, end: Offset.zero);
    _offsetAnimation = tween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    await _animationController.forward();

    if (begin != Offset.zero) {
      widget.onMovingFinished(widget.reorderableEntity);
    }
  }
}
