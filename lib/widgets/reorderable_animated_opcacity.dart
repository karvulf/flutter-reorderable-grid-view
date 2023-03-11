import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/definitions.dart';

/// Responsible for the fade in animation when [child] is created.
class ReorderableAnimatedOpacity extends StatefulWidget {
  /// Entity that contains all information to recognize it as a new widget.
  final ReorderableEntity reorderableEntity;

  /// [child] that could get the fade in animation.
  final Widget child;

  /// Called when the fade in animation was finished.
  final ReorderableEntityCallback onOpacityFinished;

  /// Duration for the fade in animation when [child] appears for the first time.
  final Duration fadeInDuration;

  const ReorderableAnimatedOpacity({
    required this.reorderableEntity,
    required this.child,
    required this.onOpacityFinished,
    required this.fadeInDuration,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableAnimatedOpacity> createState() =>
      _ReorderableAnimatedOpacityState();
}

class _ReorderableAnimatedOpacityState
    extends State<ReorderableAnimatedOpacity> {
  /// Value that will be used for the opacity animation.
  late double _opacity;

  @override
  void initState() {
    super.initState();
    _updateOpacity();
  }

  @override
  void didUpdateWidget(covariant ReorderableAnimatedOpacity oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEntity = oldWidget.reorderableEntity;
    final entity = widget.reorderableEntity;

    // that means that the [child] is new and will have a fade in animation
    if (oldEntity.originalOrderId != entity.originalOrderId && entity.isNew) {
      _updateOpacity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: _duration,
      onEnd: _handleAnimationFinished,
      child: widget.child,
    );
  }

  void _handleAnimationFinished() {
    if (widget.reorderableEntity.isNew) {
      // post frame delay is needed to ensure the widget was built
      if (widget.fadeInDuration == Duration.zero) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onOpacityFinished(widget.reorderableEntity);
        });
      } else {
        widget.onOpacityFinished(widget.reorderableEntity);
      }
    }
  }

  /// [Duration] used for the opacity animation.
  Duration get _duration {
    if (widget.reorderableEntity.isNew) {
      return widget.fadeInDuration;
    } else {
      return Duration.zero;
    }
  }

  /// Does the fade in animation with a short delay (two frame callbacks) before starting.
  void _updateOpacity() {
    _opacity = 0.0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // this prevents the flickering before updating the position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _opacity = 1.0;
          });
        }
      });
    });
  }
}
