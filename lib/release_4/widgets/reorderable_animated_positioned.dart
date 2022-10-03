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
    extends State<ReorderableAnimatedPositioned>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animateOffset(begin: Offset.zero);
  }

  @override
  void didUpdateWidget(covariant ReorderableAnimatedPositioned oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEntity = oldWidget.reorderableEntity;
    final newEntity = widget.reorderableEntity;
    if (oldEntity.updatedOffset != newEntity.updatedOffset ||
        oldEntity.isBuildingOffset != newEntity.isBuildingOffset) {
      if (!newEntity.isBuildingOffset) {
        _updateOffsetAnimation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(
        _offsetAnimation.value.dx,
        _offsetAnimation.value.dy,
        0.0,
      ),
      child: widget.child,
    );
  }

  void _updateOffsetAnimation() {
    final reorderableEntity = widget.reorderableEntity;

    late Offset offset;
    if (reorderableEntity.originalOrderId == ReorderableEntity.isNewChildId) {
      offset = Offset.zero;
    } else {
      offset =
          reorderableEntity.originalOffset - reorderableEntity.updatedOffset;
    }
    _animateOffset(begin: offset);
  }

  Future<void> _animateOffset({required Offset begin}) async {
    final tween = Tween<Offset>(begin: begin, end: Offset.zero);
    _offsetAnimation = tween.animate(_animationController)
      ..addListener(() {
        setState(() {}); // muss das setState drinnen bleiben?
      });
    await _animationController.forward();

    if (begin != Offset.zero) {
      widget.onMovingFinished(widget.reorderableEntity);
    }
  }
}
