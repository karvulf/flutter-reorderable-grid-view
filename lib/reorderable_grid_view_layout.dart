import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/reoderable_parameters.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_type.dart';
import 'package:flutter_reorderable_grid_view/reorderable.dart';

abstract class ReorderableGridViewLayout extends StatelessWidget
    implements ReorderableParameters {
  const ReorderableGridViewLayout({
    required this.children,
    required this.reorderableType,
    this.lockedChildren = const [],
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.onUpdate,
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
  final ReoderableOnUpdateFunction? onUpdate;

  final ReorderableType reorderableType;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
