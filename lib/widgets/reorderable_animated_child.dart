import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_draggable.dart';

typedef OnAnimationEndFunction = Function(
  int hashKey,
  ReorderableEntity reorderableEntity,
);

class ReorderableAnimatedChild extends StatelessWidget {
  final ReorderableEntity reorderableEntity;
  final bool enableAnimation;
  final bool enableLongPress;
  final Duration longPressDelay;
  final bool enableDraggable;

  final DragEndCallback onDragEnd;
  final OnCreatedFunction onCreated;
  final OnDragUpdateFunction onDragUpdate;
  final Function(ReorderableEntity reorderableEntity) onDragStarted;

  final ReorderableEntity? draggedReorderableEntity;
  final BoxDecoration? dragChildBoxDecoration;

  const ReorderableAnimatedChild({
    required this.reorderableEntity,
    required this.enableAnimation,
    required this.enableLongPress,
    required this.longPressDelay,
    required this.enableDraggable,
    required this.onCreated,
    required this.onDragUpdate,
    required this.onDragStarted,
    required this.onDragEnd,
    this.draggedReorderableEntity,
    this.dragChildBoxDecoration,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var duration = const Duration(milliseconds: 300);

    if (!enableAnimation) {
      duration = Duration.zero;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedPositioned(
          duration: duration,
          curve: Curves.easeInOut,
          left: -dx,
          right: dx,
          top: -dy,
          bottom: dy,
          child: ReorderableDraggable(
            reorderableEntity: reorderableEntity,
            enableLongPress: enableLongPress,
            longPressDelay: longPressDelay,
            enableDraggable: enableDraggable,
            onCreated: onCreated,
            onDragUpdate: onDragUpdate,
            onDragStarted: onDragStarted,
            onDragEnd: onDragEnd,
            draggedReorderableEntity: draggedReorderableEntity,
            dragChildBoxDecoration: dragChildBoxDecoration,
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
