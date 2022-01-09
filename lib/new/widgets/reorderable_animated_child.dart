import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/new/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/new/widgets/reorderable_draggable.dart';

typedef OnAnimationEndFunction = Function(
  int hashKey,
  ReorderableEntity reorderableEntity,
);

class ReorderableAnimatedChild extends StatelessWidget {
  final Widget child;
  final OnAnimationEndFunction onAnimationEnd;
  final OnCreatedFunction onCreated;
  final OnDragUpdateFunction onDragUpdate;

  final ReorderableEntity? reorderableEntity;

  const ReorderableAnimatedChild({
    required this.child,
    required this.onCreated,
    required this.onDragUpdate,
    required this.onAnimationEnd,
    this.reorderableEntity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          left: 0 - dx,
          right: 0 + dx,
          top: 0 + dy,
          bottom: 0 - dy,
          onEnd: () {
            if (reorderableEntity != null) {
              onAnimationEnd(child.key.hashCode, reorderableEntity!);
            }
          },
          child: ReorderableDraggable(
            child: child,
            onCreated: onCreated,
            onDragUpdate: onDragUpdate,
          ),
        ),
      ],
    );
  }

  double get dx {
    final originalOffset = reorderableEntity?.originalOffset;
    final updatedOffset = reorderableEntity?.reorderableUpdatedEntity?.offset;

    if (originalOffset != null && updatedOffset != null) {
      return originalOffset.dx - updatedOffset.dx;
    }
    return 0.0;
  }

  double get dy => 0.0;
}
