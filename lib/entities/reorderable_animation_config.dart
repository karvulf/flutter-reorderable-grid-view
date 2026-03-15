class ReorderableAnimationConfig {
  /// Duration for the position change of a child.
  ///
  /// The position can be updated if a child was removed or added.
  /// This duration won't be used for the position changes while dragging.
  ///
  /// Default value: const Duration(milliseconds: 200)
  final Duration _positionDuration;

  /// [Duration] for the position animation when a dragged child was released.
  ///
  /// The duration influence the time of the released dragged child going back
  /// to his new position.
  ///
  /// Default value: const Duration(milliseconds: 150)
  final Duration _releasedChildDuration;

  /// [Duration] for the fade in animation when a new child was added.
  ///
  /// Default value: const Duration(milliseconds: 500)
  final Duration _fadeInDuration;

  /// Duration
  final Duration _feedbackAnimationDuration;

  ///
  final bool enableAnimations;

  const ReorderableAnimationConfig({
    Duration positionDuration = const Duration(milliseconds: 200),
    Duration releasedChildDuration = const Duration(milliseconds: 150),
    Duration fadeInDuration = const Duration(milliseconds: 500),
    Duration feedbackAnimationDuration = const Duration(milliseconds: 150),
    this.enableAnimations = true,
  })  : _positionDuration = positionDuration,
        _releasedChildDuration = releasedChildDuration,
        _fadeInDuration = fadeInDuration,
        _feedbackAnimationDuration = feedbackAnimationDuration;

  Duration get positionDuration =>
      enableAnimations ? _positionDuration : Duration.zero;

  Duration get releasedChildDuration =>
      enableAnimations ? _releasedChildDuration : Duration.zero;

  Duration get fadeInDuration =>
      enableAnimations ? _fadeInDuration : Duration.zero;

  Duration get feedbackAnimationDuration =>
      enableAnimations ? _feedbackAnimationDuration : Duration.zero;
}
