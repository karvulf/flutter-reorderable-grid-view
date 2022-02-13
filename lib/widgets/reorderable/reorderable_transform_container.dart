import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable/animated/reorderable_animated_dragging_container.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable/animated/reorderable_animated_transform_container.dart';

class ReorderableTransformContainer extends StatelessWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;
  final bool isDragging;

  final OnMovingFinishedCallback onMovingFinished;

  const ReorderableTransformContainer({
    required this.child,
    required this.reorderableEntity,
    required this.isDragging,
    required this.onMovingFinished,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableAnimatedDraggingContainer(
      reorderableEntity: reorderableEntity,
      isDragging: isDragging,
      child: ReorderableAnimatedTransformContainer(
        reorderableEntity: reorderableEntity,
        onMovingFinished: onMovingFinished,
        isDragging: isDragging,
        child: child,
      ),
    );
  }
}
