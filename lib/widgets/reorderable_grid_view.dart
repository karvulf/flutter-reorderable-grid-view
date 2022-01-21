import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';

/// Todo: Hier müssen GridViews/Wrap benutzt werden, die die children animieren, wenn eines dazu kommt oder verschwindet
class ReorderableGridView extends StatelessWidget {
  final List<Widget> children;
  final ReorderCallback onReorder;
  final List<int> lockedIndices;
  final bool enableAnimation;
  final bool enableLongPress;
  final Duration longPressDelay;
  final bool enableDraggable;

  final EdgeInsets padding;
  final Clip clipBehavior;

  final BoxDecoration? dragChildBoxDecoration;

  const ReorderableGridView({
    required this.children,
    required this.onReorder,
    this.lockedIndices = const [],
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    this.dragChildBoxDecoration,
    Key? key,
  }) : super(key: key);

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
        /* return GridView(
          // shrinkWrap: true,
          controller: scrollController,
          padding: padding,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 8,
          ),
          clipBehavior: clipBehavior,
          children: draggableChildren,
        );*/
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) => draggableChildren[index],
          itemCount: draggableChildren.length,
          controller: scrollController,
          padding: padding,
          clipBehavior: clipBehavior,
        );
      },
    );
  }
}
