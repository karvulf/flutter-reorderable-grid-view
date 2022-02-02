import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/animated_grid_view_builder.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable/reorderable_builder.dart';

class AnimatedReorderableBuilder extends StatelessWidget {
  final List<Widget> children;
  final AnimatedGridViewBuilderFunction builder;

  final List<int> lockedIndices;
  final bool enableAnimation;
  final bool enableLongPress;
  final Duration longPressDelay;
  final bool enableDraggable;

  final ReorderCallback onReorder;

  final ScrollController? scrollController;
  final BoxDecoration? dragChildBoxDecoration;

  const AnimatedReorderableBuilder({
    required this.children,
    required this.onReorder,
    required this.builder,
    this.lockedIndices = const [],
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.dragChildBoxDecoration,
    this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedGridViewBuilder(
      children: children,
      builder: (children, contentGlobalKey, scrollController) {
        return ReorderableBuilder(
          children: children,
          onReorder: onReorder,
          scrollController: scrollController,
          dragChildBoxDecoration: dragChildBoxDecoration,
          longPressDelay: longPressDelay,
          enableAnimation: enableAnimation,
          enableLongPress: enableLongPress,
          enableDraggable: enableDraggable,
          lockedIndices: lockedIndices,
          builder: (children, scrollController) {
            return builder(
              children,
              contentGlobalKey,
              scrollController,
            );
          },
        );
      },
    );
  }
}
