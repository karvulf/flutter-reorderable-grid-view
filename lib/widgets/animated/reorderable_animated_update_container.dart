import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

typedef OnMovingFinishedCallback = void Function(
  ReorderableEntity reorderableEntity,
  GlobalKey globalKey,
);

/// Handles the animation for the new position of [child] when [isDragging] is false.
///
/// When isBuilding of [reorderableEntity] is true, that means that
/// the current offset is not known. Usually when adding an item to a
/// new position.
///
/// In that case, the [child] is invisible for one frame to prevent a flicker
/// on the new position while animating.
class ReorderableAnimatedUpdatedContainer extends StatefulWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;
  final bool isDragging;

  final OnMovingFinishedCallback onMovingFinished;

  const ReorderableAnimatedUpdatedContainer({
    required this.child,
    required this.reorderableEntity,
    required this.isDragging,
    required this.onMovingFinished,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableAnimatedUpdatedContainer> createState() =>
      _ReorderableAnimatedUpdatedContainerState();
}

class _ReorderableAnimatedUpdatedContainerState
    extends State<ReorderableAnimatedUpdatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  late Animation<Offset> _animationOffset;

  final _globalKey = GlobalKey();

  /// Makes the [child] unvisible.
  ///
  /// Used when the position [child] is not known to prevent flickering
  /// on the new position while animating.
  bool visible = true;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: kThemeAnimationDuration,
      vsync: this,
    );
    _animationOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed && !widget.isDragging) {
            widget.onMovingFinished(
              widget.reorderableEntity,
              _globalKey,
            );
          }
        },
      );

    _handleIsBuilding();
    _updateAnimationTranslation();
  }

  @override
  void didUpdateWidget(
      covariant ReorderableAnimatedUpdatedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    animationController.reset();

    // minimize the flicker when building existing reorderableEntity
    if (widget.reorderableEntity.isBuilding) {
      visible = false;
      _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((timeStamp) {
        visible = true;
      });
    }
    _handleIsBuilding();
    _updateAnimationTranslation();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      maintainAnimation: true,
      maintainSize: true,
      maintainState: true,
      child: Container(
        key: _globalKey,
        transform: widget.isDragging
            ? Matrix4.translationValues(0.0, 0.0, 0.0)
            : Matrix4.translationValues(
                _animationOffset.value.dx,
                _animationOffset.value.dy,
                0,
              ),
        child: widget.child,
      ),
    );
  }

  /// Minimize the flicker when building existing reorderableEntity
  void _handleIsBuilding() {
    if (widget.reorderableEntity.isBuilding) {
      visible = false;
      _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((timeStamp) {
        visible = true;
      });
    }
  }

  /// Starting animation for the new position if dx or dy is not 0.
  void _updateAnimationTranslation() {
    final offsetDiff = _getOffsetDiff(widget.reorderableEntity);
    _animationOffset = _getAnimation(offsetDiff);

    if (offsetDiff.dx != 0 || offsetDiff.dy != 0) {
      animationController.forward();
    }
  }

  /// Calculates the difference of the original and updated offset of [reorderableEntity].
  Offset _getOffsetDiff(ReorderableEntity reorderableEntity) {
    final originalOffset = reorderableEntity.originalOffset;
    final updatedOffset = reorderableEntity.updatedOffset;
    return originalOffset - updatedOffset;
  }

  /// Creating animation for [Offset] of [child].
  ///
  /// If hasSwappedOrder is true, that means, that the updated position
  /// was changed with another position. In that case, the end animation has to be
  /// the new position.
  ///
  /// Otherwise the new position would always be [Offset.zero]. But before
  /// showing the [child] on that position, the animation has to go to that offset.
  /// This is the reason for using [offset] as begin-value in the animation.
  ///
  /// Calling [onMovingFinished] when animation finished and [isDragging] is false.
  Animation<Offset> _getAnimation(Offset offset) {
    late final Tween<Offset> tween;

    if (widget.reorderableEntity.hasSwappedOrder) {
      tween = Tween<Offset>(
        begin: Offset.zero,
        end: -offset,
      );
    } else {
      tween = Tween<Offset>(
        begin: offset,
        end: Offset.zero,
      );
    }
    return tween.animate(animationController);
  }
}

/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
T? _ambiguate<T>(T? value) => value;
