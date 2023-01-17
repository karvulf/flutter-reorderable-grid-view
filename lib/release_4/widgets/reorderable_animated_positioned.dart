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

    var offset = Offset.zero;
    if (!reorderableEntity.isNew) {
      offset =
          reorderableEntity.originalOffset - reorderableEntity.updatedOffset;
    }
    _animateOffset(begin: offset);
  }

  Future<void> _animateOffset({required Offset begin}) async {
    // print('animate with begin $begin');
    final tween = Tween<Offset>(begin: begin, end: Offset.zero);
    _offsetAnimation = tween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    await _animationController.forward();

    if (begin != Offset.zero) {
      widget.onMovingFinished(widget.reorderableEntity);
    }
  }
}
