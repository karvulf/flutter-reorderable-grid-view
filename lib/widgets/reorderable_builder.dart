import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_container.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_scrolling_listener.dart';

typedef DraggableBuilder = Widget Function(
  List<Widget> children,
);

typedef ReorderListCallback = void Function(List<OrderUpdateEntity>);

/// Enables animated drag and drop behaviour for built widgets in [builder].
///
/// Be sure not to replace, add or remove your children while you are dragging
/// because this can lead to an unexpected behavior.
class ReorderableBuilder extends StatefulWidget {
  /// Updating [children] with some widgets to enable animations.
  final List<Widget> children;

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

  /// [BoxDecoration] for the child that is dragged around.
  final BoxDecoration? dragChildBoxDecoration;

  /// Callback to return updated [children].
  final DraggableBuilder builder;

  /// After releasing the dragged child, [onReorder] is called.
  ///
  /// [enableDraggable] has to be true to ensure this is called.
  final ReorderListCallback? onReorder;

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

  /// Controller to get the current scroll position.
  ///
  /// The controller has to be assigned if the returned widget of [widget.builder]
  /// is scrollable to prevent a weird animation behavior or when dragging a child.
  ///
  /// If the scrolling behavior is outside the widget, then the current scroll
  /// position will be detected inside the [context].
  final ScrollController? scrollController;

  ///
  final double automaticScrollExtent;

  const ReorderableBuilder({
    required this.children,
    required this.builder,
    this.onReorder,
    this.lockedIndices = const [],
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.automaticScrollExtent = 80.0,
    this.dragChildBoxDecoration,
    this.initDelay,
    this.onDragStarted,
    this.onDragEnd,
    this.scrollController,
    Key? key,
  })  : assert((enableDraggable && onReorder != null) || !enableDraggable),
        super(key: key);

  @override
  _ReorderableBuilderState createState() => _ReorderableBuilderState();
}

