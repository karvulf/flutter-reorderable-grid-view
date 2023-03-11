import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_builder_controller.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_drag_and_drop_controller.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_item_builder_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_opcacity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_positioned.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_released_container.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_init_child.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_scrolling_listener.dart';

typedef DraggableBuilder = Widget Function(
  List<Widget> children,
);

typedef ReorderedListFunction = List Function(List);
typedef OnReorderCallback = void Function(ReorderedListFunction);

/// Enables animated drag and drop behaviour for built widgets in [builder].
///
/// Be sure not to replace, add or remove your children while you are dragging
/// because this can lead to an unexpected behavior.
class ReorderableBuilder extends StatefulWidget {
  ///
  final List<Widget>? children;

  ///
  final Widget Function(
    Widget Function(Widget child, int index) itemBuilder,
  )? childBuilder;

  /// Specify indices for [children] that should not change their position while dragging.
  ///
  /// Default value: <int>[]
  final List<int> lockedIndices;

  /// The drag of a child can be started with the long press.
  ///
  /// Default value: true
  final bool enableLongPress;

  /// Specify the [Duration] for the pressed child before starting the dragging.
  ///
  /// Default value: kLongPressTimeout
  final Duration longPressDelay;

  /// When disabling draggable, the drag and drop behavior is not working.
  ///
  /// When [enableDraggable] is true, [onReorder] must not be null.
  ///
  /// Default value: true
  final bool enableDraggable;

  /// Enables the functionality to scroll while dragging a child to the top or bottom.
  ///
  /// Combined with the value of [automaticScrollExtent], an automatic scroll starts,
  /// when you drag the child and the widget of [builder] is scrollable.
  ///
  /// Defualt value: true
  final bool enableScrollingWhileDragging;

  /// Defines the height of the top or bottom before the dragged child indicates a scrolling.
  ///
  /// Default value: 80.0
  final double automaticScrollExtent;

  /// [Duration] for the fade in animation when a new child was added.
  ///
  /// Default value: const Duration(milliseconds: 500)
  final Duration fadeInDuration;

  /// [BoxDecoration] for the child that is dragged around.
  final BoxDecoration? dragChildBoxDecoration;

  /// Callback to return updated [children].
  final DraggableBuilder? builder;

  /// After releasing the dragged child, [onReorder] is called.
  ///
  /// [enableDraggable] has to be true to ensure this is called.
  final OnReorderCallback? onReorder;

  /// Adding delay after initializing [children].
  ///
  /// Usually, the delay would be a postFrameCallBack. But sometimes, if the app
  /// is a bit slow, or there are a lot of things happening at the same time, a
  /// longer delay is necessary to ensure a correct behavior when using drag and drop.
  ///
  /// Not recommended to use.
  final Duration? initDelay;

  /// Callback when dragging starts.
  ///
  /// Prevent updating your children while you are dragging because this can lead
  /// to an unexpected behavior.
  final VoidCallback? onDragStarted;

  /// Callback when the dragged child was released.
  final VoidCallback? onDragEnd;

  /// [ScrollController] to get the current scroll position. Important for calculations!
  ///
  /// This controller has to be assigned if the returned widget of [builder] is
  /// scrollable. Every [GridView] is scrollable by default.
  ///
  /// So usually, you should assign the controller to the [ReorderableBuilder]
  /// and to your [GridView].
  final ScrollController? scrollController;

  const ReorderableBuilder({
    required this.children,
    required this.builder,
    this.scrollController,
    this.onReorder,
    this.lockedIndices = const [],
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.automaticScrollExtent = 80.0,
    this.enableScrollingWhileDragging = true,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.dragChildBoxDecoration,
    this.initDelay,
    this.onDragStarted,
    this.onDragEnd,
    Key? key,
  })  : assert((enableDraggable && onReorder != null) || !enableDraggable),
        childBuilder = null,
        super(key: key);

  const ReorderableBuilder.builder({
    required this.childBuilder,
    this.scrollController,
    this.onReorder,
    this.lockedIndices = const [],
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.automaticScrollExtent = 80.0,
    this.enableScrollingWhileDragging = true,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.dragChildBoxDecoration,
    this.initDelay,
    this.onDragStarted,
    this.onDragEnd,
    Key? key,
  })  : assert((enableDraggable && onReorder != null) || !enableDraggable),
        children = null,
        builder = null,
        super(key: key);

