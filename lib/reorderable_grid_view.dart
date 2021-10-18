import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_type.dart';
import 'package:flutter_reorderable_grid_view/reorderable.dart';
import 'package:flutter_reorderable_grid_view/reorderable_grid_view_layout.dart';

class ReorderableGridView extends ReorderableGridViewLayout {
  const ReorderableGridView.count({
    required List<Widget> children,
    List<int> lockedChildren = const [],
    bool enableAnimation = true,
    bool enableLongPress = true,
    Duration longPressDelay = kLongPressTimeout,
    ReoderableOnUpdateFunction? onUpdate,
    Key? key,
  }) : super(
          key: key,
          children: children,
          reorderableType: ReorderableType.gridViewCount,
          longPressDelay: longPressDelay,
          enableLongPress: enableLongPress,
          enableAnimation: enableAnimation,
          onUpdate: onUpdate,
          lockedChildren: lockedChildren,
        );

  @override
  Widget build(BuildContext context) {
    return Reorderable(
      reorderableType: reorderableType,
      children: children,
      onUpdate: onUpdate,
      enableAnimation: enableAnimation,
      enableLongPress: enableLongPress,
      lockedChildren: lockedChildren,
      longPressDelay: longPressDelay,
    );
  }
}
