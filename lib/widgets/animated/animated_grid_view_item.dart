import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/animated_opacity_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/animated_transform_item.dart';

typedef OnCreatedFunction = void Function(
  ReorderableEntity reorderableEntity,
  GlobalKey key,
);

class AnimatedGridViewItem extends StatefulWidget {
  final ReorderableEntity reorderableEntity;

  final OnCreatedFunction onCreated;
  final OnCreatedFunction onBuilding;
  final OnMovingFinishedCallback onMovingFinished;
  final OnOpacityFinishedCallback onOpacityFinished;

  const AnimatedGridViewItem({
    required this.reorderableEntity,
    required this.onCreated,
    required this.onBuilding,
    required this.onMovingFinished,
    required this.onOpacityFinished,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedGridViewItem> createState() => _AnimatedGridViewItemState();
}

class _AnimatedGridViewItemState extends State<AnimatedGridViewItem> {
  final _globalKey = GlobalKey();

  var visible = true;

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
  void didUpdateWidget(covariant AnimatedGridViewItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.reorderableEntity != widget.reorderableEntity) {
      if (widget.reorderableEntity.isBuilding) {
        visible = false;
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          widget.onBuilding(
            widget.reorderableEntity,
            _globalKey,
          );
          visible = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      maintainAnimation: true,
      maintainSize: true,
      maintainState: true,
      child: AnimatedOpacityItem(
        key: _globalKey,
        reorderableEntity: widget.reorderableEntity,
        onOpacityFinished: widget.onOpacityFinished,
        child: AnimatedTransformItem(
          onMovingFinished: widget.onMovingFinished,
          reorderableEntity: widget.reorderableEntity,
        ),
      ),
    );
  }
}
