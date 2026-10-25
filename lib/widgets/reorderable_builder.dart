import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_builder_controller.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_drag_and_drop_controller.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_item_builder_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/removed_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorder_update_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/reorderable_scrollable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_removed_child.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_scrolling_listener.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_size_changed_listener.dart';

typedef DraggableBuilder = Widget Function(
  List<Widget> children,
);

typedef ReorderedListFunction<T> = List<T> Function(List<T>);
typedef OnReorderCallback<T> = void Function(ReorderedListFunction<T>);
typedef OnReorderPositions = void Function(List<ReorderUpdateEntity>);
typedef ItemCallback = void Function(int index);
typedef ChildBuilderFunction = Widget Function(
  Widget Function(Widget child, int index) itemBuilder,
);

/// Enables animated drag and drop behaviour for built widgets in [builder].
///
/// Be sure not to replace, add or remove your children while you are dragging
/// because this can lead to an unexpected behavior.
///
/// The generic type [T] defines the list type after reordering with
/// [ReorderedListFunction] in [onReorder].
class ReorderableBuilder<T> extends StatefulWidget {
  static const _defaultLockedIndices = <int>[];
  static const _defaultNonDraggableIndices = <int>[];
  static const _defaultEnableLongPress = true;
  static const _defaultLongPressDelay = kLongPressTimeout;
  static const _defaultEnableDraggable = true;
  static const _defaultAutomaticScrollExtent = 150.0;
  static const _defaultEnableScrollingWhileDragging = true;
  static const _defaultFeedbackScaleFactor = 1.05;
  static const _defaultReverse = false;
  static const _defaultAnimationConfig = ReorderableAnimationConfig();

  /// Defines the children that will be displayed for drag and drop.
  final List<Widget>? children;

  /// Enable support for [GridView.builder] using this function.
  ///
  /// This function allows rendering all children using a builder.
  /// Make sure your [GridView.builder] calls [childBuilder] to return
  /// widgets that support animations and drag-and-drop functionality.
  final ChildBuilderFunction? childBuilder;

  /// Configuration for child animations.
  ///
  /// Includes the durations and curves for fade-in, position change,
  /// released-item movement, and drag feedback.
  final ReorderableAnimationConfig animationConfig;

  /// The length of items that are rendered through [ReorderableBuilder.builder].
  ///
  /// This count ensures that the drag and drop only happens the items in a
  /// valid range and ignores any other item out of this range.
  final int? itemCount;

  /// Specify indices for [children] that should not be draggable or movable.
  ///
  /// If you have e.g. [0, 1, 2], then it means that your [children] on the
  /// first, second and third position cannot be dragged. Furthermore if
  /// you drag and drop, they won't change their position.
  ///
  /// Default value: &lt;int&gt;&#91;&#93;
  final List<int> lockedIndices;

  /// Specify indices for [children] that are not draggable.
  ///
  /// If you have e.g. [3, 4], then it means that your [children] on the
  /// third and fourth cannot be used for dragging.
  /// Compared to [lockedIndices], these [children] can change their position
  /// while dragging.
  ///
  /// Default value: &lt;int&gt;&#91;&#93;
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
  /// When [enableDraggable] is true, either [onReorder] or [onReorderPositions]
  /// must be provided.
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
  /// Default value: 150.0
  final double automaticScrollExtent;

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

  /// Manages the case where the order of [children] is reversed.
  ///
  /// If the [children] list is in reverse order, set this flag to true to ensure
  /// the widget behaves as expected. Failing to update this flag when the
  /// order is reversed will result in incorrect behavior.
  ///
  /// Default value: `false`
  final bool reverse;

  /// [BoxDecoration] for the child that is dragged around.
  final BoxDecoration? dragChildBoxDecoration;

  /// It's required to use [ReorderableBuilder] to obtain updated [children].
  ///
  /// This function returns the [children] containing all necessary widgets
  /// for animations and drag-and-drop functionality. Ensure to use the children
  /// returned by this function for proper integration.
  final DraggableBuilder? builder;

