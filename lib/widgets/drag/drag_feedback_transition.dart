import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';

/// Builds [ReorderableAnimationConfig.dragFeedback] around [child].
///
/// Used for lifting the drag feedback and for lowering the released child.
/// Without a builder, [child] is scaled by [feedbackScaleFactor].
class DragFeedbackTransition extends StatelessWidget {
  final ReorderableAnimationConfig animationConfig;

  /// Scale factor of the default transition (default: 1.05).
  final double? feedbackScaleFactor;

  /// Runs from 0 (resting) to 1 (lifted).
  final Animation<double> animation;

  final Widget child;

  const DragFeedbackTransition({
    required this.animationConfig,
    required this.feedbackScaleFactor,
    required this.animation,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final builder = animationConfig.dragFeedback.builder;
    if (builder != null) return builder(child, animation);

    return ScaleTransition(
      scale: Tween<double>(
        begin: 1.0,
        end: feedbackScaleFactor ?? 1.05,
      ).animate(animation),
      child: child,
    );
  }
}
