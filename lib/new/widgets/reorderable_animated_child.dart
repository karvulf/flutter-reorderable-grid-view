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
  final OnAnimationEndFunction onAnimationEnd;
  final OnCreatedFunction onCreated;
  final OnDragUpdateFunction onDragUpdate;
  final Function(Widget child) onDragStarted;

  final Widget? draggedChild;

  const ReorderableAnimatedChild({
    required this.reorderableEntity,
    required this.onCreated,
    required this.onDragUpdate,
    required this.onAnimationEnd,
    required this.onDragStarted,
    required this.onDragEnd,
    this.draggedChild,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = reorderableEntity.child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedPositioned(
          duration: reorderableEntity.reorderableUpdatedEntity != null
              ? const Duration(milliseconds: 200)
              : Duration.zero,
          left: 0 - dx,
          right: 0 + dx,
          top: 0 + dy,
          bottom: 0 - dy,
          onEnd: () {
            onAnimationEnd(child.key.hashCode, reorderableEntity);
          },
          child: ReorderableDraggable(
            child: child,
            draggedChild: child.key.hashCode == draggedChild?.key.hashCode
                ? draggedChild
                : null,
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
    final updatedOffset = reorderableEntity.reorderableUpdatedEntity?.offset;

    if (updatedOffset != null) {
      return originalOffset.dx - updatedOffset.dx;
    }
    return 0.0;
  }

  double get dy => 0.0;
}
