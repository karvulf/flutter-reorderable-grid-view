import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

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
  final BoxDecoration? dragChildBoxDecoration;

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
    this.dragChildBoxDecoration,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableDraggable> createState() => _ReorderableDraggableState();
}

class _ReorderableDraggableState extends State<ReorderableDraggable>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final DecorationTween _decorationTween;

  /// Holding instance to get direct access of entity when created
  late ReorderableEntity _reorderableEntity;

  final _globalKey = GlobalKey();
  final _defaultBoxDecoration = BoxDecoration(
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        spreadRadius: 5,
        blurRadius: 6,
        offset: const Offset(0, 3), // changes position of shadow
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _reorderableEntity = widget.reorderableEntity;

    _buildWidget();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    final beginDragBoxDecoration = widget.dragChildBoxDecoration?.copyWith(
      color: Colors.transparent,
      boxShadow: [],
    );
    _decorationTween = DecorationTween(
      begin: beginDragBoxDecoration ?? const BoxDecoration(),
      end: widget.dragChildBoxDecoration ?? _defaultBoxDecoration,
    );
  }

  @override
  void didUpdateWidget(covariant ReorderableDraggable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.reorderableEntity != widget.reorderableEntity) {
      _reorderableEntity = widget.reorderableEntity;

      if (_reorderableEntity.isBuilding) {
        _buildWidget();
      }
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
      child: SizedBox(
        height: _reorderableEntity.size.height,
        width: _reorderableEntity.size.width,
        child: DecoratedBoxTransition(
          position: DecorationPosition.background,
          decoration: _decorationTween.animate(_controller),
          child: reorderableEntityChild,
        ),
      ),
    );

    final draggedHashKey = widget.draggedReorderableEntity?.child.key.hashCode;
    final hashKey = reorderableEntityChild.key.hashCode;
    final visible = hashKey != draggedHashKey;

    final childWhenDragging = Visibility(
      visible: visible,
      maintainAnimation: true,
      maintainSize: true,
      maintainState: true,
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

  void _buildWidget() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final hashKey = _reorderableEntity.child.key.hashCode;
      final updatedReorderableEntity = widget.onCreated(hashKey, _globalKey);

      if (updatedReorderableEntity != null) {
        setState(() {
          _reorderableEntity = updatedReorderableEntity;
        });
      }
    });
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
