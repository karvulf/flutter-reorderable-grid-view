import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

typedef OnOpacityResetCallback = void Function(
    ReorderableEntity reorderableEntity);

class ReorderableAnimatedOpacity extends StatefulWidget {
  final ReorderableEntity reorderableEntity;
  final Widget child;

  final OnOpacityResetCallback onOpacityFinished;

  const ReorderableAnimatedOpacity({
    required this.reorderableEntity,
    required this.child,
    required this.onOpacityFinished,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableAnimatedOpacity> createState() =>
      _ReorderableAnimatedOpacityState();
}

class _ReorderableAnimatedOpacityState
    extends State<ReorderableAnimatedOpacity> {
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
    if (oldEntity.originalOrderId != entity.originalOrderId && entity.isNew) {
      _updateOpacity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: _duration,
      onEnd: () {
        if (widget.reorderableEntity.isNew) {
          widget.onOpacityFinished(widget.reorderableEntity);
        }
      },
      child: widget.child,
    );
  }

  Duration get _duration {
    if (widget.reorderableEntity.isNew) {
      return const Duration(milliseconds: 500);
    } else {
      return Duration.zero;
    }
  }

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
