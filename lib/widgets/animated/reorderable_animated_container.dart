import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_dragging_container.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_opacity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_update_container.dart';

/// Building widgets for three different animations.
///
/// Building animation for
///   - opacity when [child] is new
///   - position of [reorderableEntity] if updated and not dragged
///   - position of [reorderableEntity] if updated and dragged
class ReorderableAnimatedContainer extends StatelessWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;
  final bool isDragging;

  final OnMovingFinishedCallback onMovingFinished;
  final OnOpacityFinishedCallback onOpacityFinished;

  const ReorderableAnimatedContainer({
    required this.child,
    required this.reorderableEntity,
    required this.isDragging,
    required this.onMovingFinished,
    required this.onOpacityFinished,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableAnimatedOpacity(
      reorderableEntity: reorderableEntity,
      onOpacityFinished: onOpacityFinished,
      child: ReorderableAnimatedDraggingContainer(
        reorderableEntity: reorderableEntity,
        isDragging: isDragging,
        child: ReorderableAnimatedUpdatedContainer(
          reorderableEntity: reorderableEntity,
          onMovingFinished: onMovingFinished,
          isDragging: isDragging,
          child: child,
        ),
      ),
    );
  }
}
