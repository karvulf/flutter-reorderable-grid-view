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
  final void Function(Offset? globalOffset) onDragEnd;
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

  bool isDragging = false;
  final _draggableFeedbackGlobalKey = GlobalKey();

  /// Default [BoxDecoration] for dragged child.
  final _defaultBoxDecoration = BoxDecoration(
    boxShadow: <BoxShadow>[
      BoxShadow(
        // ignore: deprecated_member_use
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
      key: _draggableFeedbackGlobalKey,
      size: reorderableEntity.size,
      decoration: _decorationTween.animate(_decoratedBoxAnimationController),
      feedbackScaleFactor: widget.feedbackScaleFactor,
      onDeactivate: widget.onDragCanceled,
      child: child,
    );

    final currentDraggedEntity = widget.currentDraggedEntity;
    final updatedOrderId = reorderableEntity.updatedOrderId;
    final visible = currentDraggedEntity?.updatedOrderId != updatedOrderId;

    final data = _getData();

    if (!widget.enableDraggable) {
      return child;
    }

    late final Widget draggable;

    // if delay is Duration.zero, LongPressDraggable breaks onTap for [child]
    if (!widget.enableLongPress || widget.longPressDelay == Duration.zero) {
      draggable = Draggable(
        onDragStarted: _handleDragStarted,
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          _handleDragEnd(offset);
        },
        onDragCompleted: _handleDragCompleted,
        feedback: feedback,
        data: data,
        child: child,
      );
    } else {
      draggable = LongPressDraggable(
        delay: widget.longPressDelay,
        onDragStarted: _handleDragStarted,
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          _handleDragEnd(offset);
        },
        onDragCompleted: _handleDragCompleted,
        feedback: feedback,
        data: data,
        child: child,
      );
    }

    return Visibility(
      visible: visible,
      maintainAnimation: true,
      maintainSize: true,
      maintainState: true,
      child: widget.currentDraggedEntity != null ? child : draggable,
    );
  }

  /// Called after dragging started.
  void _handleDragStarted() {
    isDragging = true;
    widget.onDragStarted();
    _decoratedBoxAnimationController.forward();
  }

  /// Called when the draggable is dropped and accepted by a [DragTarget].
  ///
  /// This callback doesn't receive any positions which means that the position
  /// will be calculated throughout the [DraggableFeedback].
  void _handleDragCompleted() {
    Offset? offset;

    final currentContext = _draggableFeedbackGlobalKey.currentContext;
    final renderBox = currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      offset = renderBox.localToGlobal(Offset.zero);
    }

    _handleDragEnd(offset);
  }

  /// Called after dragging ends.
  ///
  /// Important: This can also be called after the widget was disposed but
  /// is still dragged. This has to be done to finish the drag and drop.
  void _handleDragEnd(Offset? offset) {
    if (mounted) {
      isDragging = false;
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
