import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/new/entities/reorderable_entity.dart';

typedef OnCreatedFunction = Function(
  int hashKey,
  GlobalKey key,
);

typedef OnDragUpdateFunction = Function(
  int hashKey,
  DragUpdateDetails details,
);

class ReorderableDraggable extends StatefulWidget {
  final ReorderableEntity reorderableEntity;
  final OnCreatedFunction onCreated;
  final OnDragUpdateFunction onDragUpdate;
  final Function(ReorderableEntity reorderableEntity) onDragStarted;
  final DragEndCallback onDragEnd;

  final ReorderableEntity? draggedReorderableEntity;

  const ReorderableDraggable({
    required this.reorderableEntity,
    required this.draggedReorderableEntity,
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
      final hashKey = widget.reorderableEntity.child.key.hashCode;
      widget.onCreated(hashKey, _globalKey);
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reorderableEntityChild = widget.reorderableEntity.child;
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

    return LongPressDraggable(
      onDragUpdate: _handleDragUpdate,
      onDragStarted: () {
        widget.onDragStarted(widget.reorderableEntity);
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
    final hashKey = widget.reorderableEntity.child.key.hashCode;
    widget.onDragUpdate(hashKey, details);
  }

  void _handleDragEnd(DraggableDetails details) {
    _controller.reset();

    widget.onDragEnd(details);
  }
}
