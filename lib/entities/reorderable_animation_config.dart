class ReorderableAnimationConfig {
  /// Duration for the position change of a child (not during dragging).
  ///
  /// The position can be updated if a child was removed or added.
  /// This duration won't be used for the position changes while dragging.
  ///
  /// Default value: const Duration(milliseconds: 200)
  final Duration _positionChangeDuration;

  /// Duration for item position changes while reordering during a drag.
  ///
  /// When a child is dragged, the other children animate to their temporary
  /// positions using this duration.
  ///
  /// Default value: const Duration(milliseconds: 200)
  final Duration _draggingPositionChangeDuration;

  /// Duration for the position animation when a dragged item was released.
  ///
  /// The duration influences the time of the released dragged item going back
  /// to its new position.
  ///
  /// Default value: const Duration(milliseconds: 150)
  final Duration _releasedItemDuration;

  /// Duration for the fade in animation when a new child was added.
  ///
  /// Default value: const Duration(milliseconds: 500)
  final Duration _fadeInDuration;

  /// Duration of the drag feedback scale animation.
  ///
  /// Default value: const Duration(milliseconds: 150)
  final Duration _dragFeedbackDuration;

  /// Whether animations are enabled.
  final bool enableAnimations;

  const ReorderableAnimationConfig({
    Duration positionChangeDuration = const Duration(milliseconds: 200),
    Duration draggingPositionChangeDuration = const Duration(milliseconds: 200),
    Duration releasedItemDuration = const Duration(milliseconds: 150),
    Duration fadeInDuration = const Duration(milliseconds: 500),
    Duration dragFeedbackDuration = const Duration(milliseconds: 150),
    this.enableAnimations = true,
  })  : _positionChangeDuration = positionChangeDuration,
        _draggingPositionChangeDuration = draggingPositionChangeDuration,
        _releasedItemDuration = releasedItemDuration,
        _fadeInDuration = fadeInDuration,
        _dragFeedbackDuration = dragFeedbackDuration;

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
}
