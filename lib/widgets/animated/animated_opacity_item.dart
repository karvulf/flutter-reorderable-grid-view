import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

typedef OnOpacityFinishedCallback = void Function(
  ReorderableEntity reorderableEntity,
);

class AnimatedOpacityItem extends StatefulWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;

  final OnOpacityFinishedCallback onOpacityFinished;

  const AnimatedOpacityItem({
    required this.child,
    required this.reorderableEntity,
    required this.onOpacityFinished,
    Key? key,
  }) : super(key: key);

  @override
  _AnimatedOpacityItemState createState() => _AnimatedOpacityItemState();
}

class _AnimatedOpacityItemState extends State<AnimatedOpacityItem> {
  var opacity = 0.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reorderableEntity.isNew) {
      return AnimatedOpacity(
        opacity: opacity,
        duration: _opacityDuration,
        onEnd: () {
          if (opacity == 1) {
            widget.onOpacityFinished(widget.reorderableEntity);
          }
        },
        child: widget.child,
      );
    } else {
      return widget.child;
    }
  }

  Duration get _opacityDuration {
    return widget.reorderableEntity.isNew
        ? const Duration(milliseconds: 400)
        : Duration.zero;
  }
}
