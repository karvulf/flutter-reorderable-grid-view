import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef OnCreatedFunction = Function(
  BuildContext context,
  GlobalKey key,
  int id,
  Widget child,
);

typedef OnDragUpdateFunction = Function(
  int id,
  Offset position,
  Size size,
);

class DraggableItem extends StatefulWidget {
  final Widget child;
  final int id;
  final bool enableLongPress;

  final Duration longPressDelay;
  final bool enabled;

  final OnCreatedFunction? onCreated;
  final OnDragUpdateFunction? onDragUpdate;

  const DraggableItem({
    required this.child,
    required this.id,
    required this.enableLongPress,
    this.longPressDelay = kLongPressTimeout,
    this.enabled = true,
    this.onCreated,
    this.onDragUpdate,
    Key? key,
  }) : super(key: key);

  @override
  State<DraggableItem> createState() => _DraggableItemState();
}

class _DraggableItemState extends State<DraggableItem>
    with TickerProviderStateMixin {
  final _globalKey = GlobalKey();
  final _dragKey = GlobalKey();

  final DecorationTween decorationTween = DecorationTween(
    begin: const BoxDecoration(),
    end: BoxDecoration(
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 5,
          blurRadius: 6,
          offset: const Offset(0, 3), // changes position of shadow
        ),
      ],
      // No shadow.
    ),
  );

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  @override
  void initState() {
    super.initState();

    // called only one time
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.onCreated != null) {
        widget.onCreated!(context, _globalKey, widget.id, widget.child);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      key: _globalKey,
      child: widget.child,
    );

    if (!widget.enabled) {
      return child;
    }

    final feedback = Material(
      key: _dragKey,
      child: DecoratedBoxTransition(
        position: DecorationPosition.background,
        decoration: decorationTween.animate(_controller),
        child: widget.child,
      ),
    );

    if (widget.enableLongPress) {
      return LongPressDraggable(
        delay: widget.longPressDelay,
        onDragUpdate: _handleDragUpdate,
        onDragStarted: _controller.forward,
        onDragEnd: _handleDragEnd,
        feedback: feedback,
        childWhenDragging: Container(),
        child: child,
      );
    } else {
      return Draggable<String>(
        onDragUpdate: _handleDragUpdate,
        onDragStarted: _controller.forward,
        onDragEnd: _handleDragEnd,
        feedback: feedback,
        childWhenDragging: Container(),
        child: child,
      );
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (widget.onDragUpdate != null) {
      // after postFrameCallback dragged object is correctly positioned
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        final renderObject = _dragKey.currentContext?.findRenderObject();
        if (renderObject != null) {
          final box = renderObject as RenderBox;
          final position = box.localToGlobal(Offset.zero);

          widget.onDragUpdate!(widget.id, position, box.size);
          return;
        }
      });
    }
  }

  void _handleDragEnd(DraggableDetails details) {
    _controller.reset();
  }
}
