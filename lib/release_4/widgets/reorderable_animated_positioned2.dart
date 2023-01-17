import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/release_4/widgets/reorderable_animated_positioned.dart';

class ReorderableAnimatedPositioned2 extends StatefulWidget {
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
  State<ReorderableAnimatedPositioned2> createState() =>
      _ReorderableAnimatedPositioned2State();
}

class _ReorderableAnimatedPositioned2State
    extends State<ReorderableAnimatedPositioned2> {
  @override
  Widget build(BuildContext context) {
    final offset = this.offset;
    final changedPosition = widget.reorderableEntity.originalOrderId !=
        widget.reorderableEntity.updatedOrderId;

    if (widget.isDragging) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        onEnd: () {
          // widget.onMovingFinished(widget.reorderableEntity);
        },
        transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
        child: widget.child,
      );
    } else {
      return ReorderableAnimatedPositioned(
        reorderableEntity: widget.reorderableEntity,
        onMovingFinished: widget.onMovingFinished,
        child: widget.child,
      );
      return AnimatedContainer(
        duration:
            changedPosition ? const Duration(milliseconds: 200) : Duration.zero,
        transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
        child: widget.child,
      );
    }
  }

  Offset get offset {
    if (widget.isDragging) {
      final reorderableEntity = widget.reorderableEntity;
      return reorderableEntity.updatedOffset - reorderableEntity.originalOffset;
    } else {
      return Offset.zero;
    }
  }
}
