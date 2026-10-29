import 'package:flutter/animation.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_item_transition.dart';

export 'package:flutter_reorderable_grid_view/entities/reorderable_item_transition.dart';

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

  /// Animation when a new child was inserted.
  ///
  /// Default value: fade in with const Duration(milliseconds: 500)
  final ReorderableItemTransition? _insert;

  /// Animation when a child was removed.
  ///
  /// With [Duration.zero], removed children disappear immediately.
  ///
  /// Default value: fade out with const Duration(milliseconds: 200)
  final ReorderableItemTransition? _remove;

  /// Animation of the drag feedback when dragging starts.
  ///
  /// The builder is applied on top of the scaling by
  /// [ReorderableBuilder.feedbackScaleFactor].
  ///
  /// Default value: no extra transition with
  /// const Duration(milliseconds: 150)
  final ReorderableItemTransition? _dragFeedback;

  // Deprecated values, only used when the matching transition is null.
  final Duration _fadeInDuration;
  final Curve? _fadeInCurve;
  final Duration _fadeOutDuration;
  final Curve? _fadeOutCurve;
  final Duration _dragFeedbackDuration;
  final Curve? _dragFeedbackCurve;

  /// Whether the other children wait for the remove animation of a child.
  ///
  /// If true, the other children start to move to their new positions halfway
  /// through the [remove] duration. Otherwise they move while the removed
  /// child animates out.
  ///
  /// Default value: false
  final bool changePositionAfterFadeOut;

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
    ReorderableItemTransition? insert,
    ReorderableItemTransition? remove,
    ReorderableItemTransition? dragFeedback,
    @Deprecated('Use insert: ReorderableItemTransition(duration: ...) instead. '
        'Deprecated after v5.8.0.')
    Duration fadeInDuration = const Duration(milliseconds: 500),
    @Deprecated('Use remove: ReorderableItemTransition(duration: ...) instead. '
        'Deprecated after v5.8.0.')
    Duration fadeOutDuration = const Duration(milliseconds: 200),
    @Deprecated(
        'Use dragFeedback: ReorderableItemTransition(duration: ...) instead. '
        'Deprecated after v5.8.0.')
    Duration dragFeedbackDuration = const Duration(milliseconds: 150),
    Curve? positionChangeCurve,
    Curve? draggingPositionChangeCurve,
    Curve? releasedItemCurve,
    @Deprecated('Use insert: ReorderableItemTransition(curve: ...) instead. '
        'Deprecated after v5.8.0.')
    Curve? fadeInCurve,
    @Deprecated('Use remove: ReorderableItemTransition(curve: ...) instead. '
        'Deprecated after v5.8.0.')
    Curve? fadeOutCurve,
    @Deprecated(
        'Use dragFeedback: ReorderableItemTransition(curve: ...) instead. '
        'Deprecated after v5.8.0.')
    Curve? dragFeedbackCurve,
    this.defaultAnimationCurve,
    this.enableAnimations = true,
    this.changePositionAfterFadeOut = false,
  })  : _positionChangeDuration = positionChangeDuration,
        _draggingPositionChangeDuration = draggingPositionChangeDuration,
        _releasedItemDuration = releasedItemDuration,
        _insert = insert,
        _remove = remove,
        _dragFeedback = dragFeedback,
        _fadeInDuration = fadeInDuration,
        _fadeOutDuration = fadeOutDuration,
        _dragFeedbackDuration = dragFeedbackDuration,
        _positionChangeCurve = positionChangeCurve,
        _draggingPositionChangeCurve = draggingPositionChangeCurve,
        _releasedItemCurve = releasedItemCurve,
        _fadeInCurve = fadeInCurve,
        _fadeOutCurve = fadeOutCurve,
        _dragFeedbackCurve = dragFeedbackCurve;

  /// Animation when a new child was inserted.
  ReorderableItemTransition get insert =>
      _insert ??
      ReorderableItemTransition(duration: _fadeInDuration, curve: _fadeInCurve);

  /// Animation when a child was removed.
  ReorderableItemTransition get remove =>
      _remove ??
      ReorderableItemTransition(
        duration: _fadeOutDuration,
        curve: _fadeOutCurve,
      );

  /// Animation of the drag feedback when dragging starts.
  ReorderableItemTransition get dragFeedback =>
      _dragFeedback ??
      ReorderableItemTransition(
        duration: _dragFeedbackDuration,
        curve: _dragFeedbackCurve,
        builder: ReorderableItemTransition.none,
      );

  Duration get positionChangeDuration =>
      enableAnimations ? _positionChangeDuration : Duration.zero;

  Duration get draggingPositionChangeDuration =>
      enableAnimations ? _draggingPositionChangeDuration : Duration.zero;

  Duration get releasedItemDuration =>
      enableAnimations ? _releasedItemDuration : Duration.zero;

  Duration get insertDuration =>
      enableAnimations ? insert.duration : Duration.zero;

  Duration get removeDuration =>
      enableAnimations ? remove.duration : Duration.zero;

  Duration get dragFeedbackDuration =>
      enableAnimations ? dragFeedback.duration : Duration.zero;

  Curve? get positionChangeCurve =>
      _positionChangeCurve ?? defaultAnimationCurve;

  Curve? get draggingPositionChangeCurve =>
      _draggingPositionChangeCurve ?? defaultAnimationCurve;

  Curve? get releasedItemCurve => _releasedItemCurve ?? defaultAnimationCurve;

  Curve? get insertCurve => insert.curve ?? defaultAnimationCurve;

  Curve? get removeCurve => remove.curve ?? defaultAnimationCurve;

  Curve get dragFeedbackCurve =>
      dragFeedback.curve ?? defaultAnimationCurve ?? Curves.linear;

  @Deprecated('Use insertDuration instead. Deprecated after v5.8.0.')
  Duration get fadeInDuration => insertDuration;

  @Deprecated('Use removeDuration instead. Deprecated after v5.8.0.')
  Duration get fadeOutDuration => removeDuration;

  @Deprecated('Use insertCurve instead. Deprecated after v5.8.0.')
  Curve? get fadeInCurve => insertCurve;

  @Deprecated('Use removeCurve instead. Deprecated after v5.8.0.')
  Curve? get fadeOutCurve => removeCurve;
}
