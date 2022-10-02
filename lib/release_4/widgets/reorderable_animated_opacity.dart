import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/release_4/widgets/reorderable_init_child.dart';

typedef OnOpacityFinishedCallback = void Function(Key key);

/// Fading in [child] with an animated opacity.
///
/// The fade in is only made when isNew in [reorderableEntity] is true.
class ReorderableAnimatedOpacity extends StatefulWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;

  final OnCreatedFunction onCreated;

  const ReorderableAnimatedOpacity({
    required this.child,
    required this.reorderableEntity,
    required this.onCreated,
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

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    final tween = Tween<double>(begin: 0, end: 1);
    _opacity = tween.animate(_animationController)
      ..addListener(() {
        setState(() {}); // muss das setState drinnen bleiben?
      });
  }

  @override
  void didUpdateWidget(covariant ReorderableAnimatedOpacity oldWidget) {
    super.didUpdateWidget(oldWidget);

    final reorderableEntity = widget.reorderableEntity;
    final isNew = reorderableEntity.isNew;
    // new widget that got his global key
    if (oldWidget.reorderableEntity.isNew != isNew && !isNew) {
      _animationController.forward();
    }
    // new widget with existing global key
    else if (isNew && reorderableEntity.isBuilding) {
      _animationController.reset();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCreated(null, reorderableEntity);
      });
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
}
