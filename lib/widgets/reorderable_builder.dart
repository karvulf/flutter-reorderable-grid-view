import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_builder_controller.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_drag_and_drop_controller.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_item_builder_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_scrolling_listener.dart';

typedef DraggableBuilder = Widget Function(
  List<Widget> children,
);

typedef ReorderedListFunction = List Function(List);
typedef OnReorderCallback = void Function(ReorderedListFunction);
typedef ItemCallback = void Function(int intdex);

/// Enables animated drag and drop behaviour for built widgets in [builder].
///
/// Be sure not to replace, add or remove your children while you are dragging
/// because this can lead to an unexpected behavior.
class ReorderableBuilder extends StatefulWidget {
  static const _defaultLockedIndices = <int>[];
  static const _defaultNonDraggableIndices = <int>[];
  static const _defaultEnableLongPress = true;
  static const _defaultLongPressDelay = kLongPressTimeout;
  static const _defaultEnableDraggable = true;
  static const _defaultAutomaticScrollExtent = 80.0;
  static const _defaultEnableScrollingWhileDragging = true;
  static const _defaultFadeInDuration = Duration(milliseconds: 500);
  static const _defaultReleasedChildDuration = Duration(milliseconds: 150);
  static const _defaultPositionDuration = Duration(milliseconds: 200);
  static const _defaultFeedbackScaleFactor = 1.05;

  /// Defines the children that will be displayed for drag and drop.
  final List<Widget>? children;

  /// Enable support for [GridView.builder] using this function.
  ///
  /// This function allows rendering all children using a builder.
  /// Make sure your [GridView.builder] calls [childBuilder] to return
  /// widgets that support animations and drag-and-drop functionality.
  final Widget Function(
    Widget Function(Widget child, int index) itemBuilder,
  )? childBuilder;

  /// Specify indices for [children] that should not be draggable or movable.
  ///
  /// If you have e.g. [0, 1, 2], then it means that your [children] on the
  /// first, second and third position cannot be dragged. Furthermore if
  /// you drag and drop, they won't change their position.
  ///
  /// Default value: <int>[]
  final List<int> lockedIndices;

  /// Specify indices for [children] that are not draggable.
  ///
  /// If you have e.g. [3, 4], then it means that your [children] on the
  /// third and fourth cannot be used for dragging.
  /// Compared to [lockedIndices], these [children] can change their position
  /// while dragging.
  ///
  /// Default value: <int>[]
  final List<int> nonDraggableIndices;

  /// The drag of a child will be started with a long press.
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
  /// Default value: true
  final bool enableScrollingWhileDragging;

  /// Defines the height of the top or bottom before the dragged child indicates a scrolling.
  ///
  /// Default value: 80.0
  final double automaticScrollExtent;

  /// [Duration] for the fade in animation when a new child was added.
  ///
  /// Default value: const Duration(milliseconds: 500)
  final Duration fadeInDuration;

  /// [Duration] for the position animation when a dragged child was released.
  ///
  /// The duration influence the time of the released dragged child going back
  /// to his new position.
  ///
  /// Default value: const Duration(milliseconds: 150)
  final Duration releasedChildDuration;

  /// Duration for the position change of a child.
  ///
  /// The position can be updated if a child was removed or added.
  /// This duration won't be used for the position changes while dragging.
  ///
  /// Default value: const Duration(milliseconds: 200)
  final Duration positionDuration;

  /// The scale factor applied to the feedback widget during a drag operation.
  ///
  /// This determines how much the feedback widget (the visual representation
  /// of the widget being dragged) will grow or shrink when the drag starts.
  /// A value of 1.0 means no scaling, while a value greater than 1.0 enlarges
  /// the feedback widget.
  /// For example, a value of 1.5 will increase the size by 50%.
  ///
  /// Default value: 1.05 (feedback widget grows by 5%)
  final double feedbackScaleFactor;

  /// [BoxDecoration] for the child that is dragged around.
  final BoxDecoration? dragChildBoxDecoration;

  /// It's required to use [ReorderableBuilder] to obtain updated [children].
  ///
  /// This function returns the [children] containing all necessary widgets
  /// for animations and drag-and-drop functionality. Ensure to use the children
  /// returned by this function for proper integration.
  final DraggableBuilder? builder;

  /// After releasing the dragged child, [onReorder] is called.
  ///
  /// Ensure [enableDraggable] is set to true for this callback to trigger.
  /// This function takes a [ReorderedListFunction] as a parameter, which will
  /// reorder a list of items. Make sure to pass your list to this function
  /// and cast it afterward to your specific list type.
  /// This mechanism ensures that your list is correctly updated. You can then
  /// use the updated items returned by this function.
  final OnReorderCallback? onReorder;

  /// Callback when dragging starts with the index where it started.
  ///
  /// Prevent updating your children while you are dragging because this can lead
  /// to an unexpected behavior.
  /// [index] is the position of the child where the dragging started.
  final ItemCallback? onDragStarted;

