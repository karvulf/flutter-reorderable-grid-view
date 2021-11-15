import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_item.dart';

/// This widget acts like a copy of the original child.
///
/// It's possible to disable the animation after changing the position.
/// Also when the child was added or will be removed, it's animated with a
/// fade in or out effect.
class AnimatedDraggableItem extends StatefulWidget {
  static const animationDuration = Duration(milliseconds: 300);

  final Widget child;
  final MapEntry<int, GridItemEntity> entry;
  final bool enableAnimation;
  final bool enableLongPress;

  final bool enabled;
  final Duration longPressDelay;

  final bool willBeRemoved;

  final BoxDecoration? dragBoxDecoration;
  final OnDragUpdateFunction? onDragUpdate;
  final Function(int id, Key key)? onRemoveItem;

  const AnimatedDraggableItem({
    required this.child,
    required this.entry,
    required this.enableAnimation,
    required this.enableLongPress,
    this.enabled = true,
    this.longPressDelay = kLongPressTimeout,
    this.willBeRemoved = false,
    this.dragBoxDecoration,
    this.onDragUpdate,
    this.onRemoveItem,
    Key? key,
  })  : assert(key != null,
            'Key of child was null. You need to add a unique key to the child!'),
        super(key: key);

  @override
  State<AnimatedDraggableItem> createState() => _AnimatedDraggableItemState();
}

class _AnimatedDraggableItemState extends State<AnimatedDraggableItem>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (widget.willBeRemoved) {
      _animation = Tween<double>(begin: 1, end: 0).animate(_controller)
        ..addStatusListener(
          (state) {
            if (state == AnimationStatus.completed) {
              widget.onRemoveItem!(widget.entry.key, widget.child.key!);
            }
          },
        );
    } else {
      _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draggableItem = DraggableItem(
      orderId: widget.entry.value.orderId,
      enableLongPress: widget.enableLongPress,
      onDragUpdate: widget.onDragUpdate,
      longPressDelay: widget.longPressDelay,
      dragBoxDecoration: widget.dragBoxDecoration,
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
        duration: AnimatedDraggableItem.animationDuration,
        top: widget.entry.value.localPosition.dy,
        left: widget.entry.value.localPosition.dx,
        height: widget.entry.value.size.height,
        width: widget.entry.value.size.width,
        curve: Curves.easeInOutSine,
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(_animation),
          child: draggableItem,
        ),
      );
    }
  }
}
