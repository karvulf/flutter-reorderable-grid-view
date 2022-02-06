import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/animated_opacity_child.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/animated_transform_child.dart';

typedef OnCreatedFunction = void Function(
  ReorderableEntity reorderableEntity,
  GlobalKey key,
);

typedef OnMovingFinished = void Function(
  ReorderableEntity reorderableEntity,
);

class AnimatedGridViewChild extends StatefulWidget {
  final ReorderableEntity reorderableEntity;

  final OnCreatedFunction onCreated;
  final OnCreatedFunction onBuilding;
  final OnMovingFinished onMovingFinished;

  const AnimatedGridViewChild({
    required this.reorderableEntity,
    required this.onCreated,
    required this.onBuilding,
    required this.onMovingFinished,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedGridViewChild> createState() => _AnimatedGridViewChildState();
}

class _AnimatedGridViewChildState extends State<AnimatedGridViewChild> {
  final _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      widget.onCreated(
        widget.reorderableEntity,
        _globalKey,
      );
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedGridViewChild oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.reorderableEntity != widget.reorderableEntity) {
      if (widget.reorderableEntity.isBuilding) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          widget.onBuilding(
            widget.reorderableEntity,
            _globalKey,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacityChild(
      child: AnimatedTransformChild(
        key: _globalKey,
        onMovingFinished: widget.onMovingFinished,
        reorderableEntity: widget.reorderableEntity,
      ),
    );
  }
}
