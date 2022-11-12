import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';

class ReorderableAnimatedPositioned extends StatefulWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;
  final bool isDragging;

  final void Function(ReorderableEntity reorderableEntity) onMovingFinished;

  const ReorderableAnimatedPositioned({
    required this.child,
    required this.reorderableEntity,
    required this.isDragging,
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
  Offset? lastOffset;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _updateOffsetAnimation();
  }

  @override
  void didUpdateWidget(covariant ReorderableAnimatedPositioned oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEntity = oldWidget.reorderableEntity;
    final newEntity = widget.reorderableEntity;
    if (oldEntity.updatedOffset != newEntity.updatedOffset ||
        oldEntity.isBuildingOffset != newEntity.isBuildingOffset ||
        oldEntity.key != newEntity.key) {
      if (!newEntity.isBuildingOffset) {
        if (newEntity.hasSwappedOrder) {
          // important to prevent flickering for calculating new offsets
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _animationController.reset();
            _updateOffsetAnimation();
          });
        } else {
          _updateOffsetAnimation();
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('${widget.reorderableEntity.key}: dx ${_offsetAnimation.value.dx}');
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

    var begin = Offset.zero;
    var end = Offset.zero;
    if (!reorderableEntity.isNew) {
      final originalOffset = reorderableEntity.originalOffset;
      final updatedOffset = reorderableEntity.updatedOffset;
      if (widget.isDragging) {
        if (lastOffset != null) {
          begin = lastOffset!;
        }
        end = updatedOffset - originalOffset;
        lastOffset = end;
      } else {
        begin = originalOffset - updatedOffset;
        lastOffset = null;
      }
    }
    _animateOffset(begin: begin, end: end);
  }

  Future<void> _animateOffset({
    required Offset begin,
    required Offset end,
  }) async {
    final tween = Tween<Offset>(begin: begin, end: end);
    _offsetAnimation = tween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    await _animationController.forward();

    if (end != Offset.zero) {
      print('${widget.reorderableEntity} $tween');
      widget.onMovingFinished(widget.reorderableEntity);
    }
  }
}
