import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';

/// Fades out [child] of a removed child and calls [onFinished] afterwards.
class ReorderableAnimatedRemovedChild extends StatefulWidget {
  /// Last widget of the removed child.
  final Widget child;

  /// Contains the duration and curve for the fade out.
  final ReorderableAnimationConfig animationConfig;

  /// Called when the fade out was finished.
  final VoidCallback onFinished;

  const ReorderableAnimatedRemovedChild({
    required this.child,
    required this.animationConfig,
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
    duration: widget.animationConfig.fadeOutDuration,
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
    final curve = widget.animationConfig.fadeOutCurve;
    final Animation<double> animation = curve == null
        ? _controller
        : CurvedAnimation(parent: _controller, curve: curve);

    return IgnorePointer(
      child: FadeTransition(
        opacity: ReverseAnimation(animation),
        child: widget.child,
      ),
    );
  }
}
