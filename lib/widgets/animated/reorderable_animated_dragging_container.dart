import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_update_container.dart';

typedef OnAnimationEndFunction = Function(
  int hashKey,
  ReorderableEntity reorderableEntity,
);

/// Handles the animation for the current position of [child] while dragging.
///
/// When dragging the [child], there is another logic for updating the current
/// offset of [child] compared to [ReorderableAnimatedUpdatedContainer].
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
      duration: isDragging ? const Duration(milliseconds: 300) : Duration.zero,
      curve: Curves.easeInOut,
      transform: isDragging
          ? _translationValuesWhileDragging
          : Matrix4.translationValues(0.0, 0.0, 0.0),
      child: child,
    );
  }

  /// Calculates [Matrix4] containing updated offset of [reorderableEntity].
  Matrix4 get _translationValuesWhileDragging {
    final originalOffset = reorderableEntity.originalOffset;
    final updatedOffset = reorderableEntity.updatedOffset;

    final diff = originalOffset - updatedOffset;

    return Matrix4.translationValues(-diff.dx, -diff.dy, 0);
  }
}
