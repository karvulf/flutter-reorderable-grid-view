import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/reoderable_parameters.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_type.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_wrap_parameters.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable.dart';

class ReorderableWrap extends StatelessWidget
    implements ReorderableParameters, ReorderableWrapParameters {
  @override
  final List<Widget> children;

  @override
  final List<int> lockedChildren;

  @override
  final bool enableAnimation;

  @override
  final bool enableLongPress;

  @override
  final bool enableReorder;

  @override
  final Duration longPressDelay;

  @override
  final ReorderCallback onReorder;

  @override
  final double spacing;

  @override
  final double runSpacing;

  @override
  final ScrollPhysics? physics;

  @override
  final BoxDecoration? dragChildBoxDecoration;

  const ReorderableWrap({
    required this.children,
    required this.onReorder,
    this.lockedChildren = const <int>[],
    this.longPressDelay = kLongPressTimeout,
    this.enableLongPress = true,
    this.enableAnimation = true,
    this.enableReorder = true,
    this.spacing = 8,
    this.runSpacing = 8,
    this.dragChildBoxDecoration,
    this.physics,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Reorderable(
      reorderableType: ReorderableType.wrap,
      children: children,
      spacing: spacing,
      onReorder: onReorder,
      runSpacing: runSpacing,
      enableAnimation: enableAnimation,
      enableLongPress: enableLongPress,
      lockedChildren: lockedChildren,
      longPressDelay: longPressDelay,
      physics: physics,
      dragChildBoxDecoration: dragChildBoxDecoration,
      enableReorder: enableReorder,
    );
  }
}
