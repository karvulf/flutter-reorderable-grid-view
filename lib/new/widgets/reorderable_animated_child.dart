import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/new/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/new/widgets/reorderable_draggable.dart';

typedef OnAnimationEndFunction = Function(
  int hashKey,
  ReorderableEntity reorderableEntity,
);

class ReorderableAnimatedChild extends StatelessWidget {
  final ReorderableEntity reorderableEntity;
  final DragEndCallback onDragEnd;
  final OnCreatedFunction onCreated;
  final OnDragUpdateFunction onDragUpdate;
  final Function(ReorderableEntity reorderableEntity) onDragStarted;

  final ReorderableEntity? draggedReorderableEntity;

  const ReorderableAnimatedChild({
    required this.reorderableEntity,
    required this.onCreated,
    required this.onDragUpdate,
    required this.onDragStarted,
    required this.onDragEnd,
    this.draggedReorderableEntity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var duration = const Duration(milliseconds: 200);
    if (draggedReorderableEntity == null) {
      duration = Duration.zero;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedPositioned(
          duration: duration,
          left: -dx,
          right: dx,
          top: -dy,
          bottom: dy,
          child: ReorderableDraggable(
            reorderableEntity: reorderableEntity,
            draggedReorderableEntity: draggedReorderableEntity,
            onCreated: onCreated,
            onDragUpdate: onDragUpdate,
            onDragStarted: onDragStarted,
            onDragEnd: onDragEnd,
          ),
        ),
      ],
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