  /// Callback when the dragged child was released with the index.
  ///
  /// [index] is the position of the child where the dragging ended.
  /// Important: This is called before [onReorder].
  final ItemCallback? onDragEnd;

  /// Called when the dragged child has updated his position while dragging.
  ///
  /// [index] is the new position of the dragged child. While this callback
  /// you should not update your [children] by yourself to ensure a correct
  /// behavior while dragging.
  final ItemCallback? onUpdatedDraggedChild;

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
    this.lockedIndices = _defaultLockedIndices,
    this.nonDraggableIndices = _defaultNonDraggableIndices,
    this.enableLongPress = _defaultEnableLongPress,
    this.longPressDelay = _defaultLongPressDelay,
    this.enableDraggable = _defaultEnableDraggable,
    this.automaticScrollExtent = _defaultAutomaticScrollExtent,
    this.enableScrollingWhileDragging = _defaultEnableScrollingWhileDragging,
    this.fadeInDuration = _defaultFadeInDuration,
    this.releasedChildDuration = _defaultReleasedChildDuration,
    this.positionDuration = _defaultPositionDuration,
    this.feedbackScaleFactor = _defaultFeedbackScaleFactor,
    this.dragChildBoxDecoration,
    this.onDragStarted,
    this.onDragEnd,
    this.onUpdatedDraggedChild,
    Key? key,
  })  : assert((enableDraggable && onReorder != null) || !enableDraggable),
        childBuilder = null,
        super(key: key);

  const ReorderableBuilder.builder({
    required this.childBuilder,
    this.scrollController,
    this.onReorder,
    this.lockedIndices = _defaultLockedIndices,
    this.nonDraggableIndices = _defaultNonDraggableIndices,
    this.enableLongPress = _defaultEnableLongPress,
    this.longPressDelay = _defaultLongPressDelay,
    this.enableDraggable = _defaultEnableDraggable,
    this.automaticScrollExtent = _defaultAutomaticScrollExtent,
    this.enableScrollingWhileDragging = _defaultEnableScrollingWhileDragging,
    this.fadeInDuration = _defaultFadeInDuration,
    this.releasedChildDuration = _defaultReleasedChildDuration,
    this.positionDuration = _defaultPositionDuration,
    this.feedbackScaleFactor = _defaultFeedbackScaleFactor,
    this.dragChildBoxDecoration,
    this.onDragStarted,
    this.onDragEnd,
    this.onUpdatedDraggedChild,
    Key? key,
  })  : assert((enableDraggable && onReorder != null) || !enableDraggable),
        children = null,
        builder = null,
        super(key: key);

  @override
  State<ReorderableBuilder> createState() => _ReorderableBuilderState();
}

