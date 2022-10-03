import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';

class ReorderableAnimatedPositioned extends StatefulWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;

  final void Function(ReorderableEntity reorderableEntity) onMovingFinished;

  const ReorderableAnimatedPositioned({
    required this.child,
    required this.reorderableEntity,
    required this.onMovingFinished,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableAnimatedPositioned> createState() =>
      _ReorderableAnimatedPositionedState();
}

class _ReorderableAnimatedPositionedState
    extends State<ReorderableAnimatedPositioned> {
  @override
  void didUpdateWidget(covariant ReorderableAnimatedPositioned oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final offset = _offset;
    return Container(
      transform: Matrix4.translationValues(
        0, // offset.dx,
        0, // offset.dy,
        0.0,
      ),
      child: widget.child,
    );
  }

  Offset get _offset {
    final reorderableEntity = widget.reorderableEntity;
    return reorderableEntity.originalOffset - reorderableEntity.updatedOffset;
  }
}
