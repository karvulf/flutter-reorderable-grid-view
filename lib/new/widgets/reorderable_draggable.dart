import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/new/entities/reorderable_entity.dart';

typedef OnCreatedFunction = ReorderableEntity? Function(
  int hashKey,
  GlobalKey key,
);

typedef OnDragUpdateFunction = Function(
  int hashKey,
  DragUpdateDetails details,
);

class ReorderableDraggable extends StatefulWidget {
  final ReorderableEntity reorderableEntity;
  final bool enableLongPress;
  final Duration longPressDelay;
  final bool enableDraggable;

  final OnCreatedFunction onCreated;
  final OnDragUpdateFunction onDragUpdate;
  final Function(ReorderableEntity reorderableEntity) onDragStarted;
  final DragEndCallback onDragEnd;

  final ReorderableEntity? draggedReorderableEntity;

  const ReorderableDraggable({
    required this.reorderableEntity,
    required this.enableLongPress,
    required this.longPressDelay,
    required this.enableDraggable,
    required this.onCreated,
    required this.onDragUpdate,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.draggedReorderableEntity,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableDraggable> createState() => _ReorderableDraggableState();
}

class _ReorderableDraggableState extends State<ReorderableDraggable>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late ReorderableEntity _reorderableEntity;

  final _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final hashKey = _reorderableEntity.child.key.hashCode;
      _reorderableEntity = widget.onCreated(hashKey, _globalKey)!;
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _reorderableEntity = widget.reorderableEntity;
  }

  @override
  void didUpdateWidget(covariant ReorderableDraggable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reorderableEntity != widget.reorderableEntity) {
      setState(() {
        _reorderableEntity = widget.reorderableEntity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reorderableEntityChild = _reorderableEntity.child;
    final child = Container(
      key: _globalKey,
      child: reorderableEntityChild,
    );

    final feedback = Material(
      color: Colors.transparent,
      child: reorderableEntityChild,
    );

    final draggedHashKey = widget.draggedReorderableEntity?.child.key.hashCode;
    final hashKey = reorderableEntityChild.key.hashCode;
    final visible = hashKey != draggedHashKey;

    final childWhenDragging = Visibility(
      visible: visible,
      child: child,
    );

    if (!widget.enableDraggable) {
      return child;
    } else if (widget.enableLongPress) {
      return LongPressDraggable(
        delay: widget.longPressDelay,
        onDragUpdate: _handleDragUpdate,
        onDragStarted: _handleStarted,
        onDragEnd: _handleDragEnd,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: childWhenDragging,
      );
    } else {
      return Draggable(
        onDragUpdate: _handleDragUpdate,
        onDragStarted: _handleStarted,
        onDragEnd: _handleDragEnd,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: childWhenDragging,
      );
    }
  }

  void _handleStarted() {
    widget.onDragStarted(_reorderableEntity);
    _controller.forward();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final hashKey = _reorderableEntity.child.key.hashCode;
    widget.onDragUpdate(hashKey, details);
  }

  void _handleDragEnd(DraggableDetails details) {
    _controller.reset();

    widget.onDragEnd(details);
  }
}
