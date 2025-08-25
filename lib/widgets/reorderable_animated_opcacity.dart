import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_init_child.dart';

/// Responsible for the fade in animation when [child] is created.
class ReorderableAnimatedOpacity extends StatefulWidget {
  /// Entity that contains all information to recognize it as a new widget.
  final ReorderableEntity reorderableEntity;

  /// [child] that could get the fade in animation.
  final Widget child;

  /// Called when the fade in animation has started for a new child.
  final void Function() onAnimationStarted;

  /// Duration for the fade in animation when [child] appears for the first time.
  final Duration fadeInDuration;

  const ReorderableAnimatedOpacity({
    required this.reorderableEntity,
    required this.child,
    required this.onAnimationStarted,
    required this.fadeInDuration,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableAnimatedOpacity> createState() =>
      _ReorderableAnimatedOpacityState();
}

class _ReorderableAnimatedOpacityState extends State<ReorderableAnimatedOpacity>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _handleAnimationStarted();

    // This post frame callback ensures the child stays invisible while its
    // position is calculated. This prevents flickering when the child appears
    // and moves to its new position.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ReorderableAnimatedOpacity oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEntity = oldWidget.reorderableEntity;
    final entity = widget.reorderableEntity;

    // that means that the [child] is new and will have a fade in animation
    if (oldEntity.key != entity.key && entity.isNew) {
      _restartAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }

  void _restartAnimation() {
    _controller.reset();
    _controller.duration = _duration;
    _controller.forward();
    _handleAnimationStarted();
  }

  /// Called after the animation has started.
  ///
  /// The [widget.onAnimationStarted] callback is only triggered for newly
  /// added children. Since a new child may appear in the position previously
  /// occupied by a different child, it is crucial to verify the `.isNew` flag
  /// to ensure correct behavior.
  ///
  /// Two frame callbacks are utilized to guarantee that the "onCreated"
  /// callback from [ReorderableInitChild] is invoked before
  /// [widget.onAnimationStarted]. However, this approach is not optimal and
  /// should be refined in the future.
  void _handleAnimationStarted() {
    if (widget.reorderableEntity.isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onAnimationStarted();
        });
      });
    }
  }

  /// Returns the animation duration for [widget.child].
  ///
  /// Only newly added children should have a non-zero duration to show the
  /// animation. All other children are still "animated," but since the
  /// animation shouldn't be visible to the user, the duration is set to zero.
  ///
  /// The duration remains important because, without it, [widget.child] would
  /// never appear, as the opacity would stay at 0.
  Duration get _duration {
    final isNew = widget.reorderableEntity.isNew;
    return isNew ? widget.fadeInDuration : Duration.zero;
  }
}
