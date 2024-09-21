import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
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
  final double feedbackScaleFactor;
  final BoxDecoration? dragChildBoxDecoration;

  final VoidCallback onDragStarted;
  final void Function(Offset globalOffset) onDragEnd;
  final VoidCallback onDragCanceled;

  final ReorderableEntity? currentDraggedEntity;

  const ReorderableDraggable({
    required this.child,
    required this.reorderableEntity,
    required this.enableLongPress,
    required this.longPressDelay,
    required this.enableDraggable,
    required this.feedbackScaleFactor,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onDragCanceled,
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
      size: reorderableEntity.size,
      decoration: _decorationTween.animate(
        _decoratedBoxAnimationController,
      ),
      feedbackScaleFactor: widget.feedbackScaleFactor,
      onDeactivate: widget.onDragCanceled,
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
    final data = _getData();

    if (!widget.enableDraggable) {
      return child;
    } else {
      return LongPressDraggable(
        delay: widget.enableLongPress ? widget.longPressDelay : Duration.zero,
        onDragStarted: _handleDragStarted,
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          _handleDragEnd(offset);
        },
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        data: data,
        child: child,
      );
    }
  }

  /// Called after dragging started.
  void _handleDragStarted() {
    widget.onDragStarted();
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

    widget.onDragEnd(offset);
  }

  Object? _getData() {
    final child = widget.child;

    if (child is CustomDraggable) {
      return child.data;
    } else {
      return null;
    }
  }
}
