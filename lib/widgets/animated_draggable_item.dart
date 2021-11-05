import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_item.dart';

/// This widget acts like a copy of the original child.
///
/// It's possible to disable the animation after changing the position.
class AnimatedDraggableItem extends StatefulWidget {
  final MapEntry<int, GridItemEntity> entry;
  final bool enableAnimation;
  final bool enableLongPress;
  final Widget child;

  final bool enabled;
  final Duration longPressDelay;

  final bool removeWithAnimation;

  final OnDragUpdateFunction? onDragUpdate;
  final Function(int id, Widget child)? onRemovedItem;

  const AnimatedDraggableItem({
    required this.entry,
    required this.enableAnimation,
    required this.enableLongPress,
    required this.child,
    this.enabled = true,
    this.longPressDelay = kLongPressTimeout,
    this.removeWithAnimation = false,
    this.onDragUpdate,
    this.onRemovedItem,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedDraggableItem> createState() => _AnimatedDraggableItemState();
}

class _AnimatedDraggableItemState extends State<AnimatedDraggableItem>
    with SingleTickerProviderStateMixin {
  final animationDuration = const Duration(milliseconds: 300);
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (widget.removeWithAnimation) {
      animation = Tween<double>(begin: 1, end: 0).animate(controller)
        ..addStatusListener(
          (state) {
            widget.onRemovedItem!(widget.entry.key, widget.child);
          },
        );
    } else {
      animation = Tween<double>(begin: 0, end: 1).animate(controller);
    }
    controller.forward();
  }

  @override
  void dispose() {
    Future.delayed(animationDuration, () {
      controller.reverse();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draggableItem = DraggableItem(
      id: widget.entry.key,
      enableLongPress: widget.enableLongPress,
      onDragUpdate: widget.onDragUpdate,
      longPressDelay: widget.longPressDelay,
      enabled: widget.enabled,
      child: SizedBox(
        height: widget.entry.value.size.height,
        width: widget.entry.value.size.width,
        child: widget.child,
      ),
    );

    if (!widget.enableAnimation) {
      return Positioned(
        top: widget.entry.value.localPosition.dy,
        left: widget.entry.value.localPosition.dx,
        height: widget.entry.value.size.height,
        width: widget.entry.value.size.width,
        child: draggableItem,
      );
    } else {
      return AnimatedPositioned(
        duration: animationDuration,
        top: widget.entry.value.localPosition.dy,
        left: widget.entry.value.localPosition.dx,
        height: widget.entry.value.size.height,
        width: widget.entry.value.size.width,
        curve: Curves.easeInOutSine,
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(animation),
          child: draggableItem,
        ),
      );
    }
  }
}
