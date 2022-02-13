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
  final bool isDragging;

  const ReorderableAnimatedDraggingContainer({
    required this.child,
    required this.reorderableEntity,
    required this.isDragging,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: isDragging
          ? Matrix4.translationValues(-dx, -dy, 0)
          : Matrix4.translationValues(0.0, 0.0, 0.0),
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
