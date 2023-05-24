import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/definitions.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_feedback.dart';

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
  final Widget child;
  final ReorderableEntity reorderableEntity;
  final bool enableLongPress;
  final Duration longPressDelay;
  final bool enableDraggable;
  final BoxDecoration? dragChildBoxDecoration;

  final ReorderableEntityCallback onDragStarted;
  final ReleasedReorderableEntityCallback onDragEnd;

  final ReorderableEntity? currentDraggedEntity;

  const ReorderableDraggable({
    required this.child,
    required this.reorderableEntity,
    required this.enableLongPress,
    required this.longPressDelay,
    required this.enableDraggable,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.currentDraggedEntity,
    this.dragChildBoxDecoration,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableDraggable> createState() => _ReorderableDraggableState();
}

class _ReorderableDraggableState extends State<ReorderableDraggable>
    with TickerProviderStateMixin {
  late final AnimationController _decoratedBoxAnimationController;
  late final DecorationTween _decorationTween;
  late DraggableDetails lastDraggedDetails;

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

    _decoratedBoxAnimationController = AnimationController(
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
  void dispose() {
    _decoratedBoxAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reorderableEntity = widget.reorderableEntity;
    var child = widget.child;

    final feedback = DraggableFeedback(
      reorderableEntity: reorderableEntity,
      decoration: _decorationTween.animate(
        _decoratedBoxAnimationController,
      ),
      child: child,
    );

    final draggedKey = widget.currentDraggedEntity?.key;
    final key = reorderableEntity.key;
    final visible = key != draggedKey;

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
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          _handleDragEnd(offset);
        },
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: child,
      );
    } else {
      return Draggable(
        onDragStarted: _handleDragStarted,
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          _handleDragEnd(offset);
        },
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: child,
      );
    }
  }

  /// Called after dragging started.
  void _handleDragStarted() {
    widget.onDragStarted(widget.reorderableEntity);
    _decoratedBoxAnimationController.forward();
  }

  /// Called after dragging ends.
  ///
  /// Important: This can also be called after the widget was disposed but
  /// is still dragged. This has to be done to finish the drag and drop.
  void _handleDragEnd(Offset offset) {
    if (mounted) {
      _decoratedBoxAnimationController.reset();
    }

    widget.onDragEnd(
      ReleasedReorderableEntity(
        reorderableEntity: widget.reorderableEntity,
        dropOffset: offset,
      ),
    );
  }
}