  @override
  State<ReorderableBuilder> createState() => _ReorderableBuilderState();
}

// Todo: Items tauschen im Builder, z. B. 140 auf Position 300
class _ReorderableBuilderState extends State<ReorderableBuilder>
    with WidgetsBindingObserver {
  late final ReorderableBuilderController reorderableBuilderController;
  late final ReorderableItemBuilderController reorderableItemBuilderController;

  @override
  void initState() {
    super.initState();
    _ambiguate(WidgetsBinding.instance)!.addObserver(this);

    reorderableBuilderController = ReorderableBuilderController();
    reorderableItemBuilderController = ReorderableItemBuilderController();

    final children = widget.children;
    if (children == null) return;
    reorderableBuilderController.initChildren(children: children);
  }

  @override
  void didUpdateWidget(covariant ReorderableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    final children = widget.children;
    if (children == null || children == oldWidget.children) return;

    reorderableBuilderController.updateChildren(children: children);
    setState(() {});
  }

  @override
  void didChangeMetrics() {
    final orientationBefore = MediaQuery.of(context).orientation;
    _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((_) {
      if (!mounted) return;
      final orientationAfter = MediaQuery.of(context).orientation;
      if (orientationBefore != orientationAfter) {
        // Todo: Dieser Aufruf geschieht gleich 3 Mal!
        _reorderableController.handleDeviceOrientationChanged();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late Widget child;

    final builder = widget.builder;
    if (builder == null) {
      child = widget.childBuilder!(_buildItem);
    } else {
      child = builder(_wrapChildren());
    }

    return ReorderableScrollingListener(
      isDragging: _reorderableController.draggedEntity != null,
      reorderableChildKey: child.key as GlobalKey?,
      scrollController: widget.scrollController,
      automaticScrollExtent: widget.automaticScrollExtent,
      enableScrollingWhileDragging: widget.enableScrollingWhileDragging,
      onDragUpdate: _handleDragUpdate,
      onDragEnd: _handleDragEnd,
      onScrollUpdate: _handleScrollUpdate,
      getScrollOffset: _getScrollOffset,
      child: child,
    );
  }

  Widget _buildItem(Widget child, int index) {
    final reorderableEntity = reorderableItemBuilderController.buildItem(
      key: child.key as ValueKey,
      index: index,
    );
    final reorderableController = _reorderableController;
    final draggedEntity = reorderableController.draggedEntity;
    return _wrapChild(
      child: child,
      reorderableEntity: reorderableEntity,
      currentDraggedEntity: draggedEntity,
    );
  }

  List<Widget> _wrapChildren() {
    final children = widget.children;
    if (children == null) return <Widget>[];

    final updatedChildren = <Widget>[];

    final reorderableController = _reorderableController;
    final childrenKeyMap = reorderableController.childrenKeyMap;
    final draggedEntity = reorderableController.draggedEntity;
    for (final child in children) {
      final key = (child.key as ValueKey);
      final reorderableEntity = childrenKeyMap[key.value]!;
      updatedChildren.add(
        _wrapChild(
          child: child,
          reorderableEntity: reorderableEntity,
          currentDraggedEntity: draggedEntity,
        ),
      );
    }
    return updatedChildren;
  }

  Widget _wrapChild({
    required Widget child,
    required ReorderableEntity reorderableEntity,
    required ReorderableEntity? currentDraggedEntity,
  }) {
    return ReorderableAnimatedOpacity(
      reorderableEntity: reorderableEntity,
      fadeInDuration: widget.fadeInDuration,
      onOpacityFinished: _handleOpacityFinished,
      child: ReorderableAnimatedPositioned(
        reorderableEntity: reorderableEntity,
        isDragging: currentDraggedEntity != null,
        onMovingFinished: _handleMovingFinished,
        child: ReorderableInitChild(
          reorderableEntity: reorderableEntity,
          initDelay: widget.initDelay,
          onCreated: _handleCreatedChild,
          child: ReorderableAnimatedReleasedContainer(
            releasedReorderableEntity:
                _reorderableController.releasedReorderableEntity,
            scrollOffset: _getScrollOffset(),
            reorderableEntity: reorderableEntity,
            child: ReorderableDraggable(
              reorderableEntity: reorderableEntity,
              enableDraggable: widget.enableDraggable,
              currentDraggedEntity: currentDraggedEntity,
              enableLongPress: widget.enableLongPress,
              longPressDelay: widget.longPressDelay,
              dragChildBoxDecoration: widget.dragChildBoxDecoration,
              onDragStarted: _handleDragStarted,
              onDragEnd: (releasedReorderableEntity) {
                _reorderableController.updateReleasedReorderableEntity(
                  releasedReorderableEntity: releasedReorderableEntity,
                );
                setState(() {});
              },
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Drag and Drop part
  void _handleDragStarted(ReorderableEntity reorderableEntity) {
    _reorderableController.handleDragStarted(
      reorderableEntity: reorderableEntity,
      currentScrollOffset: _getScrollOffset(),
      lockedIndices: widget.lockedIndices,
    );
    setState(() {});
  }

  void _handleDragUpdate(PointerMoveEvent pointerMoveEvent) {
    final hasUpdated = _reorderableController.handleDragUpdate(
      pointerMoveEvent: pointerMoveEvent,
      lockedIndices: widget.lockedIndices,
    );
    if (hasUpdated) setState(() {});
  }

  void _handleScrollUpdate(Offset scrollOffset) {
    _reorderableController.handleScrollUpdate(
      scrollOffset: scrollOffset,
    );
  }

  void _handleDragEnd() {
    final reorderUpdateEntities = _reorderableController.handleDragEnd();

    if (reorderUpdateEntities != null) {
      widget.onReorder!((items) => _reorderableController.reorderList(
            items: items,
            reorderUpdateEntities: reorderUpdateEntities,
          ));
    }
    // important to update the dragged entity which should be null at this point
    setState(() {});
  }

  /// Animation part

  void _handleMovingFinished(ReorderableEntity reorderableEntity) {
    _reorderableController.handleMovingFinished(
      reorderableEntity: reorderableEntity,
    );
    setState(() {});
  }

  void _handleOpacityFinished(ReorderableEntity reorderableEntity) {
    _reorderableController.handleOpacityFinished(
      reorderableEntity: reorderableEntity,
    );
    setState(() {});
  }

  void _handleCreatedChild(
    ReorderableEntity reorderableEntity,
    GlobalKey key,
  ) {
    final reorderableController = _reorderableController;
    final offsetMap = reorderableController.offsetMap;

    Offset? offset;
    Size? size;

    var index = reorderableEntity.updatedOrderId;
    final renderObject = key.currentContext?.findRenderObject();

    if (renderObject != null && offsetMap[index] == null) {
      final renderBox = renderObject as RenderBox;
      offset = renderBox.localToGlobal(Offset.zero) + _getScrollOffset();
      size = renderBox.size;
    }

    reorderableController.handleCreatedChild(
      offset: offset,
      reorderableEntity: reorderableEntity,
      size: size,
    );
    setState(() {});
  }

  ReorderableDragAndDropController get _reorderableController {
    if (widget.children == null) {
      return reorderableItemBuilderController;
    } else {
      return reorderableBuilderController;
    }
  }

  /// Returning the current scroll position.
  ///
  /// There are two possibilities to get the scroll position.
  ///
  /// First one is, the returned child of [widget.builder] is a scrollable widget.
  /// In this case, it is important that the [widget.scrollController] is added
  /// to the scrollable widget to get the current scroll position.
  ///
  /// Another possibility is that one of the parents is scrollable.
  /// In that case, the position of the scroll is accessible inside [context].
  ///
  /// Otherwise, 0.0 will be returned.
  Offset _getScrollOffset() {
    var scrollPosition = Scrollable.maybeOf(context)?.position;
    final scrollController = widget.scrollController;

    if (scrollPosition == null &&
        scrollController != null &&
        scrollController.hasClients) {
      scrollPosition = scrollController.position;
    }

    if (scrollPosition != null) {
      final pixels = scrollPosition.pixels;
      final isScrollingVertical = scrollPosition.axis == Axis.vertical;
      return Offset(
        isScrollingVertical ? 0.0 : pixels,
        isScrollingVertical ? pixels : 0.0,
      );
    }

    return Offset.zero;
  }
}

/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
T? _ambiguate<T>(T? value) => value;
