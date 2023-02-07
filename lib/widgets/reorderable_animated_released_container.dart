import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

/// Responsible for the animation when releasing [child] after drag and drop.
///
/// When the child was released, this widget enables an animation to animate the
/// child to his new (or old) position. This looks a lot smoother than just
/// bringing the [child] to his new position.
class ReorderableAnimatedReleasedContainer extends StatefulWidget {
  /// [child] will be shown and animated if required.
  final Widget child;

  /// Related to [child] and required for animation purposes.
  final ReorderableEntity reorderableEntity;

  /// Current scrolling value. (Currently only support to y-direction).
  final double scrollPixels;

  /// Describes [reorderableEntity] that is released after drag and drop.
  ///
  /// If this value is not null, it will be checked, if this is related to
  /// [reorderableEntity] and an offset animation could start.
  final ReleasedReorderableEntity? releasedReorderableEntity;

  const ReorderableAnimatedReleasedContainer({
    required this.child,
    required this.reorderableEntity,
    required this.scrollPixels,
    required this.releasedReorderableEntity,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableAnimatedReleasedContainer> createState() =>
      _ReorderableAnimatedReleasedContainerState();
}

class _ReorderableAnimatedReleasedContainerState
    extends State<ReorderableAnimatedReleasedContainer>
    with TickerProviderStateMixin {
  /// Controller for the offset animation.
  late AnimationController _offsetAnimationController;

  /// Animation value to show the offset animation.
  Animation<Offset>? _offsetAnimation;

  @override
  void initState() {
    super.initState();

    // Todo: add duration to parameter of this package
    _offsetAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(
    covariant ReorderableAnimatedReleasedContainer oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    _handleUpdatedWidget(
      oldEntity: oldWidget.releasedReorderableEntity,
      newEntity: widget.releasedReorderableEntity,
    );
  }

  @override
  void dispose() {
    _offsetAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var child = widget.child;

    final offset = _offsetAnimation?.value;

    if (offset != null) {
      return Transform(
        transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
        child: child,
      );
    } else {
      return child;
    }
  }

  /// Checks if [oldEntity] and [newEntity] are different and the same for animation.
  void _handleUpdatedWidget({
    required ReleasedReorderableEntity? oldEntity,
    required ReleasedReorderableEntity? newEntity,
  }) {
    if (oldEntity != newEntity &&
        newEntity != null &&
        newEntity.reorderableEntity.key == widget.reorderableEntity.key) {
      _handleReleasedReorderableEntity(
        releasedReorderableEntity: newEntity,
      );
    }
  }

  /// Animates [widget.child] to his current offset.
  ///
  /// Called after releasing dragged child and animates the way from the
  /// released position to his new position.
  Future<void> _handleReleasedReorderableEntity({
    required ReleasedReorderableEntity releasedReorderableEntity,
  }) async {
    final begin = getBeginOffset(
      releasedReorderableEntity: releasedReorderableEntity,
    );
    final tween = Tween<Offset>(begin: begin, end: Offset.zero);
    _offsetAnimation = tween.animate(_offsetAnimationController)
      ..addListener(() {
        setState(() {});
      });

    await _offsetAnimationController.forward();

    _offsetAnimationController.reset();
    _offsetAnimation = null;
  }

  /// Calculates the offset after releasing the dragged [widget.child].
  ///
  /// The calculated offset depends on the scroll position and should describe
  /// the position when the dragged [widget.child] was released.
  /// Todo: Add support for horizontal scrolling.
  Offset getBeginOffset({
    required ReleasedReorderableEntity releasedReorderableEntity,
  }) {
    return releasedReorderableEntity.dropOffset -
        widget.reorderableEntity.updatedOffset +
        Offset(0.0, widget.scrollPixels);
  }
}