class _ReorderableBuilderState extends State<ReorderableBuilder>
    with WidgetsBindingObserver {
  late final ReorderableBuilderController reorderableBuilderController;
  late final ReorderableItemBuilderController reorderableItemBuilderController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    WidgetsBinding.instance.removeObserver(this);
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
      index: index,
    );
  }

  List<Widget> _wrapChildren() {
    final children = widget.children;
    if (children == null) return <Widget>[];

    final updatedChildren = <Widget>[];

    final reorderableController = _reorderableController;
    final childrenKeyMap = reorderableController.childrenKeyMap;
    final draggedEntity = reorderableController.draggedEntity;
    var index = 0;

    for (final child in children) {
      final key = (child.key as ValueKey);
      final reorderableEntity = childrenKeyMap[key.value]!;

      updatedChildren.add(
        _wrapChild(
          child: child,
          reorderableEntity: reorderableEntity,
          currentDraggedEntity: draggedEntity,
          index: index++,
        ),
      );
    }
    return updatedChildren;
  }

  /// Helper function to wrap [child] with required widgets for this package.
  ///
  /// [index] should be the position of the [child] in [widget.children] and
  /// is required to know if the [child] cannot be dragged.
  Widget _wrapChild({
    required Widget child,
    required ReorderableEntity reorderableEntity,
    required ReorderableEntity? currentDraggedEntity,
    required int index,
  }) {
    bool isDraggable = !widget.nonDraggableIndices.contains(index) &&
        !widget.lockedIndices.contains(index);

    return ReorderableBuilderItem(
      reorderableEntity: reorderableEntity,
      fadeInDuration: widget.fadeInDuration,
      onOpacityFinished: _handleOpacityFinished,
      positionDuration: widget.positionDuration,
      onMovingFinished: _handleMovingFinished,
      onCreated: _handleCreatedChild,
      releasedReorderableEntity:
          _reorderableController.releasedReorderableEntity,
      scrollOffset: _getScrollOffset(),
      releasedChildDuration: widget.releasedChildDuration,
      enableDraggable: widget.enableDraggable && isDraggable,
      currentDraggedEntity: currentDraggedEntity,
      enableLongPress: widget.enableLongPress,
      longPressDelay: widget.longPressDelay,
      dragChildBoxDecoration: widget.dragChildBoxDecoration,
      feedbackScaleFactor: widget.feedbackScaleFactor,
      onDragStarted: _handleDragStarted,
      onDragEnd: _handleDragEnd,
      onDragCanceled: _handleDragCanceled,
      child: child,
    );
  }

  ///
  /// Drag and Drop part
  ///

  void _handleDragStarted(ReorderableEntity reorderableEntity) {
    _reorderableController.handleDragStarted(
      reorderableEntity: reorderableEntity,
      currentScrollOffset: _getScrollOffset(),
      lockedIndices: widget.lockedIndices,
      isScrollableOutside: Scrollable.maybeOf(context)?.position == null,
    );
    widget.onDragStarted?.call(reorderableEntity.updatedOrderId);

    setState(() {});
  }

  void _handleDragUpdate(PointerMoveEvent pointerMoveEvent) {
    final hasUpdated = _reorderableController.handleDragUpdate(
      pointerMoveEvent: pointerMoveEvent,
    );

    if (hasUpdated) {
      // this fixes the issue when the user scrolls while dragging to get the updated scroll value
      _reorderableController.scrollOffset = _getScrollOffset();

      // notifying about the new position of the dragged child
      final orderId = _reorderableController.draggedEntity!.updatedOrderId;
      widget.onUpdatedDraggedChild?.call(orderId);

      setState(() {});
    }
  }

  /// Called after dragged item was released.
  ///
  /// The offset will be translated to the local position of this widget
  ///
  /// If the scrollable part is outside the widget then the scroll offset
  /// has to be subtracted to get the correct position.
  void _handleDragEnd(
    ReorderableEntity reorderableEntity,
    Offset globalOffset,
  ) {
    var globalRenderObject = context.findRenderObject() as RenderBox;
    var offset = globalRenderObject.globalToLocal(globalOffset);

    // scrollable part is outside this widget
    if (Scrollable.maybeOf(context)?.position != null) {
      offset -= _reorderableController.scrollOffset;
    }

    // call to ensure animation to dropped item
    _reorderableController.updateReleasedReorderableEntity(
      releasedReorderableEntity: ReleasedReorderableEntity(
        dropOffset: offset,
        reorderableEntity: reorderableEntity,
      ),
    );
    setState(() {});

    _finishDragging();

    // important to update the dragged entity which should be null at this point
    setState(() {});
  }

  /// Called after the dragged child was canceled, e.g. deleted.
  ///
  /// Finishes dragging without doing any animation for the dragged entity.
  void _handleDragCanceled(ReorderableEntity reorderableEntity) {
    _finishDragging();
  }

  void _handleScrollUpdate(Offset scrollOffset) {
    _reorderableController.scrollOffset = scrollOffset;
  }

  void _finishDragging() {
    final draggedEntity = _reorderableController.draggedEntity;
    if (draggedEntity == null) return;

    widget.onDragEnd?.call(draggedEntity.updatedOrderId);

    final reorderUpdateEntities = _reorderableController.handleDragEnd();

    if (reorderUpdateEntities != null) {
      widget.onReorder!((items) => _reorderableController.reorderList(
            items: items,
            reorderUpdateEntities: reorderUpdateEntities,
          ));
    }
  }

  ///
  /// Animation part
  ///

  ReorderableEntity _handleMovingFinished(ReorderableEntity reorderableEntity) {
    return _reorderableController.handleMovingFinished(
      reorderableEntity: reorderableEntity,
    );
  }

  ReorderableEntity _handleOpacityFinished(
    ReorderableEntity reorderableEntity,
  ) {
    return _reorderableController.handleOpacityFinished(
      reorderableEntity: reorderableEntity,
    );
  }

  /// Creates [ReorderableEntity] that contains all required values for animations.
  ///
  /// When the child was created, the offset and size is calculated (with [key]).
  /// The offset is a bit more tricky and has to be translated to the local
  /// offset in this widget.
  /// At this way the offset will always be correct for calculations even though
  /// this widget is appearing in animated way (e.g. within a BottomModalSheet).
  ReorderableEntity _handleCreatedChild(
      ReorderableEntity reorderableEntity, GlobalKey key) {
    final reorderableController = _reorderableController;
    final offsetMap = reorderableController.offsetMap;

    Offset? offset;

    var index = reorderableEntity.updatedOrderId;
    final renderObject = key.currentContext?.findRenderObject();

    if (renderObject != null) {
      final renderBox = renderObject as RenderBox;

      // should only add offset if it is not existing to prevent wrong animations
      if (offsetMap[index] == null) {
        // translating global offset to the local offset in this widget
        var parentRenderObject = context.findRenderObject() as RenderBox;
        offset = parentRenderObject.globalToLocal(
          renderBox.localToGlobal(Offset.zero),
        );
        offset += _getScrollOffset();
      }
    }

    return reorderableController.handleCreatedChild(
      offset: offset,
      reorderableEntity: reorderableEntity,
    );
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

    // For example, in cases where there are nested scrollable widgets
    // like GridViews inside a parent scrollable widget,
    // the widget assigned to the controller will be used for scroll calculations
    if (scrollController != null && scrollController.hasClients) {
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
