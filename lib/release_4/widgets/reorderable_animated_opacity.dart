import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';

typedef OnOpacityFinishedCallback = void Function(Key key);
typedef OnOpacityResetCallback = void Function(
  ReorderableEntity reorderableEntity,
);

/// Fading in [child] with an animated opacity.
///
/// The fade in is only made when isNew in [reorderableEntity] is true.
class ReorderableAnimatedOpacity extends StatefulWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;

  final OnOpacityResetCallback onOpacityFinished;

  const ReorderableAnimatedOpacity({
    required this.child,
    required this.reorderableEntity,
    required this.onOpacityFinished,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableAnimatedOpacity> createState() =>
      _ReorderableAnimatedOpacityState();
}

class _ReorderableAnimatedOpacityState extends State<ReorderableAnimatedOpacity>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Animation<double>? _opacityAnimation;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _checkOpacityAnimation();
  }

  @override
  void didUpdateWidget(covariant ReorderableAnimatedOpacity oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEntity = oldWidget.reorderableEntity;
    final newEntity = widget.reorderableEntity;
    if (oldEntity.isBuildingOffset && !newEntity.isBuildingOffset) {
      _checkOpacityAnimation();
    } else if (oldEntity.originalOrderId != ReorderableEntity.isNewChildId &&
        newEntity.originalOrderId == ReorderableEntity.isNewChildId) {
      _checkOpacityAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = _opacityAnimation?.value ?? this.opacity;
    print('build $opacity ${widget.reorderableEntity.key}');
    return Opacity(
      opacity: 1.0, // opacity,
      child: widget.child,
    );
  }

  Future<void> _checkOpacityAnimation() async {
    final reorderableEntity = widget.reorderableEntity;

    if (reorderableEntity.originalOrderId == ReorderableEntity.isNewChildId) {
      if (!reorderableEntity.isBuildingOffset) {
        _animationController.reset();
        _updateOpacityAnimation(begin: 0, end: 1);
        await _animationController.forward();
        widget.onOpacityFinished(reorderableEntity);
      } else {
        _updateOpacity(opacity: 0.0);
      }
    } else {
      if (!reorderableEntity.isBuildingOffset) {
        _updateOpacity(opacity: 1.0);
      }
    }
  }

  void _updateOpacity({required double opacity}) {
    _animationController.stop();
    this.opacity = opacity;
    _opacityAnimation = null;
  }

  void _updateOpacityAnimation({
    required double begin,
    required double end,
  }) {
    if (!_animationController.isAnimating) {
      _opacityAnimation = Tween<double>(
        begin: begin,
        end: end,
      ).animate(_animationController)
        ..addListener(() {
          setState(() {});
        });
    }
  }
}
