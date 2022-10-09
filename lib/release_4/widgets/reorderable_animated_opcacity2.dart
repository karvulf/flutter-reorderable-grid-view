import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/release_4/widgets/reorderable_animated_opacity.dart';

class ReorderableAnimatedOpacity2 extends StatefulWidget {
  final ReorderableEntity reorderableEntity;
  final Widget child;

  final OnOpacityResetCallback onOpacityFinished;

  const ReorderableAnimatedOpacity2({
    required this.reorderableEntity,
    required this.child,
    required this.onOpacityFinished,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableAnimatedOpacity2> createState() =>
      _ReorderableAnimatedOpacity2State();
}

class _ReorderableAnimatedOpacity2State
    extends State<ReorderableAnimatedOpacity2> {
  late double _opacity;

  @override
  void initState() {
    super.initState();
    print('init state ${widget.reorderableEntity.key}');
    if (widget.reorderableEntity.originalOrderId ==
        ReorderableEntity.isNewChildId) {
      _opacity = 0.0;
    } else {
      _opacity = 1.0;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  void didUpdateWidget(covariant ReorderableAnimatedOpacity2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    /*
    if (oldWidget.reorderableEntity != widget.reorderableEntity) {
      if (widget.reorderableEntity.originalOrderId ==
          ReorderableEntity.isNewChildId) {
        setState(() {
          _opacity = 0.0;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _opacity = 1.0;
          });
        });
      }
    }
  */
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reorderableEntity.originalOrderId !=
        ReorderableEntity.isNewChildId) {
      return widget.child;
    }
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 500),
      onEnd: () {
        widget.onOpacityFinished(widget.reorderableEntity);
      },
      child: widget.child,
    );
  }

  double _getUpdatedOpacity() {
    if (widget.reorderableEntity.originalOrderId ==
        ReorderableEntity.isNewChildId) {
      return 0.0;
    } else {
      return 1.0;
    }
  }
}
