import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_type.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_grid_view_layout.dart';

class ReorderableGridView extends ReorderableGridViewLayout {
  const ReorderableGridView({
    required List<Widget> children,
    required ReorderCallback onReorder,
    required SliverGridDelegate gridDelegate,
    List<int> lockedChildren = const [],
    bool enableAnimation = true,
    bool enableLongPress = true,
    Duration longPressDelay = kLongPressTimeout,
    Clip clipBehavior = Clip.none,
    EdgeInsetsGeometry? padding,
    Key? key,
  }) : super(
          key: key,
          children: children,
          onReorder: onReorder,
          reorderableType: ReorderableType.gridView,
          gridDelegate: gridDelegate,
          lockedChildren: lockedChildren,
          enableLongPress: enableLongPress,
          enableAnimation: enableAnimation,
          longPressDelay: longPressDelay,
          clipBehavior: clipBehavior,
          padding: padding,
        );

  const ReorderableGridView.count({
    required List<Widget> children,
    required int crossAxisCount,
    required ReorderCallback onReorder,
    List<int> lockedChildren = const [],
    bool enableAnimation = true,
    bool enableLongPress = true,
    Duration longPressDelay = kLongPressTimeout,
    double mainAxisSpacing = 0.0,
    EdgeInsetsGeometry? padding,
    Clip clipBehavior = Clip.none,
    Key? key,
  }) : super(
          key: key,
          children: children,
          reorderableType: ReorderableType.gridViewCount,
          longPressDelay: longPressDelay,
          enableLongPress: enableLongPress,
          enableAnimation: enableAnimation,
          onReorder: onReorder,
          lockedChildren: lockedChildren,
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          padding: padding,
          clipBehavior: clipBehavior,
        );

  const ReorderableGridView.extent({
    required List<Widget> children,
    required ReorderCallback onReorder,
    required double maxCrossAxisExtent,
    List<int> lockedChildren = const [],
    bool enableAnimation = true,
    bool enableLongPress = true,
    Duration longPressDelay = kLongPressTimeout,
    double mainAxisSpacing = 0.0,
    Clip clipBehavior = Clip.none,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    Key? key,
  }) : super(
          key: key,
          children: children,
          reorderableType: ReorderableType.gridViewExtent,
          longPressDelay: longPressDelay,
          enableLongPress: enableLongPress,
          enableAnimation: enableAnimation,
          onReorder: onReorder,
          lockedChildren: lockedChildren,
          mainAxisSpacing: mainAxisSpacing,
          clipBehavior: clipBehavior,
          maxCrossAxisExtent: maxCrossAxisExtent,
          physics: physics,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
          padding: padding,
        );

  @override
  Widget build(BuildContext context) {
    return Reorderable(
      reorderableType: reorderableType,
      children: children,
      onReorder: onReorder,
      enableAnimation: enableAnimation,
      enableLongPress: enableLongPress,
      lockedChildren: lockedChildren,
      longPressDelay: longPressDelay,
      clipBehavior: clipBehavior,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      physics: physics,
      maxCrossAxisExtent: maxCrossAxisExtent,
      crossAxisCount: crossAxisCount,
      gridDelegate: gridDelegate,
      padding: padding,
      childAspectRatio: childAspectRatio,
    );
  }
}
