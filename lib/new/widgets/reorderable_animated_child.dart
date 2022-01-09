import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/new/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/new/widgets/reorderable_draggable.dart';

class ReorderableAnimatedChild extends StatelessWidget {
  final Widget child;
  final ReorderCallback onReorder;
  final OnCreatedFunction onCreated;
  final OnDragUpdateFunction onDragUpdate;

  final ReorderableEntity? reorderableEntity;

  const ReorderableAnimatedChild({
    required this.child,
    required this.onCreated,
    required this.onDragUpdate,
    required this.onReorder,
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
          onEnd: _handleAnimationEnd,
          child: ReorderableDraggable(
            child: child,
            onCreated: onCreated,
            onDragUpdate: onDragUpdate,
          ),
        ),
      ],
    );
  }

  void _handleAnimationEnd() {
    final reorderableUpdatedEntity =
        reorderableEntity?.reorderableUpdatedEntity;
    final oldIndex = reorderableUpdatedEntity?.oldIndex;
    final newIndex = reorderableUpdatedEntity?.oldIndex;

    if (oldIndex != null && newIndex != null) {
      onReorder(oldIndex, newIndex);
    }
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
