import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_view_type.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';

/// Todo: Hier müssen GridViews/Wrap benutzt werden, die die children animieren, wenn eines dazu kommt oder verschwindet
class ReorderableGridView extends StatelessWidget {
  late final GridViewType _reorderableType;

  final List<Widget> children;
  final ReorderCallback onReorder;
  final List<int> lockedIndices;
  final bool enableAnimation;
  final bool enableLongPress;
  final Duration longPressDelay;
  final bool enableDraggable;

  final EdgeInsets padding;
  final Clip clipBehavior;

  // GridView
  late final SliverGridDelegate? gridDelegate;

  // GridView.count
  late final int? crossAxisCount;
  late final double? mainAxisSpacing;
  late final double? crossAxisSpacing;

  // GridView.extent
  late final double? maxCrossAxisExtent;
  late final double? childAspectRatio;

  final ScrollPhysics? physics;
  final BoxDecoration? dragChildBoxDecoration;

  ReorderableGridView({
    required this.children,
    required this.onReorder,
    required this.gridDelegate,
    this.lockedIndices = const [],
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    this.dragChildBoxDecoration,
    Key? key,
  }) : super(key: key) {
    _reorderableType = GridViewType.gridView;
  }

  ReorderableGridView.count({
    required this.children,
    required this.onReorder,
    required this.crossAxisCount,
    this.lockedIndices = const [],
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    this.dragChildBoxDecoration,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    Key? key,
  }) : super(key: key) {
    _reorderableType = GridViewType.gridViewCount;
  }

  ReorderableGridView.extent({
    required this.children,
    required this.onReorder,
    required this.maxCrossAxisExtent,
    this.lockedIndices = const [],
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    this.dragChildBoxDecoration,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    Key? key,
  }) : super(key: key) {
    _reorderableType = GridViewType.gridViewExtent;
  }

  ReorderableGridView.builder({
    required this.children,
    required this.onReorder,
    required this.gridDelegate,
    this.lockedIndices = const [],
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    this.dragChildBoxDecoration,
    Key? key,
  }) : super(key: key) {
    _reorderableType = GridViewType.gridViewBuilder;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableBuilder(
      children: children,
      onReorder: onReorder,
      lockedIndices: lockedIndices,
      enableAnimation: enableAnimation,
      enableLongPress: enableLongPress,
      longPressDelay: longPressDelay,
      enableDraggable: enableDraggable,
      dragChildBoxDecoration: dragChildBoxDecoration,
      builder: (draggableChildren, scrollController) {
        switch (_reorderableType) {
          case GridViewType.gridView:
            return GridView(
              controller: scrollController,
              children: draggableChildren,
              physics: physics,
              padding: padding,
              gridDelegate: gridDelegate!,
              clipBehavior: clipBehavior,
            );
          case GridViewType.gridViewCount:
            return GridView.count(
              controller: scrollController,
              physics: physics,
              children: draggableChildren,
              crossAxisCount: crossAxisCount!,
              mainAxisSpacing: mainAxisSpacing!,
              crossAxisSpacing: crossAxisSpacing!,
              clipBehavior: clipBehavior,
              padding: padding,
            );
          case GridViewType.gridViewExtent:
            return GridView.extent(
              controller: scrollController,
              children: draggableChildren,
              physics: physics,
              maxCrossAxisExtent: maxCrossAxisExtent!,
              mainAxisSpacing: mainAxisSpacing!,
              crossAxisSpacing: crossAxisSpacing!,
              padding: padding,
              clipBehavior: clipBehavior,
              childAspectRatio: childAspectRatio!,
            );
          case GridViewType.gridViewBuilder:
            return GridView.builder(
              controller: scrollController,
              physics: physics,
              itemCount: draggableChildren.length,
              itemBuilder: (context, index) => draggableChildren[index],
              gridDelegate: gridDelegate!,
              padding: padding,
              clipBehavior: clipBehavior,
            );
        }
      },
    );
  }
}
