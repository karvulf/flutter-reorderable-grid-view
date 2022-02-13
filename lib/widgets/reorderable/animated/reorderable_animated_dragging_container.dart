import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

typedef OnAnimationEndFunction = Function(
  int hashKey,
  ReorderableEntity reorderableEntity,
);

class ReorderableAnimatedDraggingContainer extends StatelessWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;

  const ReorderableAnimatedDraggingContainer({
    required this.child,
    required this.reorderableEntity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var duration = const Duration(milliseconds: 300);

    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(-dx, -dy, 0),
      child: child,
    );
  }

  double get dx {
    final originalOffset = reorderableEntity.originalOffset;
    final updatedOffset = reorderableEntity.updatedOffset;

    return originalOffset.dx - updatedOffset.dx;
  }

  double get dy {
    final originalOffset = reorderableEntity.originalOffset;
    final updatedOffset = reorderableEntity.updatedOffset;

    return originalOffset.dy - updatedOffset.dy;
  }
}
