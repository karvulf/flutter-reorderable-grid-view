import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/definitions.dart';

/// Responsible for the fade in animation when [child] is created.
class ReorderableAnimatedOpacity extends StatefulWidget {
  /// Entity that contains all information to recognize it as a new widget.
  final ReorderableEntity reorderableEntity;

  ///
  final ReorderableBuilderCallback builder;

  /// Called when the fade in animation was finished.
  final ReorderableEntityCallback2 onOpacityFinished;

  /// Duration for the fade in animation when [child] appears for the first time.
  final Duration fadeInDuration;

  const ReorderableAnimatedOpacity({
    required this.reorderableEntity,
    required this.builder,
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
  late final _globalKey = GlobalKey();
  late ReorderableEntity _reorderableEntity;

  @override
  void initState() {
    super.initState();
    _reorderableEntity = widget.reorderableEntity;
    _updateOpacity();
  }

  @override
  void didUpdateWidget(covariant ReorderableAnimatedOpacity oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEntity = oldWidget.reorderableEntity;
    final entity = widget.reorderableEntity;

    if (entity != oldEntity) {
      setState(() {
        _reorderableEntity = widget.reorderableEntity;
      });
    }

    // that means that the [child] is new and will have a fade in animation
    if (oldEntity.originalOrderId != entity.originalOrderId && entity.isNew) {
      _updateOpacity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      key: _globalKey,
      opacity: _opacity,
      duration: _duration,
      onEnd: _handleAnimationFinished,
      child: widget.builder(_reorderableEntity),
    );
  }

  /// Will call [widget.onOpacityFinished] only when opacity changed to 1.0.
  ///
  /// 1.0 means that the widget appeared. When the animation ends because it
  /// was set to 0.0, then the call shouldn't happen because that would be a
  /// fade out which is not supported currently.
  void _handleAnimationFinished() {
    if (_opacity == 1.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _callOnOpacityFinished();
      });
    }
  }

  void _callOnOpacityFinished() {
    final renderObject = _globalKey.currentContext?.findRenderObject();
    final renderBox = renderObject as RenderBox?;
    final size = renderBox?.size;

    final updatedEntity = widget.onOpacityFinished(
      widget.reorderableEntity.copyWith(size: size),
    );

    if (mounted) {
      setState(() {
        _reorderableEntity = updatedEntity;
      });
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
