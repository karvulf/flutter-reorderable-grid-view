import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_type.dart';
import 'package:flutter_reorderable_grid_view/entities/reoderable_parameters.dart';
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
  final Duration longPressDelay;

  @override
  final ReoderableOnUpdateFunction? onUpdate;

  @override
  final double spacing;

  @override
  final double runSpacing;

  const ReorderableWrap({
    required this.children,
    this.lockedChildren = const <int>[],
    this.longPressDelay = kLongPressTimeout,
    this.enableLongPress = true,
    this.enableAnimation = true,
    this.spacing = 8,
    this.runSpacing = 8,
    this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Reorderable(
      reorderableType: ReorderableType.wrap,
      children: children,
      spacing: spacing,
      onUpdate: onUpdate,
      runSpacing: runSpacing,
      enableAnimation: enableAnimation,
      enableLongPress: enableLongPress,
      lockedChildren: lockedChildren,
      longPressDelay: longPressDelay,
    );
  }
}