class _ReorderableBuilderState extends State<ReorderableBuilder>
    with WidgetsBindingObserver {
  /// [ReorderableEntity] that is dragged around.
  ReorderableEntity? _draggedReorderableEntity;

  /// Describes all [widget.children] inside the map.
  ///
  /// The key is always the hashCode of the child key. This is a reason
  /// why every child has to have a unique key to prevent misscalculations
  /// for the animation.
  var _childrenMap = <int, ReorderableEntity>{};

  /// For getting easier access, [_offsetMap] holds all known positions with the orderId as key.
  final _offsetMap = <int, Offset>{};

  /// Holding this value here for better performance.
  ///
  /// After dragging a child, [_scrollPositionPixels] is always updated.
  double _scrollPositionPixels = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    var orderId = 0;
    final checkDuplicatedKeyList = <int>[];

    // adding all children for _childrenMap
    for (final child in widget.children) {
      final hashKey = child.key.hashCode;

      if (!checkDuplicatedKeyList.contains(hashKey)) {
        checkDuplicatedKeyList.add(hashKey);
      } else {
        throw Exception('Duplicated key $hashKey found in children');
      }

      _childrenMap[hashKey] = ReorderableEntity(
        child: child,
        originalOrderId: orderId,
        updatedOrderId: orderId,
        isBuilding: true,
      );
      orderId++;
    }
  }

  @override
  void didChangeMetrics() {
    final orientationBefore = MediaQuery.of(context).orientation;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final orientationAfter = MediaQuery.of(context).orientation;
      if (orientationBefore != orientationAfter) {
        // rebuild all items
        for (final entry in _childrenMap.entries) {
          _childrenMap[entry.key] = entry.value.copyWith(isBuilding: true);
        }
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant ReorderableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.children != widget.children) {
      _handleUpdatedChildren();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.builder(_getDraggableChildren());
    return ReorderableScrollingListener(
      isDragging: _draggedReorderableEntity != null,
      scrollableContentKey: child.key as GlobalKey?,
      scrollController: widget.scrollController,
      automaticScrollExtent: widget.automaticScrollExtent,
      onDragUpdate: _checkForCollisions,
      onDragEnd: _handleDragEnd,
      onScrollUpdate: (scrollPixels) {
        _scrollPositionPixels = scrollPixels;
      },
      child: child,
    );
  }

  /// Building a list of [widget.children] wrapped with [ReorderableAnimatedContainer].
  List<Widget> _getDraggableChildren() {
    final draggableChildren = <Widget>[];
    final sortedChildren = _childrenMap.values.toList()
      ..sort((a, b) => a.originalOrderId.compareTo(b.originalOrderId));

    for (final reorderableEntity in sortedChildren) {
      var enableDraggable = widget.enableDraggable;

      if (widget.lockedIndices.contains(reorderableEntity.updatedOrderId)) {
        enableDraggable = false;
      }

      draggableChildren.add(
        ReorderableAnimatedContainer(
          key: Key(reorderableEntity.keyHashCode.toString()),
          reorderableEntity: reorderableEntity,
          isDragging: _draggedReorderableEntity != null,
          onMovingFinished: _handleMovingFinished,
          onOpacityFinished: _handleOpacityFinished,
          child: ReorderableDraggable(
            key: reorderableEntity.child.key,
            draggedReorderableEntity: _draggedReorderableEntity,
            enableLongPress: widget.enableLongPress,
            longPressDelay: widget.longPressDelay,
            enableDraggable: enableDraggable,
            onCreated: _handleCreated,
            onBuilding: _handleBuilding,
            onDragStarted: _handleDragStarted,
            reorderableEntity: reorderableEntity,
            dragChildBoxDecoration: widget.dragChildBoxDecoration,
            initDelay: widget.initDelay,
          ),
        ),
      );
    }

    return draggableChildren;
  }

  /// Adding [Size] and [Offset] to [reorderableEntity] in [_childrenMap].
  ///
  /// When a new child was added to [widget.children], this will be called to
  /// add necessary information about the size and position.
  /// Also isBuilding will be set to false.
  ReorderableEntity? _handleCreated(
    ReorderableEntity reorderableEntity,
    GlobalKey key,
  ) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final offset = _getOffset(
      orderId: reorderableEntity.updatedOrderId,
      renderBox: renderBox,
    );

    if (offset != null) {
      final updatedReorderableEntity = reorderableEntity.copyWith(
        size: renderBox?.size,
        originalOffset: offset,
        updatedOffset: offset,
        isBuilding: false,
      );
      _childrenMap[reorderableEntity.keyHashCode] = updatedReorderableEntity;

      return updatedReorderableEntity;
    }

    return null;
  }

  /// Called immediately when the user starts to drag a child to update current dragged [ReorderableEntity] and scrollPosition.
  void _handleDragStarted(ReorderableEntity reorderableEntity) {
    widget.onDragStarted?.call();
    setState(() {
      _draggedReorderableEntity = reorderableEntity;
      _scrollPositionPixels = _scrollPixels;
    });
  }

  /// Updates orderId and offset of all children in [_childrenMap] and calls [widget.onReorder] at the end.
  ///
  /// When dragging ends, the original orderId and original offset will be
  /// overwritten with the updated values to ensure that every child is positioned
  /// correctly.
  ///
  /// After that, it is possible that the moved the child around a locked index
  /// in [widget.lockedIndices]. To prevent an incorrect order in [widget.children]
  /// when calling [widget.onReorder], a list is created with all necessary
  /// position updates for [widget.children].
  ///
  /// When the list is created, [widget.onReorder] will be called.
  void _handleDragEnd() {
    widget.onDragEnd?.call();

    final oldIndex = _draggedReorderableEntity!.originalOrderId;
    final newIndex = _draggedReorderableEntity!.updatedOrderId;

    // the dragged item has changed position
    if (oldIndex != newIndex) {
      final updatedChildrenMap = <int, ReorderableEntity>{};

      // updating all entries in childrenMap
      for (final childrenMapEntry in _childrenMap.entries) {
        final reorderableEntity = childrenMapEntry.value;
        final updatedEntryValue = childrenMapEntry.value.copyWith(
          originalOrderId: reorderableEntity.updatedOrderId,
          originalOffset: reorderableEntity.updatedOffset,
        );

        updatedChildrenMap[childrenMapEntry.key] = updatedEntryValue;
      }

      _childrenMap = updatedChildrenMap;

      final orderUpdateEntities = _getOrderUpdateEntities(
        oldIndex: oldIndex,
        newIndex: newIndex,
      );
      widget.onReorder!(orderUpdateEntities);
    }

    setState(() {
      _draggedReorderableEntity = null;
    });
  }

  /// Returns a list of all updated positions containing old and new index.
  ///
  /// This method is a special case because of [widget.lockedIndices]. To ensure
  /// that the user reorder [widget.children] correctly, it has to be checked
  /// if there a locked indices between [oldIndex] and [newIndex].
  /// If that's the case, then at least one more [OrderUpdateEntity] will be
  /// added to that list.
  ///
  /// There are two ways when reordering. The order could have changed upwards or
  /// downwards. So if the variable summands is positive, that means the order
  /// changed upwards, e.g. the item was moved from order 0 (=oldIndex) to 4 (=newIndex).
  ///
  /// For every time in this ordering sequence, when a locked index was found,
  /// a new [OrderUpdateEntity] will be added to the returned list. This is
  /// important to reorder all items correctly afterwards.
  ///
  /// E.g. when the oldIndex was 0, the newIndex is 4 and index 2 is locked, then
  /// at least there are two [OrderUpdateEntity] in the list.
  ///
  /// The first one contains always the old and new index. The second one is added
  /// after the locked index.
  ///
  /// So if the oldIndex was 0 and the new index 4, and the locked index is 2,
  /// then the draggedOrderId would be 0. It will be updated after the locked index.
  /// The current collisionId is always the current orderId in the while loop.
  /// After looping through the old index until index 3, then a new [OrderUpdateEntity]
  /// is created. The old index would be the current collisionId with the summands.
  /// Because the summands can be -1 or 1, this calculation works in both directions.
  ///
  /// That means that the oldIndex is 2.
  ///
  /// The newIndex is the current draggedOrderId (= 0) with a notLockedIndicesCounter
  /// multiplied the summands.
  ///
  /// The notLockedIndicesCounter is the number of indices that were before the
  /// locked index. In this case, there are two of them: the index 0 and 1.
  /// So notLockedIndicesCounter would be 1 because the counting starts at index 1
  /// and goes on until 4.
  ///
  /// That results with a new index value of 1.
  ///
  /// So the list with two entities will be returend. The first one with
  /// (0, 4) and (2, 1).
  ///
  /// When the user has the following list items:
  /// ```dart
  /// final listItems = [0, 1, 2, 3, 4]
  /// ```
  /// with a locked index at 2.
  /// When reordering, the user has to iterate through the two items, that would
  /// results in the following code:
  ///
  /// ```dart
  /// for(final orderUpdateEntity in orderUpdateEntities) {
  ///   final item = listItems.removeAt(orderUpdateEntity.oldIndex);
  ///   listItems.insertAt(4, orderUpdateEntity.newIndex);
  /// }
  /// ```
  /// To explain what is happening in this loop:
  ///
  /// The first [OrderUpdateEntity] would order the list to the following list,
  /// when removing at the old index 0 and inserting at new index 4:
  ///
  /// ```dart
  /// [0, 1, 2, 3, 4] -> [1, 2, 3, 4, 0].
  /// ```
  ///
  /// Because the item at index 2 is locked, the number 2 shouldn't change the
  /// position. This is the reason, why there are more than one entity in the list
  /// when having a lockedIndex.
  ///
  /// The second [OrderUpdateEntity] has the oldIndex 2 and newIndex 1:
  ///
  /// ```dart
  /// [1, 2, 3, 4, 0] -> [1, 3, 2, 4, 0].
  /// ```
  ///
  /// Now the ordering is correct. The number 2 is still at the locked index 2.
  List<OrderUpdateEntity> _getOrderUpdateEntities({
    required oldIndex,
    required newIndex,
  }) {
    if (oldIndex == newIndex) return [];

    final orderUpdateEntities = <OrderUpdateEntity>[
      OrderUpdateEntity(oldIndex: oldIndex, newIndex: newIndex),
    ];

    // depends if ordering back or forwards
    final summands = oldIndex > newIndex ? -1 : 1;
    // when a locked index was found, this id will be updated to the index after the locked index
    var currentDraggedOrderId = oldIndex;
    // counting the id upwards or downwards until newIndex was reached
    var currentCollisionOrderId = oldIndex;

    var hasFoundLockedIndex = false;
    // important counter to get a correct value for newIndex when there were multiple not locked indices before a locked index
    var notLockedIndicesCounter = 0;

    // counting currentCollisionOrderId = oldIndex until newIndex
    while (currentCollisionOrderId != newIndex) {
      currentCollisionOrderId += summands;

      if (!widget.lockedIndices.contains(currentCollisionOrderId)) {
        // if there was one or more locked indices, then a new OrderUpdateEntity has to be added
        // this prevents wrong ordering values when calling onReorder
        if (hasFoundLockedIndex) {
          orderUpdateEntities.add(
            OrderUpdateEntity(
              oldIndex: currentCollisionOrderId - summands,
              newIndex:
                  currentDraggedOrderId + notLockedIndicesCounter * summands,
            ),
          );
          currentDraggedOrderId = currentCollisionOrderId;
          hasFoundLockedIndex = false;
          notLockedIndicesCounter = 0;
        } else {
          notLockedIndicesCounter++;
        }
      } else {
        hasFoundLockedIndex = true;
      }
    }

    return orderUpdateEntities;
  }

  /// Looking for any children that collision with the information in [details].
  ///
  /// When a collision was detected, it is possible that one or more children
  /// were between that collision and the dragged child.
  void _checkForCollisions(PointerMoveEvent details) {
    final draggedHashKey = _draggedReorderableEntity!.child.key.hashCode;

    var draggedOffset = Offset(
      details.position.dx,
      details.position.dy + _scrollPositionPixels,
    );

    final collisionMapEntry = _getCollisionMapEntry(
      draggedHashKey: draggedHashKey,
      draggedOffset: draggedOffset,
    );

    if (collisionMapEntry != null &&
        !widget.lockedIndices
            .contains(collisionMapEntry.value.updatedOrderId)) {
      final draggedOrderId = _draggedReorderableEntity!.updatedOrderId;
      final collisionOrderId = collisionMapEntry.value.updatedOrderId;

      final difference = draggedOrderId - collisionOrderId;
      if (difference > 1) {
        _updateMultipleCollisions(
          collisionOrderId: collisionOrderId,
          draggedHashKey: draggedHashKey,
          isBackwards: true,
        );
      } else if (difference < -1) {
        _updateMultipleCollisions(
          collisionOrderId: collisionOrderId,
          draggedHashKey: draggedHashKey,
          isBackwards: false,
        );
      } else {
        _updateCollision(
          draggedHashKey: draggedHashKey,
          collisionMapEntry: collisionMapEntry,
        );
      }
    }
  }

  /// Updates all children that were between the collision and dragged child position.
  void _updateMultipleCollisions({
    required int draggedHashKey,
    required int collisionOrderId,
    required bool isBackwards,
  }) {
    final summands = isBackwards ? -1 : 1;
    var currentCollisionOrderId = _draggedReorderableEntity!.updatedOrderId;

    while (currentCollisionOrderId != collisionOrderId) {
      currentCollisionOrderId += summands;

      if (!widget.lockedIndices.contains(currentCollisionOrderId)) {
        final collisionMapEntry = _childrenMap.entries.firstWhere(
          (entry) => entry.value.updatedOrderId == currentCollisionOrderId,
        );
        _updateCollision(
          draggedHashKey: draggedHashKey,
          collisionMapEntry: collisionMapEntry,
        );
      }
    }
  }

  /// Swapping position and offset between dragged child and collision child.
  ///
  /// The collision is only valid when the orderId of the child is not found in
  /// [widget.lockedIndices].
  ///
  /// When a collision was detected, then the collision child and dragged child
  /// are swapping the position and orderId. At that moment, only the value
  /// updatedOrderId and updatedOffset of [ReorderableEntity] will be updated
  /// to ensure that an animation will be shown.
  void _updateCollision({
    required int draggedHashKey,
    required MapEntry<int, ReorderableEntity> collisionMapEntry,
  }) {
    final collisionOrderId = collisionMapEntry.value.updatedOrderId;
    if (widget.lockedIndices.contains(collisionOrderId)) {
      return;
    }

    // update for collision entity
    final updatedCollisionEntity = collisionMapEntry.value.copyWith(
      updatedOffset: _draggedReorderableEntity!.updatedOffset,
      updatedOrderId: _draggedReorderableEntity!.updatedOrderId,
    );
    _childrenMap[collisionMapEntry.key] = updatedCollisionEntity;

    // update for dragged entity
    final updatedDraggedEntity = _draggedReorderableEntity!.copyWith(
      updatedOffset: collisionMapEntry.value.updatedOffset,
      updatedOrderId: collisionMapEntry.value.updatedOrderId,
    );
    _childrenMap[draggedHashKey] = updatedDraggedEntity;

    setState(() {
      _draggedReorderableEntity = updatedDraggedEntity;
    });
  }

  /// Checking if the dragged child collision with another child in [_childrenMap].
  MapEntry<int, ReorderableEntity>? _getCollisionMapEntry({
    required int draggedHashKey,
    required Offset draggedOffset,
  }) {
    for (final entry in _childrenMap.entries) {
      final localPosition = entry.value.updatedOffset;
      final size = entry.value.size;

      if (entry.key == draggedHashKey) {
        continue;
      }

      // checking collision with full item size and local position
      if (draggedOffset.dx >= localPosition.dx &&
          draggedOffset.dy >= localPosition.dy &&
          draggedOffset.dx <= localPosition.dx + size.width &&
          draggedOffset.dy <= localPosition.dy + size.height) {
        return entry;
      }
    }
    return null;
  }

  /// Returning the current scroll position.
  ///
  /// There are two possibilities to get the scroll position.
  ///
  /// First one is, the returned child of [widget.builder] has a scrollable widget.
  /// In this case, it is important that the [widget._scrollController] is added
  /// to the scrollable widget to get the current scroll position.
  ///
  /// Another possibility is that one of the parents is scrollable.
  /// In that case, the position of the scroll is accessible inside [context].
  ///
  /// Otherwise, 0.0 will be returned.
  // todo: ist jetzt doppelt, geht vlt besser
  double get _scrollPixels {
    var pixels = Scrollable.of(context)?.position.pixels;
    final scrollController = widget.scrollController;

    if (pixels != null) {
      return pixels;
    } else if (scrollController != null && scrollController.hasClients) {
      return scrollController.position.pixels;
    } else {
      return 0.0;
    }
  }

  /// Returns optional calculated [Offset] related to [key].
  ///
  /// If the renderBox for [key] and [_contentGlobalKey] was found,
  /// the offset for [key] inside the renderBox of [_contentGlobalKey]
  /// is calculated. The current scroll position of dy of offset is always
  /// added to return a relative position.
  Offset? _getOffset({
    required int orderId,
    required RenderBox? renderBox,
  }) {
    if (_offsetMap[orderId] != null) {
      return _offsetMap[orderId];
    } else if (renderBox == null) {
      // assert(false, 'RenderBox of child should not be null!');
    } else {
      final localOffset = renderBox.globalToLocal(Offset.zero);

      final offset = Offset(
        localOffset.dx.abs(),
        localOffset.dy.abs() + _scrollPixels,
      );

      _offsetMap[orderId] = offset;

      return offset;
    }

    return null;
  }

  /// Updates all children for [_childrenMap].
  ///
  /// When the child already exists in [_childrenMap], it is checked when the
  /// size of children has changed.
  /// If that's the case and the order of that child has changed, that means
  /// that it has swapped the position with another child and should be animated.
  ///
  /// Also it is possible that the child already exists in [_childrenMap], but
  /// it could has a new position, that is not known inside [_offsetMap].
  /// In that case isBuilding is true and will notify with the size and offset later.
  ///
  /// If the child was totally new, it gets also a flag inside [ReorderableEntity].
  ///
  /// At the end [_childrenMap] gets an update containing all [widget.children]
  /// and theirs new positions.
  void _handleUpdatedChildren() {
    var orderId = 0;
    final updatedChildrenMap = <int, ReorderableEntity>{};
    final addedOrRemovedOrderId = _getRemovedOrAddedOrderId();
    final checkDuplicatedKeyList = <int>[];

    for (final child in widget.children) {
      final keyHashCode = child.key.hashCode;

      if (!checkDuplicatedKeyList.contains(keyHashCode)) {
        checkDuplicatedKeyList.add(keyHashCode);
      } else {
        throw Exception('Duplicated key $keyHashCode found in children');
      }

      var childrenSizeHasChanged = false;
      if (addedOrRemovedOrderId != null) {
        childrenSizeHasChanged = orderId >= addedOrRemovedOrderId;
      }

      // check if child already exists
      if (_childrenMap.containsKey(keyHashCode)) {
        final reorderableEntity = _childrenMap[keyHashCode]!;
        final hasUpdatedOrder = reorderableEntity.originalOrderId != orderId;
        final updatedReorderableEntity = reorderableEntity.copyWith(
          child: child,
          updatedOrderId: orderId,
          updatedOffset: _offsetMap[orderId],
          isBuilding: !_offsetMap.containsKey(orderId),
          isNew: false,
          hasSwappedOrder: hasUpdatedOrder && !childrenSizeHasChanged,
        );
        updatedChildrenMap[keyHashCode] = updatedReorderableEntity;
      } else {
        updatedChildrenMap[keyHashCode] = ReorderableEntity(
          child: child,
          originalOrderId: orderId,
          updatedOrderId: orderId,
          isBuilding: false,
          isNew: true,
        );
      }
      orderId++;
    }
    setState(() {
      _childrenMap = updatedChildrenMap;
    });
  }

  /// Looking for a child that was added or removed.
  ///
  /// When [widget.children] is updated, it is possible that a child was removed
  /// or added. In that case, this method looks for the removed or added child and
  /// returns his orderId.
  int? _getRemovedOrAddedOrderId() {
    if (_childrenMap.length < widget.children.length) {
      var orderId = 0;
      for (final child in widget.children) {
        final keyHashCode = child.key.hashCode;
        if (!_childrenMap.containsKey(keyHashCode)) {
          return orderId;
        }
        orderId++;
      }
    } else if (_childrenMap.length > widget.children.length) {
      var orderId = 0;
      final childrenKeys = widget.children.map((e) => e.key.hashCode).toList();
      for (final key in _childrenMap.keys) {
        if (!childrenKeys.contains(key)) {
          return orderId;
        }
        orderId++;
      }
    }
    return null;
  }

  /// Updates [reorderableEntity] for [_childrenMap] with new [Offset].
  ///
  /// Usually called when the child with [globalKey] was rebuilt or got a new position.
  ReorderableEntity? _handleBuilding(
    ReorderableEntity reorderableEntity,
    GlobalKey globalKey,
  ) {
    final renderBox =
        globalKey.currentContext?.findRenderObject() as RenderBox?;

    final offset = _getOffset(
      renderBox: renderBox,
      orderId: reorderableEntity.updatedOrderId,
    );

    if (offset != null) {
      // updating existing
      final updatedReorderableEntity = reorderableEntity.copyWith(
        updatedOffset: offset,
        size: renderBox?.size,
        isBuilding: false,
      );
      final updatedKeyHashCode = updatedReorderableEntity.keyHashCode;
      _childrenMap[updatedKeyHashCode] = updatedReorderableEntity;

      setState(() {});

      return updatedReorderableEntity;
    }

    return null;
  }

  /// Updating [reorderableEntity] when the child was moved to a new position.
  ///
  /// There is a difference in the update when the child has swapped the position
  /// with another child or has just moved to a new position.
  ///
  /// If there was no swap, then the current offset of [reorderableEntity] is checked.
  /// This update is necessary to prevent wrong positions after moving the child.
  /// This can happen, when there are a lot of updates at the same time in [widget.children].
  void _handleMovingFinished(
    ReorderableEntity reorderableEntity,
    GlobalKey globalKey,
  ) {
    Size? size;
    Offset? updatedOffset = reorderableEntity.updatedOffset;

    if (!reorderableEntity.hasSwappedOrder) {
      final renderBox =
          globalKey.currentContext?.findRenderObject() as RenderBox?;

      updatedOffset = _getOffset(
        renderBox: renderBox,
        orderId: reorderableEntity.updatedOrderId,
      );
      size = renderBox?.size;
    }

    if (updatedOffset != null) {
      _childrenMap[reorderableEntity.keyHashCode] = reorderableEntity.copyWith(
        originalOffset: updatedOffset,
        updatedOffset: updatedOffset,
        size: size,
        originalOrderId: reorderableEntity.updatedOrderId,
        hasSwappedOrder: false,
      );
      setState(() {});
    }
  }

  /// After [reorderableEntity] faded in, the parameter isNew is false.
  void _handleOpacityFinished(int keyHashCode) {
    final reorderableEntity = _childrenMap[keyHashCode]!;
    _childrenMap[keyHashCode] = reorderableEntity.copyWith(
      isNew: false,
    );
  }
}

