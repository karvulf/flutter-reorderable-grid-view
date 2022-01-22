import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';

/// Todo: Hier müssen GridViews/Wrap benutzt werden, die die children animieren, wenn eines dazu kommt oder verschwindet
class ReorderableWrap extends StatelessWidget {
  final List<Widget> children;
  final ReorderCallback onReorder;
  final List<int> lockedIndices;
  final bool enableAnimation;
  final bool enableLongPress;
  final Duration longPressDelay;
  final bool enableDraggable;

  final EdgeInsets padding;
  final Clip clipBehavior;
  final double spacing;
  final double runSpacing;

  final ScrollPhysics? physics;
  final BoxDecoration? dragChildBoxDecoration;

  const ReorderableWrap({
    required this.children,
    required this.onReorder,
    this.lockedIndices = const [],
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    this.dragChildBoxDecoration,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
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
        return SingleChildScrollView(
          controller: scrollController,
          physics: physics,
          child: Wrap(
            children: draggableChildren,
            spacing: spacing,
            runSpacing: runSpacing,
            clipBehavior: clipBehavior,
          ),
        );
      },
    );
  }
}