  /// After releasing the dragged child, [onReorder] or [onReorderPositions] is called.
  ///
  /// Ensure [enableDraggable] is set to true for this callback to trigger.
  /// This function takes a [ReorderedListFunction] as a parameter, which will
  /// reorder a list of items. Make sure to pass your list to this function
  /// and cast it afterward to your specific list type.
  /// This mechanism ensures that your list is correctly updated. You can then
  /// use the updated items returned by this function.
  final OnReorderCallback<T>? onReorder;

  /// After releasing the dragged child, [onReorderPositions] is called.
  ///
  /// Ensure [enableDraggable] is set to true for this callback to trigger.
  /// This function returns a list of [ReorderUpdateEntity] containing the
  /// [ReorderUpdateEntity.oldIndex] and [ReorderUpdateEntity.newIndex] of each
  /// moved child.
  /// Apply them in order to your list. Use either this or [onReorder].
  final OnReorderPositions? onReorderPositions;

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
  /// You have assign the controller to the [ReorderableBuilder]
  /// and to your [GridView].
  ///
  /// If the scrollable widget is outside [ReorderableBuilder], then you don't
  /// add [scrollController] to this widget because the calculations also works
  /// by using the scroll value in the context.
  final ScrollController? scrollController;

  const ReorderableBuilder({
    required this.children,
    required this.builder,
    this.scrollController,
    this.onReorder,
    this.onReorderPositions,
    this.animationConfig = _defaultAnimationConfig,
    this.lockedIndices = _defaultLockedIndices,
    this.nonDraggableIndices = _defaultNonDraggableIndices,
    @Deprecated("This parameter is no longer needed.\n"
        "To disable the long press and initiate the drag immediately, "
        "set [longPressDelay] to [Duration.zero].")
    this.enableLongPress = _defaultEnableLongPress,
    this.longPressDelay = _defaultLongPressDelay,
    this.enableDraggable = _defaultEnableDraggable,
    this.automaticScrollExtent = _defaultAutomaticScrollExtent,
    this.enableScrollingWhileDragging = _defaultEnableScrollingWhileDragging,
    this.feedbackScaleFactor = _defaultFeedbackScaleFactor,
    this.reverse = _defaultReverse,
    this.dragChildBoxDecoration,
    this.onDragStarted,
    this.onDragEnd,
    this.onUpdatedDraggedChild,
    super.key,
  })  : assert(
          (enableDraggable &&
                  (onReorder != null || onReorderPositions != null)) ||
              !enableDraggable,
        ),
        childBuilder = null,
        itemCount = null;

  const ReorderableBuilder.builder({
    required ChildBuilderFunction this.childBuilder,
    required int this.itemCount,
    this.scrollController,
    this.onReorder,
    this.onReorderPositions,
    this.animationConfig = _defaultAnimationConfig,
    this.lockedIndices = _defaultLockedIndices,
    this.nonDraggableIndices = _defaultNonDraggableIndices,
    @Deprecated("This parameter is no longer needed.\n"
        "To disable the long press and initiate the drag immediately, "
        "set [longPressDelay] to [Duration.zero].")
    this.enableLongPress = _defaultEnableLongPress,
    this.longPressDelay = _defaultLongPressDelay,
    this.enableDraggable = _defaultEnableDraggable,
    this.automaticScrollExtent = _defaultAutomaticScrollExtent,
    this.enableScrollingWhileDragging = _defaultEnableScrollingWhileDragging,
    this.feedbackScaleFactor = _defaultFeedbackScaleFactor,
    this.reverse = _defaultReverse,
    this.dragChildBoxDecoration,
    this.onDragStarted,
    this.onDragEnd,
    this.onUpdatedDraggedChild,
    super.key,
  })  : assert(
          (enableDraggable &&
                  (onReorder != null || onReorderPositions != null)) ||
              !enableDraggable,
        ),
        children = null,
        builder = null;

  @override
  State<ReorderableBuilder<T>> createState() => _ReorderableBuilderState();
}

class _ReorderableBuilderState<T> extends State<ReorderableBuilder<T>> {
  late final ReorderableBuilderController reorderableBuilderController;
  late final ReorderableItemBuilderController reorderableItemBuilderController;

