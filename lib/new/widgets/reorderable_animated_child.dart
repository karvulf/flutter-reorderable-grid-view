import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/new/widgets/reorderable_draggable.dart';

class ReorderableAnimatedChild extends StatelessWidget {
  final Widget child;
  final int orderId;
  final Offset? offset;
  final OnCreatedFunction onCreated;
  final OnDragUpdateFunction onDragUpdate;

  const ReorderableAnimatedChild({
    required this.child,
    required this.orderId,
    required this.onCreated,
    required this.onDragUpdate,
    this.offset = Offset.zero,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('offset $offset');
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          left: 0,
          // position?.dx,
          right: 0,
          top: 0,
          // position?.dy,
          bottom: 0,
          child: ReorderableDraggable(
            child: child,
            orderId: orderId,
            onCreated: onCreated,
            onDragUpdate: onDragUpdate,
          ),
        ),
      ],
    );
  }
}
