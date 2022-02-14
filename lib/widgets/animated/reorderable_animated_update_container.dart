import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

typedef OnMovingFinishedCallback = void Function(int keyHashCode);

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
    ).animate(animationController);
  }

  @override
  void didUpdateWidget(
      covariant ReorderableAnimatedUpdatedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    animationController.reset();

    // minimize the flicker when building
    if (widget.reorderableEntity.isBuilding) {
      visible = false;
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        visible = true;
      });
    }
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

  void _updateAnimationTranslation() {
    final offsetDiff = _getOffsetDiff(widget.reorderableEntity);
    _animationOffset = _getAnimation(offsetDiff);

    if (offsetDiff.dx != 0 || offsetDiff.dy != 0) {
      animationController.forward();
    }
  }

  Offset _getOffsetDiff(ReorderableEntity reorderableEntity) {
    final originalOffset = reorderableEntity.originalOffset;
    final updatedOffset = reorderableEntity.updatedOffset;
    return originalOffset - updatedOffset;
  }

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
    return tween.animate(animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !widget.isDragging) {
          widget.onMovingFinished(widget.reorderableEntity.keyHashCode);
        }
      });
  }
}
