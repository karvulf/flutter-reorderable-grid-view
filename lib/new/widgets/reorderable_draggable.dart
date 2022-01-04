import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ReorderableDraggable extends StatefulWidget {
  final Widget child;

  const ReorderableDraggable({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableDraggable> createState() => _ReorderableDraggableState();
}

class _ReorderableDraggableState extends State<ReorderableDraggable>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedback = Material(
      color: Colors.transparent,
      child: widget.child,
    );

    return LongPressDraggable(
      onDragUpdate: _handleDragUpdate,
      onDragStarted: _controller.forward,
      onDragEnd: _handleDragEnd,
      feedback: feedback,
      childWhenDragging: Container(),
      child: widget.child,
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {}

  void _handleDragEnd(DraggableDetails details) {
    _controller.reset();
  }
}
