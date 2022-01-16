import 'package:flutter/material.dart';

typedef OnCreatedFunction = Function(
  int hashKey,
  GlobalKey key,
);

typedef OnDragUpdateFunction = Function(
  int hashKey,
  DragUpdateDetails details,
);

class ReorderableDraggable extends StatefulWidget {
  final Widget child;
  final OnCreatedFunction onCreated;
  final OnDragUpdateFunction onDragUpdate;
  final Function(Widget child) onDragStarted;
  final DragEndCallback onDragEnd;

  final Widget? draggedChild;

  const ReorderableDraggable({
    required this.child,
    required this.draggedChild,
    required this.onCreated,
    required this.onDragUpdate,
    required this.onDragStarted,
    required this.onDragEnd,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableDraggable> createState() => _ReorderableDraggableState();
}

class _ReorderableDraggableState extends State<ReorderableDraggable>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  final _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      widget.onCreated(widget.child.key.hashCode, _globalKey);
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      key: _globalKey,
      child: widget.child,
    );

    final feedback = Material(
      color: Colors.transparent,
      child: widget.child,
    );

    final visible = widget.draggedChild == null;

    return LongPressDraggable(
      onDragUpdate: _handleDragUpdate,
      onDragStarted: () {
        widget.onDragStarted(widget.child);
        _controller.forward();
      },
      onDragEnd: _handleDragEnd,
      feedback: feedback,
      childWhenDragging: Visibility(
        visible: visible,
        child: child,
      ),
      child: Visibility(
        visible: visible,
        child: child,
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    widget.onDragUpdate(widget.child.key.hashCode, details);
  }

  void _handleDragEnd(DraggableDetails details) {
    _controller.reset();

    widget.onDragEnd(details);
  }
}
