import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated_draggable_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_item.dart';

class ReorderableSingleChildScrollView extends StatelessWidget {
  final double height;
  final double width;
  final Clip clipBehavior;
  final Map<int, GridItemEntity> childrenIdMap;
  final bool enableAnimation;
  final bool enableLongPress;
  final Duration longPressDelay;
  final List<int> lockedChildren;
  final bool removeWithAnimation;

  final ScrollPhysics? physics;
  final OnDragUpdateFunction? onDragUpdate;
  final Function(int id, Widget child)? onRemovedItem;

  const ReorderableSingleChildScrollView({
    required this.height,
    required this.width,
    required this.clipBehavior,
    required this.childrenIdMap,
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.lockedChildren = const <int>[],
    this.onDragUpdate,
    this.removeWithAnimation = false,
    this.onRemovedItem,
    this.physics,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: physics,
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          clipBehavior: clipBehavior,
          children: childrenIdMap.entries
              .map(
                (e) => AnimatedDraggableItem(
                  key: e.value.key ?? Key(e.key.toString()),
                  removeWithAnimation: removeWithAnimation,
                  enableAnimation: enableAnimation,
                  entry: e,
                  enableLongPress: enableLongPress,
                  onDragUpdate: onDragUpdate,
                  longPressDelay: longPressDelay,
                  enabled: !lockedChildren.contains(e.key),
                  child: e.value.child,
                  onRemovedItem: onRemovedItem,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
