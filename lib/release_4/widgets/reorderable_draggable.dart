import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';

typedef OnCreatedFunction = void Function(
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
  final Widget child;
  final ReorderableEntity reorderableEntity;
  final bool enableLongPress;
  final Duration longPressDelay;
  final bool enableDraggable;
  final BoxDecoration? dragChildBoxDecoration;
  final ReleasedReorderableEntity? releasedReorderableEntity;

  final void Function(ReorderableEntity reorderableEntity) onDragStarted;
  final void Function(ReleasedReorderableEntity releasedReorderableEntity)
      onDragEnd;

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
    required this.releasedReorderableEntity,
    this.dragChildBoxDecoration,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableDraggable> createState() => _ReorderableDraggableState();
}

class _ReorderableDraggableState extends State<ReorderableDraggable>
    with TickerProviderStateMixin {
  late final AnimationController _decoratedBoxAnimationController;
  late AnimationController _offsetAnimationController;
  late final DecorationTween _decorationTween;
  late DraggableDetails lastDraggedDetails;

  ///
  Animation<Offset>? _offsetAnimation;

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
    _offsetAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
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
    final currentDraggedEntity = widget.currentDraggedEntity;
    final oldDraggedEntity = oldWidget.currentDraggedEntity;
    if (currentDraggedEntity != oldWidget.currentDraggedEntity &&
        currentDraggedEntity == null) {
      if (oldDraggedEntity?.key == widget.reorderableEntity.key) {
        // _handleDragEnd(details);
      }
    }

    final releasedReorderableEntity = widget.releasedReorderableEntity;
    if (oldWidget.releasedReorderableEntity !=
            widget.releasedReorderableEntity &&
        releasedReorderableEntity != null &&
        releasedReorderableEntity.reorderableEntity.key ==
            widget.reorderableEntity.key) {
      _handleReleasedReorderableEntity(
        releasedReorderableEntity: releasedReorderableEntity,
      );
    }
  }

  @override
  void dispose() {
    _decoratedBoxAnimationController.dispose();
    _offsetAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reorderableEntity = widget.reorderableEntity;
    var child = widget.child;
    if (_offsetAnimation != null) {
      child = Container(
        transform: Matrix4.translationValues(
          _offsetAnimation!.value.dx,
          _offsetAnimation!.value.dy,
          0.0,
        ),
        child: child,
      );
    }
    final size = reorderableEntity.size;
    final feedback = Material(
      color: Colors.transparent, // removes white corners when having shadow
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: DecoratedBoxTransition(
          position: DecorationPosition.background,
          decoration: _decorationTween.animate(
            _decoratedBoxAnimationController,
          ),
          child: child,
        ),
      ),
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

  /// Called after dragging started.
  void _handleDragStarted() {
    widget.onDragStarted(widget.reorderableEntity);
    _decoratedBoxAnimationController.forward();
  }

  void _handleDragEnd(DraggableDetails details) {
    widget.onDragEnd(
      ReleasedReorderableEntity(
        reorderableEntity: widget.reorderableEntity,
        dropOffset: details.offset,
      ),
    );
  }

  /// Called after releasing dragged child.
  Future<void> _handleReleasedReorderableEntity({
    required ReleasedReorderableEntity releasedReorderableEntity,
  }) async {
    _decoratedBoxAnimationController.reset();
    final begin = releasedReorderableEntity.dropOffset -
        widget.reorderableEntity.updatedOffset;
    final tween = Tween<Offset>(begin: begin, end: Offset.zero);
    _offsetAnimation = tween.animate(_offsetAnimationController)
      ..addListener(() {
        setState(() {});
      });
    await _offsetAnimationController.forward();
    _offsetAnimationController.reset();
    _offsetAnimation = null;
  }
}
