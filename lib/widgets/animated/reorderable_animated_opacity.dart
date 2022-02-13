import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

typedef OnOpacityFinishedCallback = void Function(
  ReorderableEntity reorderableEntity,
);

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
  _ReorderableAnimatedOpacityState createState() =>
      _ReorderableAnimatedOpacityState();
}

class _ReorderableAnimatedOpacityState extends State<ReorderableAnimatedOpacity>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _updateOpacity();
  }

  @override
  void didUpdateWidget(covariant ReorderableAnimatedOpacity oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animationController.reset();
    _updateOpacity();
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

  void _updateOpacity() {
    var tween = Tween<double>(begin: 1, end: 1);

    if (widget.reorderableEntity.isNew) {
      tween = Tween<double>(begin: 0, end: 1);
    }

    _opacity = tween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onOpacityFinished(widget.reorderableEntity);
        }
      });
    _animationController.forward();
  }
}
