import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_item.dart';

/// This widget acts like a copy of the original child.
///
/// It's possible to disable the animation after changing the position.
class AnimatedDraggableItem extends StatelessWidget {
  final MapEntry<int, GridItemEntity> entry;
  final Function(
    BuildContext context,
    DragUpdateDetails details,
    int id,
  ) onDragUpdate;
  final bool enableAnimation;
  final bool enableLongPress;
  final bool enabled;
  final Duration longPressDelay;

  const AnimatedDraggableItem({
    required this.entry,
    required this.onDragUpdate,
    required this.enableAnimation,
    required this.enableLongPress,
    this.enabled = true,
    this.longPressDelay = kLongPressTimeout,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final draggableItem = DraggableItem(
      item: entry.value.item,
      id: entry.key,
      enableLongPress: enableLongPress,
      onDragUpdate: onDragUpdate,
      longPressDelay: longPressDelay,
      enabled: enabled,
    );

    if (!enableAnimation) {
      return Positioned(
        top: entry.value.localPosition.dy,
        left: entry.value.localPosition.dx,
        height: entry.value.size.height,
        width: entry.value.size.width,
        child: draggableItem,
      );
    } else {
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        top: entry.value.localPosition.dy,
        left: entry.value.localPosition.dx,
        height: entry.value.size.height,
        width: entry.value.size.width,
        curve: Curves.easeInOutSine,
        child: draggableItem,
      );
    }
  }
}
