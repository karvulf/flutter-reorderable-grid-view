import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

class ReorderableAnimatedReleasedContainer extends StatefulWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;
  final double scrollPixels;

  final ReleasedReorderableEntity? releasedReorderableEntity;

  const ReorderableAnimatedReleasedContainer({
    required this.child,
    required this.reorderableEntity,
    required this.scrollPixels,
    required this.releasedReorderableEntity,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableAnimatedReleasedContainer> createState() =>
      _ReorderableAnimatedReleasedContainerState();
}

class _ReorderableAnimatedReleasedContainerState
    extends State<ReorderableAnimatedReleasedContainer>
    with TickerProviderStateMixin {
  late AnimationController _offsetAnimationController;

  Animation<Offset>? _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _offsetAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(
      covariant ReorderableAnimatedReleasedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final releasedReorderableEntity = widget.releasedReorderableEntity;
    if (oldWidget.releasedReorderableEntity != releasedReorderableEntity &&
        releasedReorderableEntity != null &&
        releasedReorderableEntity.reorderableEntity.key ==
            widget.reorderableEntity.key) {
      _handleReleasedReorderableEntity(
        releasedReorderableEntity: releasedReorderableEntity,
      );
    }
  }

  @override
  void dispose() {
    _offsetAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var child = widget.child;

    if (_offsetAnimation != null) {
      child = Container(
        transform: Matrix4.translationValues(
          _offsetAnimation!.value.dx,
          _offsetAnimation!.value.dy,
          0.0,
        ),
        child: child,
      );
    }
    return child;
  }

  /// Called after releasing dragged child.
  Future<void> _handleReleasedReorderableEntity({
    required ReleasedReorderableEntity releasedReorderableEntity,
  }) async {
    final begin = releasedReorderableEntity.dropOffset -
        widget.reorderableEntity.updatedOffset +
        Offset(0.0, widget.scrollPixels);
    final tween = Tween<Offset>(begin: begin, end: Offset.zero);
    _offsetAnimation = tween.animate(_offsetAnimationController)
      ..addListener(() {
        setState(() {});
      });
    await _offsetAnimationController.forward();
    _offsetAnimationController.reset();
    _offsetAnimation = null;
  }
}
