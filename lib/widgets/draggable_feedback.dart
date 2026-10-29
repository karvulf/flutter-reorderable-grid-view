import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/drag_feedback_transition.dart';

class DraggableFeedback extends StatefulWidget {
  final Widget child;
  final Size size;
  final Animation<Decoration> decoration;

  /// Scale factor of the default transition (default: 1.05).
  ///
  /// Ignored if [ReorderableAnimationConfig.dragFeedback] has a builder.
  final double? feedbackScaleFactor;
  final VoidCallback onDeactivate;

  /// Animation settings for the feedback.
  ///
  /// [ReorderableAnimationConfig.dragFeedback] animates the feedback when
  /// dragging starts.
  final ReorderableAnimationConfig animationConfig;

  const DraggableFeedback({
    required this.child,
    required this.size,
    required this.decoration,
    required this.feedbackScaleFactor,
    required this.onDeactivate,
    required this.animationConfig,
    super.key,
  });

  @override
  State<DraggableFeedback> createState() => _DraggableFeedbackState();
}

class _DraggableFeedbackState extends State<DraggableFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.animationConfig.dragFeedback.duration,
  );

  late final CurvedAnimation _animation = CurvedAnimation(
    parent: _controller,
    curve: widget.animationConfig.dragFeedback.curve ?? Curves.linear,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    widget.onDeactivate();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final child = DecoratedBoxTransition(
      position: DecorationPosition.background,
      decoration: widget.decoration,
      child: widget.child,
    );

    return Material(
      color: Colors.transparent, // removes white corners when having shadow
      child: SizedBox.fromSize(
        size: widget.size,
        child: DragFeedbackTransition(
          animationConfig: widget.animationConfig,
          feedbackScaleFactor: widget.feedbackScaleFactor,
          animation: _animation,
          child: child,
        ),
      ),
    );
  }
}
