import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

/// Responsible for the fade in animation when [child] is created.
class ReorderableAnimatedOpacity extends StatefulWidget {
  /// Entity that contains all information to recognize it as a new widget.
  final ReorderableEntity reorderableEntity;

  /// [child] that could get the fade in animation.
  final Widget child;

  /// Called when the fade in animation was finished.
  ///
  /// [size] is calculated after the fade in and is related to the built [child].
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
    _controller.addStatusListener((status) {
      if (status.isCompleted) {}
    });
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _handleAnimationStarted();
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

  void _handleAnimationStarted() {
    if (widget.reorderableEntity.isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAnimationStarted();
      });
    }
  }

  Duration get _duration {
    final isNew = widget.reorderableEntity.isNew;
    return isNew ? widget.fadeInDuration : Duration.zero;
  }
}
