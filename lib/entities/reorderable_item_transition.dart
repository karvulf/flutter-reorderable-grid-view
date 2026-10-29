import 'package:flutter/widgets.dart';

/// Describes how a child animates, e.g. when it is inserted or removed.
///
/// [builder] receives an [Animation] running from 0 to 1 over [duration] with
/// [curve] already applied. For removals the animation runs reversed (1 to 0).
///
/// Use explicit transitions driven by the animation (e.g. [ScaleTransition],
/// [SizeTransition]). Don't use implicit animations or your own controller,
/// the timing is owned by [duration] (removed children are disposed after it).
class ReorderableItemTransition {
  /// Duration of the animation.
  final Duration duration;

  /// Curve of the animation.
  ///
  /// If null, [ReorderableAnimationConfig.defaultAnimationCurve] is used.
  final Curve? curve;

  /// Builds the animated child.
  ///
  /// Default value: [fade]
  final AnimatedSwitcherTransitionBuilder builder;

  const ReorderableItemTransition({
    required this.duration,
    this.curve,
    this.builder = fade,
  });

  /// Fades [child] in or out.
  static Widget fade(Widget child, Animation<double> animation) =>
      FadeTransition(opacity: animation, child: child);

  /// Returns [child] without any transition.
  static Widget none(Widget child, Animation<double> animation) => child;
}
