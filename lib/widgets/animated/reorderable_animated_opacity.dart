import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

typedef OnOpacityFinishedCallback = void Function(Key key);

/// Fading in [child] with an animated opacity.
///
/// The fade in is only made when isNew in [reorderableEntity] is true.
class ReorderableAnimatedOpacity extends StatefulWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;

  final OnOpacityFinishedCallback onOpacityFinished;

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

  late Animation<double> _opacity;

  bool hasStartedAnimation = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 1, end: 1).animate(_animationController);
    _updateOpacity();
  }

  @override
  void didUpdateWidget(covariant ReorderableAnimatedOpacity oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.reorderableEntity != oldWidget.reorderableEntity) {
      _updateOpacity();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacity.value,
      child: widget.child,
    );
  }

  /// Building new animation for [_opacity].
  ///
  /// Animation only starts when [hasStartedAnimation] is false or
  /// when [reorderableEntity] is new.
  void _updateOpacity() {
    var isNew = widget.reorderableEntity.isNew;

    if (hasStartedAnimation || !isNew) return;

    _animationController.reset();
    hasStartedAnimation = true;

    final tween = Tween<double>(begin: 0, end: 1);

    _opacity = tween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          hasStartedAnimation = false;
          widget.onOpacityFinished(widget.reorderableEntity.key);
        }
      });
    _animationController.forward();
  }
}
