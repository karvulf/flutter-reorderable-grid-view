import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/animated_opacity_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/animated_transform_item.dart';

typedef OnCreatedFunction = void Function(
  ReorderableEntity reorderableEntity,
  GlobalKey key,
);

class AnimatedGridViewItem extends StatelessWidget {
  final ReorderableEntity reorderableEntity;

  final OnMovingFinishedCallback onMovingFinished;
  final OnOpacityFinishedCallback onOpacityFinished;

  const AnimatedGridViewItem({
    required this.reorderableEntity,
    required this.onMovingFinished,
    required this.onOpacityFinished,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacityItem(
      reorderableEntity: reorderableEntity,
      onOpacityFinished: onOpacityFinished,
      child: AnimatedTransformItem(
        child: reorderableEntity.child, // new
        isDragging: false, // new
        onMovingFinished: onMovingFinished,
        reorderableEntity: reorderableEntity,
      ),
    );
  }
}
