import 'package:flutter/animation.dart';

class ReorderableAnimationConfig {
  /// Duration for the position change of a child (not during dragging).
  ///
  /// The position can be updated if a child was removed or added.
  /// This duration won't be used for the position changes while dragging.
  ///
  /// Default value: const Duration(milliseconds: 200)
  final Duration _positionChangeDuration;

  /// Curve for [positionChangeDuration].
  ///
  /// If null, [defaultAnimationCurve] is used.
  final Curve? _positionChangeCurve;

  /// Duration for item position changes while reordering during a drag.
  ///
  /// When a child is dragged, the other children animate to their temporary
  /// positions using this duration.
  ///
  /// Default value: const Duration(milliseconds: 200)
  final Duration _draggingPositionChangeDuration;

  /// Curve for [draggingPositionChangeDuration].
  ///
  /// If null, [defaultAnimationCurve] is used.
  final Curve? _draggingPositionChangeCurve;

  /// Duration for the position animation when a dragged item was released.
  ///
  /// The duration influences the time of the released dragged item going back
  /// to its new position.
  ///
  /// Default value: const Duration(milliseconds: 150)
  final Duration _releasedItemDuration;

  /// Curve for [releasedItemDuration].
  ///
  /// If null, [defaultAnimationCurve] is used.
  final Curve? _releasedItemCurve;

  /// Duration for the fade in animation when a new child was added.
  ///
  /// Default value: const Duration(milliseconds: 500)
  final Duration _fadeInDuration;

  /// Curve for [fadeInDuration].
  ///
  /// If null, [defaultAnimationCurve] is used.
  final Curve? _fadeInCurve;

  /// Duration of the drag feedback scale animation.
  ///
  /// Default value: const Duration(milliseconds: 150)
  final Duration _dragFeedbackDuration;

  /// Curve for [dragFeedbackDuration].
  ///
  /// If null, [defaultAnimationCurve] is used.
  final Curve? _dragFeedbackCurve;

  /// Whether animations are enabled.
  final bool enableAnimations;

  /// Global fallback curve for all curve parameters.
  ///
  /// This curve is used when a specific curve is not set.
  final Curve? defaultAnimationCurve;

  const ReorderableAnimationConfig({
    Duration positionChangeDuration = const Duration(milliseconds: 200),
    Duration draggingPositionChangeDuration = const Duration(milliseconds: 200),
    Duration releasedItemDuration = const Duration(milliseconds: 150),
    Duration fadeInDuration = const Duration(milliseconds: 500),
    Duration dragFeedbackDuration = const Duration(milliseconds: 150),
    Curve? positionChangeCurve,
    Curve? draggingPositionChangeCurve,
    Curve? releasedItemCurve,
    Curve? fadeInCurve,
    Curve? dragFeedbackCurve,
    this.defaultAnimationCurve,
    this.enableAnimations = true,
  })  : _positionChangeDuration = positionChangeDuration,
        _draggingPositionChangeDuration = draggingPositionChangeDuration,
        _releasedItemDuration = releasedItemDuration,
        _fadeInDuration = fadeInDuration,
        _dragFeedbackDuration = dragFeedbackDuration,
        _positionChangeCurve = positionChangeCurve,
        _draggingPositionChangeCurve = draggingPositionChangeCurve,
        _releasedItemCurve = releasedItemCurve,
        _fadeInCurve = fadeInCurve,
        _dragFeedbackCurve = dragFeedbackCurve;

  Duration get positionChangeDuration =>
      enableAnimations ? _positionChangeDuration : Duration.zero;

  Duration get draggingPositionChangeDuration =>
      enableAnimations ? _draggingPositionChangeDuration : Duration.zero;

  Duration get releasedItemDuration =>
      enableAnimations ? _releasedItemDuration : Duration.zero;

  Duration get fadeInDuration =>
      enableAnimations ? _fadeInDuration : Duration.zero;

  Duration get dragFeedbackDuration =>
      enableAnimations ? _dragFeedbackDuration : Duration.zero;

  Curve? get positionChangeCurve =>
      _positionChangeCurve ?? defaultAnimationCurve;

  Curve? get draggingPositionChangeCurve =>
      _draggingPositionChangeCurve ?? defaultAnimationCurve;

  Curve? get releasedItemCurve => _releasedItemCurve ?? defaultAnimationCurve;

  Curve? get fadeInCurve => _fadeInCurve ?? defaultAnimationCurve;

  Curve get dragFeedbackCurve =>
      _dragFeedbackCurve ?? defaultAnimationCurve ?? Curves.linear;
}
