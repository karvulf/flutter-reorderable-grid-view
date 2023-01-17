import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/release_4/widgets/reorderable_animated_positioned.dart';

class ReorderableAnimatedPositioned2 extends StatelessWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;
  final bool isDragging;

  final void Function(ReorderableEntity reorderableEntity) onMovingFinished;

  const ReorderableAnimatedPositioned2({
    required this.child,
    required this.reorderableEntity,
    required this.isDragging,
    required this.onMovingFinished,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final offset = this.offset;

    if (isDragging) {
      print('is dragging');
      return AnimatedContainer(
        key: const ValueKey('dragging-animated-container'),
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
        child: child,
      );
    } else {
      print('is NOT dragging');
      return ReorderableAnimatedPositioned(
        key: const ValueKey('not-dragging-animated-container'),
        reorderableEntity: reorderableEntity,
        onMovingFinished: onMovingFinished,
        child: child,
      );
      /*return AnimatedContainer(
        duration:
        changedPosition ? const Duration(milliseconds: 200) : Duration.zero,
        transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
        child: child,
      );
      return ReorderableAnimatedPositioned(
        reorderableEntity: reorderableEntity,
        onMovingFinished: onMovingFinished,
        child: child,
      );
      return AnimatedContainer(
        duration:
            changedPosition ? const Duration(milliseconds: 200) : Duration.zero,
        transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
        child: child,
      );*/
    }
  }

  Offset get offset {
    if (isDragging) {
      return reorderableEntity.updatedOffset - reorderableEntity.originalOffset;
    } else {
      return reorderableEntity.originalOffset - reorderableEntity.updatedOffset;
    }
  }
}
