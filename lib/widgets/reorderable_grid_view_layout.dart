import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/reoderable_parameters.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_grid_view_parameters.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_type.dart';

abstract class ReorderableGridViewLayout extends StatelessWidget
    implements ReorderableParameters, ReorderableGridViewParameters {
  const ReorderableGridViewLayout({
    required this.children,
    required this.reorderableType,
    required this.onReorder,
    this.lockedChildren = const [],
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.mainAxisSpacing = 0.0,
    this.clipBehavior = Clip.hardEdge,
    this.maxCrossAxisExtent = 0.0,
    this.crossAxisSpacing = 0.0,
    this.gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
    ),
    this.childAspectRatio = 1.0,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.crossAxisCount,
    this.padding,
    Key? key,
  }) : super(key: key);

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
  final ReorderCallback onReorder;

  @override
  final ReorderableType reorderableType;

  @override
  final int? crossAxisCount;

  @override
  final double mainAxisSpacing;

  @override
  final ScrollPhysics? physics;

  @override
  final double maxCrossAxisExtent;

  @override
  final Clip clipBehavior;

  @override
  final double crossAxisSpacing;

  @override
  final SliverGridDelegate gridDelegate;

  @override
  final EdgeInsetsGeometry? padding;

  @override
  final double childAspectRatio;

  @override
  Widget build(BuildContext context);
}
