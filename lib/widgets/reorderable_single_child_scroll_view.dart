import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated_draggable_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_item.dart';

/// Represents the copied children of a [Wrap] or [GridView] and displays them.
///
/// This widget builts all his children inside a [SingleChildScrollView] and positions
/// all children.
class ReorderableSingleChildScrollView extends StatelessWidget {
  final double height;
  final double width;
  final Clip clipBehavior;
  final ReorderableEntity reorderableEntity;
  final bool enableAnimation;
  final bool enableLongPress;
  final Duration longPressDelay;
  final List<int> lockedChildren;
  final bool willBeRemoved;

  final List<BoxShadow>? dragBoxShadow;
  final ScrollPhysics? physics;
  final OnDragUpdateFunction? onDragUpdate;
  final Function(int id, Key key)? onRemoveItem;

  final Key? sizedBoxKey;

  const ReorderableSingleChildScrollView({
    required this.reorderableEntity,
    required this.height,
    required this.width,
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.lockedChildren = const <int>[],
    this.onDragUpdate,
    this.willBeRemoved = false,
    this.onRemoveItem,
    this.physics,
    this.clipBehavior = Clip.hardEdge,
    this.sizedBoxKey,
    this.dragBoxShadow,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = reorderableEntity.children;
    return SingleChildScrollView(
      physics: physics,
      clipBehavior: clipBehavior,
      child: SizedBox(
        key: sizedBoxKey,
        height: height,
        width: width,
        child: Stack(
          clipBehavior: clipBehavior,
          children: reorderableEntity.idMap.entries
              .map(
                (e) => AnimatedDraggableItem(
                  key: children[e.value.orderId].key,
                  willBeRemoved: willBeRemoved,
                  enableAnimation: enableAnimation,
                  entry: e,
                  enableLongPress: enableLongPress,
                  onDragUpdate: onDragUpdate,
                  longPressDelay: longPressDelay,
                  enabled: !lockedChildren.contains(e.key),
                  onRemoveItem: onRemoveItem,
                  child: children[e.value.orderId],
                  boxShadow: dragBoxShadow,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
