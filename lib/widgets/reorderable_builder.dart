import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_container.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_draggable.dart';

typedef DraggableBuilder = Widget Function(
  List<Widget> children,
  ScrollController scrollController,
);

typedef ReorderCallback = void Function(List<OrderUpdateEntity>);

/// Enables animated drag and drop behaviour for built widgets in [builder].
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
  final ReorderCallback? onReorder;

  const ReorderableBuilder({
    required this.children,
    required this.builder,
    this.onReorder,
    this.lockedIndices = const [],
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.dragChildBoxDecoration,
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

  /// [_scrollController] to get the scroll position in vertical direction of the widget of [widget.builder].
  ///
  /// The controller has to be assigned if the returned widget of [widget.builder]
  /// is scrollable to prevent a weird animation behavior or when dragging a child.
  final ScrollController _scrollController = ScrollController();

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
        // Todo: Logik noch hinzufügen
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
    return widget.builder(
      _getDraggableChildren(),
      _scrollController,
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
            onDragUpdate: _handleDragUpdate,
            onCreated: _handleCreated,
            onBuilding: _handleBuilding,
            onDragStarted: _handleDragStarted,
            onDragEnd: _handleDragEnd,
            reorderableEntity: reorderableEntity,
            dragChildBoxDecoration: widget.dragChildBoxDecoration,
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
      _offsetMap[reorderableEntity.updatedOrderId] = offset;

      return updatedReorderableEntity;
    }

    return null;
  }

  /// Called immediately when the user starts to drag a child to update current dragged [ReorderableEntity] and scrollPosition.
  void _handleDragStarted(ReorderableEntity reorderableEntity) {
    setState(() {
      _draggedReorderableEntity = reorderableEntity;
      _scrollPositionPixels = _scrollPixels;
    });
  }

  /// Always called when the user moves the dragged child around.
  void _handleDragUpdate(DragUpdateDetails details) {
    _checkForCollisions(details: details);
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
  void _handleDragEnd(DraggableDetails details) {
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
    }

    setState(() {
      _draggedReorderableEntity = null;
    });

    final orderUpdateEntities = _getOrderUpdateEntities(
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
    widget.onReorder!(orderUpdateEntities);
  }

  /// Returns a list of all updated positions containing old and new index.
  ///
  /// This method is a special case because of [widget.lockedIndices]. To ensure
  /// that the user reorder [widget.children] correctly, it has to be checked
  /// if there a locked indices between [oldIndex] and [newIndex].
  /// If that's the case, then at least one more [OrderUpdateEntity] will be
  /// added to that list.
  ///
  /// Todo: Berechnung muss erklärt werden
  List<OrderUpdateEntity> _getOrderUpdateEntities({
    required oldIndex,
    required newIndex,
  }) {
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
        }
        notLockedIndicesCounter++;
      } else {
        hasFoundLockedIndex = true;
      }
    }

    return orderUpdateEntities;
  }

  /// some more logical functions

  /// Looking for any children that collision with the information in [details].
  ///
  /// When a collision was detected, it is possible that one or more children
  /// were between that collision and the dragged child.
  void _checkForCollisions({
    required DragUpdateDetails details,
  }) {
    final draggedHashKey = _draggedReorderableEntity!.child.key.hashCode;

    var draggedOffset = Offset(
      details.localPosition.dx,
      details.localPosition.dy + _scrollPositionPixels,
    );

    final collisionMapEntry = _getCollisionMapEntry(
      draggedHashKey: draggedHashKey,
      draggedOffset: draggedOffset,
    );

    if (collisionMapEntry != null) {
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
  /// In this case, it is important that the [_scrollController] is added
  /// to the scrollable widget to get the current scroll position.
  ///
  /// Another possibility is that one of the parents is scrollable.
  /// In that case, the position of the scroll is accessible inside [context].
  ///
  /// Otherwise, 0.0 will be returned.
  double get _scrollPixels {
    var pixels = Scrollable.of(context)?.position.pixels;
    if (pixels != null) {
      return pixels;
    } else if (_scrollController.hasClients) {
      return _scrollController.position.pixels;
    } else {
      return 0.0;
    }
  }

  ///
  /// NEW
  ///

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
    if (renderBox == null) {
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
  /// If the length of children was the same, the originalOrderId and
  /// originalOffset will also be updated to prevent a moving animation.
  /// This case can happen, e. g. after a drag and drop, when the children
  /// change theirs position.
  void _handleUpdatedChildren() {
    var orderId = 0;
    final updatedChildrenMap = <int, ReorderableEntity>{};
    final addedOrRemovedOrderId = _getRemovedOrAddedOrderId();
    // Todo duplicated key überprüfung rein
    for (final child in widget.children) {
      final keyHashCode = child.key.hashCode;
      var sizeHasChanged = false;
      if (addedOrRemovedOrderId != null) {
        sizeHasChanged = orderId >= addedOrRemovedOrderId;
      }

      // check if child already exists
      if (_childrenMap.containsKey(keyHashCode)) {
        final reorderableEntity = _childrenMap[keyHashCode]!;
        bool hasUpdatedOrder = reorderableEntity.originalOrderId != orderId;
        final updatedReorderableEntity = reorderableEntity.copyWith(
          child: child,
          updatedOrderId: orderId,
          updatedOffset: _offsetMap[orderId],
          isBuilding: !_offsetMap.containsKey(orderId),
          isNew: false,
          hasSwappedOrder: hasUpdatedOrder && !sizeHasChanged,
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
  /// Usually called when the child with [key] was rebuilt or got a new position.
  ReorderableEntity? _handleBuilding(
    ReorderableEntity reorderableEntity,
    GlobalKey key,
  ) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    final offset = _getOffset(
      renderBox: renderBox,
      orderId: reorderableEntity.updatedOrderId,
    );

    if (offset != null) {
      // updating existing
      final updatedReorderableEntity = reorderableEntity.copyWith(
        updatedOffset: offset,
        isBuilding: false,
      );
      final updatedKeyHashCode = updatedReorderableEntity.keyHashCode;
      _childrenMap[updatedKeyHashCode] = updatedReorderableEntity;

      setState(() {});

      return updatedReorderableEntity;
    }

    return null;
  }

  /// After [reorderableEntity] moved to the new position, the offset and orderId get an update.
  void _handleMovingFinished(int keyHashCode) {
    final reorderableEntity = _childrenMap[keyHashCode]!;

    _childrenMap[keyHashCode] = reorderableEntity.copyWith(
      originalOffset: reorderableEntity.updatedOffset,
      originalOrderId: reorderableEntity.updatedOrderId,
    );
    setState(() {});
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

    final draggedOrderIdBefore = draggedReorderableEntity?.updatedOrderId;
    final draggedOrderIdAfter = updatedDraggedEntity.updatedOrderId;

    final draggedOriginalOffset = updatedDraggedEntity.originalOffset;
    final draggedOffsetBefore = draggedReorderableEntity?.updatedOffset;
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
