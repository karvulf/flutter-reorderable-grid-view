import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/animated_grid_view/widgets/animated_grid_view_builder.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_view_type.dart';

class AnimatedGridView extends StatelessWidget {
  late final GridViewType _reorderableType;

  final List<Widget> children;
  final bool enableAnimation;

  final EdgeInsets padding;
  final Clip clipBehavior;
  final bool shrinkWrap;

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

  AnimatedGridView({
    required this.children,
    required this.gridDelegate,
    this.enableAnimation = true,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    this.dragChildBoxDecoration,
    this.shrinkWrap = false,
    Key? key,
  }) : super(key: key) {
    _reorderableType = GridViewType.gridView;
  }

  AnimatedGridView.count({
    required this.children,
    required this.crossAxisCount,
    this.enableAnimation = true,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    this.dragChildBoxDecoration,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.shrinkWrap = false,
    Key? key,
  }) : super(key: key) {
    _reorderableType = GridViewType.gridViewCount;
  }

  AnimatedGridView.extent({
    required this.children,
    required this.maxCrossAxisExtent,
    this.enableAnimation = true,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    this.dragChildBoxDecoration,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = false,
    Key? key,
  }) : super(key: key) {
    _reorderableType = GridViewType.gridViewExtent;
  }

  AnimatedGridView.builder({
    required this.children,
    required this.gridDelegate,
    this.enableAnimation = true,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    this.dragChildBoxDecoration,
    this.shrinkWrap = false,
    Key? key,
  }) : super(key: key) {
    _reorderableType = GridViewType.gridViewBuilder;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGridViewBuilder(
      children: children,
      builder: (draggableChildren, scrollController, contentGlobalKey) {
        switch (_reorderableType) {
          case GridViewType.gridView:
            return GridView(
              key: contentGlobalKey,
              controller: scrollController,
              children: draggableChildren,
              physics: physics,
              padding: padding,
              gridDelegate: gridDelegate!,
              clipBehavior: clipBehavior,
              shrinkWrap: shrinkWrap,
            );
          case GridViewType.gridViewCount:
            return GridView.count(
              key: contentGlobalKey,
              controller: scrollController,
              physics: physics,
              children: draggableChildren,
              crossAxisCount: crossAxisCount!,
              mainAxisSpacing: mainAxisSpacing!,
              crossAxisSpacing: crossAxisSpacing!,
              clipBehavior: clipBehavior,
              padding: padding,
              shrinkWrap: shrinkWrap,
            );
          case GridViewType.gridViewExtent:
            return GridView.extent(
              key: contentGlobalKey,
              controller: scrollController,
              children: draggableChildren,
              physics: physics,
              maxCrossAxisExtent: maxCrossAxisExtent!,
              mainAxisSpacing: mainAxisSpacing!,
              crossAxisSpacing: crossAxisSpacing!,
              padding: padding,
              clipBehavior: clipBehavior,
              childAspectRatio: childAspectRatio!,
              shrinkWrap: shrinkWrap,
            );
          case GridViewType.gridViewBuilder:
            return GridView.builder(
              key: contentGlobalKey,
              controller: scrollController,
              physics: physics,
              itemCount: draggableChildren.length,
              itemBuilder: (context, index) => draggableChildren[index],
              gridDelegate: gridDelegate!,
              padding: padding,
              clipBehavior: clipBehavior,
              shrinkWrap: shrinkWrap,
            );
        }
      },
    );
  }
}
