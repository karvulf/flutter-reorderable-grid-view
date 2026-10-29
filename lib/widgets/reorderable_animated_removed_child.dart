import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_grid_view/entities/removed_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';

/// Shows a removed child at its last position and animates it out.
///
/// The animation is built by [ReorderableAnimationConfig.remove].
///
/// Has to be a direct child of a [Stack] because it returns a [Positioned].
/// Calls [onFinished] after the animation.
class ReorderableAnimatedRemovedChild extends StatefulWidget {
  /// Contains the last widget, offset and size of the removed child.
  final RemovedReorderableEntity removedEntity;

  /// Contains the duration, curve and builder for the remove animation.
  final ReorderableAnimationConfig animationConfig;

  /// Used to update the position while scrolling during the fade out.
  final ScrollController? scrollController;

  /// Returns the current scroll offset.
  final ValueGetter<Offset> getScrollOffset;

  /// Called when the fade out was finished.
  final VoidCallback onFinished;

  const ReorderableAnimatedRemovedChild({
    required this.removedEntity,
    required this.animationConfig,
    required this.scrollController,
    required this.getScrollOffset,
    required this.onFinished,
    super.key,
  });

  @override
  State<ReorderableAnimatedRemovedChild> createState() =>
      _ReorderableAnimatedRemovedChildState();
}

class _ReorderableAnimatedRemovedChildState
    extends State<ReorderableAnimatedRemovedChild>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.animationConfig.remove.duration,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenCompleteOrCancel(() {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final removedEntity = widget.removedEntity;
    final curve = widget.animationConfig.remove.curve;
    final Animation<double> animation = curve == null
        ? _controller
        : CurvedAnimation(parent: _controller, curve: curve);

    return ListenableBuilder(
      // without scroll controller, the position is only calculated once
      listenable: Listenable.merge([widget.scrollController]),
      builder: (context, child) {
        final offset = removedEntity.offset - widget.getScrollOffset();
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          width: removedEntity.size.width,
          height: removedEntity.size.height,
          child: child!,
        );
      },
      child: IgnorePointer(
        child: widget.animationConfig.remove.builder(
          removedEntity.child,
          ReverseAnimation(animation),
        ),
      ),
    );
  }
}
