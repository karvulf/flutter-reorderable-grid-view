import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_type.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_grid_view_layout.dart';

class ReorderableGridView extends ReorderableGridViewLayout {
  const ReorderableGridView.count({
    required List<Widget> children,
    required int crossAxisCount,
    List<int> lockedChildren = const [],
    bool enableAnimation = true,
    bool enableLongPress = true,
    Duration longPressDelay = kLongPressTimeout,
    ReoderableOnUpdateFunction? onUpdate,
    double mainAxisSpacing = 0.0,
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
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
        );

  const ReorderableGridView.extent({
    required List<Widget> children,
    List<int> lockedChildren = const [],
    bool enableAnimation = true,
    bool enableLongPress = true,
    Duration longPressDelay = kLongPressTimeout,
    double mainAxisSpacing = 0,
    Clip clipBehavior = Clip.none,
    bool shrinkWrap = false,
    double maxCrossAxisExtent = 0.0,
    double crossAxisSpacing = 0.0,
    ReoderableOnUpdateFunction? onUpdate,
    ScrollPhysics? physics,
    Key? key,
  }) : super(
          key: key,
          children: children,
          reorderableType: ReorderableType.gridViewExtent,
          longPressDelay: longPressDelay,
          enableLongPress: enableLongPress,
          enableAnimation: enableAnimation,
          onUpdate: onUpdate,
          lockedChildren: lockedChildren,
          mainAxisSpacing: mainAxisSpacing,
          clipBehavior: clipBehavior,
          shrinkWrap: shrinkWrap,
          maxCrossAxisExtent: maxCrossAxisExtent,
          physics: physics,
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
      clipBehavior: clipBehavior,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      physics: physics,
      maxCrossAxisExtent: maxCrossAxisExtent,
      shrinkWrap: shrinkWrap,
      crossAxisCount: crossAxisCount,
    );
  }
}