  /// Removed children that are still shown while fading out.
  final _removedEntities = <RemovedReorderableEntity>[];

  /// Last built child of every key for [ReorderableBuilder.builder].
  ///
  /// Needed to fade out a removed child that is no longer built.
  final _lastBuiltChildren = <dynamic, Widget>{};

  /// Keys of children built since the last update of the item count.
  final _builtKeyValues = <dynamic>{};

  /// Delay for position changes that were triggered by removed children.
  Duration _positionChangeDelay = Duration.zero;

  @override
  void initState() {
    super.initState();
    reorderableBuilderController = ReorderableBuilderController();
    reorderableItemBuilderController = ReorderableItemBuilderController();

    final children = widget.children;
    if (children == null) return;
    reorderableBuilderController.initChildren(children: children);
  }

  @override
  void didUpdateWidget(covariant ReorderableBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final children = widget.children;
    if (children == null) {
      _checkRemovedBuiltChildren(oldItemCount: oldWidget.itemCount);
      return;
    }
    if (children == oldWidget.children) return;

    _updateRemovedEntities(
      oldChildren: oldWidget.children ?? const [],
      children: children,
    );
    reorderableBuilderController.updateChildren(children: children);
    setState(() {});
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

    return ReorderableSizeChangedListener(
      onSizeChanged: _handleSizeChanged,
      // always added to keep the widget tree stable when children are removed
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          ReorderableScrollingListener(
            isDragging: _reorderableController.draggedEntity != null,
            reorderableChildKey: child.key as GlobalKey?,
            scrollController: widget.scrollController,
            automaticScrollExtent: widget.automaticScrollExtent,
            enableScrollingWhileDragging: widget.enableScrollingWhileDragging,
            reverse: widget.reverse,
            onDragUpdate: _handleDragUpdate,
            child: child,
          ),
          ..._removedEntities.map(_buildRemovedChild),
        ],
      ),
    );
  }

  /// Adds removed children of [oldChildren] to [_removedEntities] to fade them out.
  ///
  /// Only children with a known offset and size are faded out. While dragging
  /// or without fade out duration, removed children disappear immediately.
  void _updateRemovedEntities({
    required List<Widget> oldChildren,
    required List<Widget> children,
  }) {
    final keyValues = {
      for (final child in children) (child.key as ValueKey).value,
    };

    // a child that was added again is shown by the GridView
    _removedEntities.removeWhere(
      (entity) => keyValues.contains(entity.key.value),
    );

    final isFadeOutDisabled =
        widget.animationConfig.fadeOutDuration == Duration.zero;
    if (isFadeOutDisabled || _reorderableController.draggedEntity != null) {
      return;
    }

    final childrenKeyMap = reorderableBuilderController.childrenKeyMap;
    final removedCount = _removedEntities.length;
    for (final oldChild in oldChildren) {
      final key = oldChild.key as ValueKey;
      if (keyValues.contains(key.value)) continue;

      final reorderableEntity = childrenKeyMap[key.value];
      if (reorderableEntity == null || reorderableEntity.isBuildingOffset) {
        continue;
      }

      _removedEntities.add(
        RemovedReorderableEntity(
          key: key,
          child: oldChild,
          offset: reorderableEntity.updatedOffset,
          size: reorderableEntity.size,
        ),
      );
    }

    if (_removedEntities.length > removedCount) _delayPositionChanges();
  }

  /// Finds removed children for [ReorderableBuilder.builder] to fade them out.
  ///
  /// When the item count decreases, the GridView rebuilds all children that
  /// are currently shown. A child that was visible before, but is not built
  /// again in the next frame, was removed.
  ///
  /// ponytail: the removed child is added one frame after it disappeared,
  /// because the GridView builds its children after this widget.
  void _checkRemovedBuiltChildren({required int? oldItemCount}) {
    final itemCount = widget.itemCount;
    if (oldItemCount == null ||
        itemCount == null ||
        itemCount >= oldItemCount) {
      return;
    }

    final isFadeOutDisabled =
        widget.animationConfig.fadeOutDuration == Duration.zero;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (isFadeOutDisabled ||
        _reorderableController.draggedEntity != null ||
        renderBox == null ||
        !renderBox.hasSize) {
      return;
    }

    // size of the last frame
    final visibleRect = Offset.zero & renderBox.size;
    final scrollOffset = _scrollOffset;
    final visibleEntities = <RemovedReorderableEntity>[];

    for (final entity
        in reorderableItemBuilderController.childrenKeyMap.values) {
      final child = _lastBuiltChildren[entity.key.value];
      if (child == null || entity.isBuildingOffset) continue;

      final rect = (entity.updatedOffset - scrollOffset) & entity.size;
      if (!rect.overlaps(visibleRect)) continue;

      visibleEntities.add(
        RemovedReorderableEntity(
          key: entity.key,
          child: child,
          offset: entity.updatedOffset,
          size: entity.size,
        ),
      );
    }

    _builtKeyValues.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final removedEntities = visibleEntities.where(
        (entity) => !_builtKeyValues.contains(entity.key.value),
      );
      if (removedEntities.isEmpty) return;

      _delayPositionChanges();
      setState(() {
        for (final removedEntity in removedEntities) {
          _lastBuiltChildren.remove(removedEntity.key.value);
          _removedEntities.add(removedEntity);
        }
      });
    });
  }

  /// Lets the position changes of the current update wait for the fade out.
  ///
  /// Only if [ReorderableAnimationConfig.positionChangeAfterFadeOut] is true.
  /// The delay is reset after the next frame, when all position changes of
  /// this update have started.
  void _delayPositionChanges() {
    final animationConfig = widget.animationConfig;
    if (!animationConfig.positionChangeAfterFadeOut) return;

    _positionChangeDelay = animationConfig.fadeOutDuration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _positionChangeDelay = Duration.zero;
      });
    });
  }

  /// Shows the removed child of [removedEntity] at its last position.
  ///
  /// The position follows [ReorderableBuilder.scrollController] while fading out.
  ///
  /// ponytail: with a scrollable outside of this widget, the position is not
  /// updated while scrolling during the fade out.
  Widget _buildRemovedChild(RemovedReorderableEntity removedEntity) {
    Widget buildPositioned(BuildContext context, Widget? child) {
      final offset = removedEntity.offset - _scrollOffset;
      return Positioned(
        left: offset.dx,
        top: offset.dy,
        width: removedEntity.size.width,
        height: removedEntity.size.height,
        child: child!,
      );
    }

    final child = ReorderableAnimatedRemovedChild(
      animationConfig: widget.animationConfig,
      onFinished: () => setState(() {
        _removedEntities.remove(removedEntity);
      }),
      child: removedEntity.child,
    );

    final scrollController = widget.scrollController;
    if (scrollController == null) {
      return KeyedSubtree(
        key: ObjectKey(removedEntity),
        child: buildPositioned(context, child),
      );
    }

    return ListenableBuilder(
      key: ObjectKey(removedEntity),
      listenable: scrollController,
      builder: buildPositioned,
      child: child,
    );
  }

  Widget _buildItem(Widget child, int index) {
    assert(
      child.key is ValueKey,
      'You have to provide a unique ValueKey to every child!',
    );
    final key = child.key as ValueKey;
    _lastBuiltChildren[key.value] = child;
    _builtKeyValues.add(key.value);

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

    return ReorderableSizeChangedListener(
      onSizeChanged: _handleSizeChanged,
      child: ReorderableBuilderItem(
        reorderableEntity: reorderableEntity,
        draggingAnimationMap: _reorderableController.draggingAnimationMap,
        positionChangeDelay: () => _positionChangeDelay,
        animationConfig: widget.animationConfig,
        onOpacityFinished: _handleOpacityFinished,
        onMovingFinished: _handleMovingFinished,
        onCreated: _handleCreatedChild,
        releasedReorderableEntity:
            _reorderableController.releasedReorderableEntity,
        scrollOffset: _scrollOffset,
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
      ),
    );
  }

  ///
  /// Drag and Drop part
  ///

  void _handleDragStarted(ReorderableEntity reorderableEntity) {
    _reorderableController.handleDragStarted(
      reorderableEntity: reorderableEntity,
      currentScrollOffset: _scrollOffset,
      lockedIndices: widget.lockedIndices,
      isScrollableOutside: _isScrollOutside,
      itemCount: widget.itemCount,
    );
    widget.onDragStarted?.call(reorderableEntity.updatedOrderId);

    setState(() {});
  }

  void _handleDragUpdate(PointerMoveEvent pointerMoveEvent) {
    // the scroll position can change while dragging (e.g. auto scroll),
    // so it has to be updated before calculating the new position
    _reorderableController.scrollOffset = _scrollOffset;

    final hasUpdated = _reorderableController.handleDragUpdate(
      pointerMoveEvent: pointerMoveEvent,
    );

    if (hasUpdated) {
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
    Offset? globalOffset,
  ) {
    if (globalOffset != null) {
      var globalRenderObject = context.findRenderObject() as RenderBox;
      var offset = globalRenderObject.globalToLocal(globalOffset);

      // scrollable part is outside this widget
      if (_isScrollOutside) {
        offset -= _scrollOffset;
      }

      // call to ensure animation to dropped item
      _reorderableController.updateReleasedReorderableEntity(
        releasedReorderableEntity: ReleasedReorderableEntity(
          dropOffset: offset,
          reorderableEntity: reorderableEntity,
        ),
      );
    }
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

  void _finishDragging() {
    final draggedEntity = _reorderableController.draggedEntity;
    if (draggedEntity == null) return;

    widget.onDragEnd?.call(draggedEntity.updatedOrderId);

    final reorderUpdateEntities = _reorderableController.handleDragEnd();

    if (reorderUpdateEntities != null) {
      assert(
        (widget.onReorder != null) ^ (widget.onReorderPositions != null),
        'One of either onReorder or onReorderPositions must be provided',
      );

      widget.onReorderPositions?.call(reorderUpdateEntities);

      widget.onReorder?.call(
        (items) => _reorderableController.reorderList(
          items: items,
          reorderUpdateEntities: reorderUpdateEntities,
        ),
      );
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
    ReorderableEntity reorderableEntity,
    GlobalKey key,
  ) {
    final reorderableController = _reorderableController;
    final offsetMap = reorderableController.offsetMap;

    Offset? offset;
    Size size = reorderableEntity.size;

    var index = reorderableEntity.updatedOrderId;
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      size = renderBox.size;

      // should only add offset if it is not existing to prevent wrong animations
      if (offsetMap[index] == null) {
        // translating global offset to the local offset in this widget
        var parentRenderObject = context.findRenderObject() as RenderBox;
        offset = parentRenderObject.globalToLocal(
          renderBox.localToGlobal(Offset.zero),
        );
        offset += _scrollOffset;
      }
    }

    return reorderableController.handleCreatedChild(
      offset: offset,
      reorderableEntity: reorderableEntity,
      size: size,
    );
  }

  /// Called when this widget or one of its children got a new size.
  ///
  /// This can happen e.g. after rotating the device, resizing the window or
  /// changing the tile size or column count of the GridView.
  ///
  /// Cached sizes and offsets would be stale, so all children are re-measured.
  void _handleSizeChanged() {
    if (!mounted) return;

    setState(() {
      _reorderableController.handleSizeChanged();
    });
  }

  ReorderableDragAndDropController get _reorderableController {
    if (widget.children == null) {
      return reorderableItemBuilderController;
    } else {
      return reorderableBuilderController;
    }
  }

  Offset get _scrollOffset {
    return _reorderableScrollable.getScrollOffset(
      reverse: widget.reverse,
    );
  }

  bool get _isScrollOutside {
    return _reorderableScrollable.isScrollOutside;
  }

  ReorderableScrollable get _reorderableScrollable => ReorderableScrollable.of(
        context,
        scrollController: widget.scrollController,
      );
}
