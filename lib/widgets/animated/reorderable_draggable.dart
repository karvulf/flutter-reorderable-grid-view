import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

typedef OnCreatedFunction = ReorderableEntity? Function(
  ReorderableEntity reorderableEntity,
  GlobalKey key,
);

typedef OnDragUpdateFunction = Function(
  DragUpdateDetails details,
);

/// Enables drag and drop behaviour for [child].
///
/// Important methods: [onCreated] and [onBuilding].
///
/// [onCreated] is called after widget was built to return [_globalKey]
/// for calculating position and size.
///
/// [onBuilding] is always called if [isBuilding] of [reorderableEntity] is true.
/// That means, that there was an update in the position, usually a new position.
class ReorderableDraggable extends StatefulWidget {
  final ReorderableEntity reorderableEntity;
  final bool enableLongPress;
  final Duration longPressDelay;
  final bool enableDraggable;
  final BoxDecoration? dragChildBoxDecoration;

  final OnCreatedFunction onCreated;
  final OnCreatedFunction onBuilding;
  final Function(ReorderableEntity reorderableEntity) onDragStarted;

  final ReorderableEntity? draggedReorderableEntity;
  final Duration? initDelay;

  const ReorderableDraggable({
    required this.reorderableEntity,
    required this.enableLongPress,
    required this.longPressDelay,
    required this.enableDraggable,
    required this.onCreated,
    required this.onBuilding,
    required this.onDragStarted,
    required this.draggedReorderableEntity,
    this.initDelay,
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

  /// [GlobalKey] assigned to this widget for getting size and position.
  final _globalKey = GlobalKey();

  /// Default [BoxDecoration] for dragged child.
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

    _handleCreated();

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
      _handleUpdated();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reorderableEntityChild = _reorderableEntity.child;
    final child = Container(
      key: _globalKey,
      child: reorderableEntityChild,
    );

    final feedback = Material(
      color: Colors.transparent, // removes white corners when having shadow
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
        onDragStarted: _handleDragStarted,
        onDragEnd: _handleDragEnd,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: childWhenDragging,
      );
    } else {
      return Draggable(
        onDragStarted: _handleDragStarted,
        onDragEnd: _handleDragEnd,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: childWhenDragging,
      );
    }
  }

  /// Updates [_reorderableEntity] after calling [onCreated].
  void _handleCreated() {
    final initDuration = widget.initDelay;

    if (initDuration != null) {
      Future.delayed(initDuration).then((_) {
        _callOnCreated();
      });
    } else {
      _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((_) {
        _callOnCreated();
      });
    }
  }

  void _callOnCreated() {
    final updatedReorderableEntity = widget.onCreated(
      widget.reorderableEntity,
      _globalKey,
    );

    if (updatedReorderableEntity != null) {
      setState(() {
        _reorderableEntity = updatedReorderableEntity;
      });
    }
  }

  /// Updates [_reorderableEntity] after calling [onBuilding].
  void _handleUpdated() {
    _reorderableEntity = widget.reorderableEntity;

    if (_reorderableEntity.isBuilding) {
      _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((_) {
        final updatedReorderableEntity = widget.onBuilding(
          widget.reorderableEntity,
          _globalKey,
        );

        if (updatedReorderableEntity != null) {
          _reorderableEntity = updatedReorderableEntity;
        }
      });
    }
  }

  /// Called after dragging started.
  void _handleDragStarted() {
    widget.onDragStarted(_reorderableEntity);
    _controller.forward();
  }

  /// Called after releasing dragged child.
  void _handleDragEnd(DraggableDetails details) {
    _controller.reset();
  }
}

/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
T? _ambiguate<T>(T? value) => value;