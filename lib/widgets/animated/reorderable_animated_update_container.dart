import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

typedef OnMovingFinishedCallback = void Function(
  ReorderableEntity reorderableEntity,
);

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

  late Animation<double> _animationDx;
  late Animation<double> _animationDy;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: kThemeAnimationDuration,
      vsync: this,
    );
    _animationDx = Tween<double>(begin: 0, end: 0).animate(animationController);
    _animationDy = Tween<double>(begin: 0, end: 0).animate(animationController);
  }

  @override
  void didUpdateWidget(
      covariant ReorderableAnimatedUpdatedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    animationController.reset();
    _updateAnimationTranslation();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      transform: widget.isDragging
          ? Matrix4.translationValues(0.0, 0.0, 0.0)
          : Matrix4.translationValues(
              _animationDx.value,
              _animationDy.value,
              0,
            ),
      child: widget.child,
    );
  }

  void _updateAnimationTranslation() {
    final offsetDiff = _getOffsetDiff(widget.reorderableEntity);
    _animationDx = _getAnimation(offsetDiff.dx * -1);
    _animationDy = _getAnimation(offsetDiff.dy * -1);

    if (offsetDiff.dx != 0 || offsetDiff.dy != 0) {
      animationController.forward();
    }
  }

  Offset _getOffsetDiff(ReorderableEntity reorderableEntity) {
    final originalOffset = reorderableEntity.originalOffset;
    final updatedOffset = reorderableEntity.updatedOffset;
    return originalOffset - updatedOffset;
  }

  Animation<double> _getAnimation(double value) {
    return Tween<double>(
      begin: -value,
      end: 0,
    ).animate(animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !widget.isDragging) {
          widget.onMovingFinished(widget.reorderableEntity);
        }
      });
  }
}