/*
    ///
    /// some prints for me
    ///

    final draggedOrderIdBefore = _draggedReorderableEntity?.originalOrderId;
    final draggedOrderIdAfter = updatedDraggedEntity.updatedOrderId;

    final draggedOriginalOffset = updatedDraggedEntity.originalOffset;
    final draggedOffsetBefore = _draggedReorderableEntity?.originalOffset;
    final draggedOffsetAfter = updatedDraggedEntity.updatedOffset;

    final collisionOrderIdBefore = collisionMapEntry.value.updatedOrderId;
    final collisionOrderIdAfter = updatedCollisionEntity.updatedOrderId;

    final collisionOriginalOffset = collisionMapEntry.value.originalOffset;
    final collisionOffsetBefore = collisionMapEntry.value.updatedOffset;
    final collisionOffsetAfter = updatedCollisionEntity.updatedOffset;

    print('');
    print('---- Dragged child at position $draggedOrderIdBefore ----');
    print(
        'Dragged child from position $draggedOrderIdBefore to $draggedOrderIdAfter');
    print('Dragged child original offset $draggedOriginalOffset');
    print(
        'Dragged child from offset $draggedOffsetBefore to $draggedOffsetAfter');
    print('----');
    print(
        'Collisioned child from position $collisionOrderIdBefore to $collisionOrderIdAfter');
    print('Collisioned child original offset $collisionOriginalOffset');
    print(
        'Collisioned child from offset $collisionOffsetBefore to $collisionOffsetAfter');
    print('---- END ----');
    print('');

 */
