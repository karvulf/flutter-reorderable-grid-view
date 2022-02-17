import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_container.dart';

typedef DraggableBuilder = Widget Function(
  List<Widget> children,
  ScrollController scrollController,
);

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

  void _handleDragStarted(ReorderableEntity reorderableEntity) {
    setState(() {
      _draggedReorderableEntity = reorderableEntity;
      _scrollPositionPixels = _scrollPixels;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _checkForCollisions(details: details);
  }

  /// Updates all children in map when dragging ends.
  ///
  /// Every updated child gets a new offset and orderId.
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

    if (oldIndex != newIndex && widget.onReorder != null) {
      widget.onReorder!(oldIndex, newIndex);
    }
  }

  /// some more logical functions

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
  /// First one is, that the built child is scrollable.
  /// In this case, it is important, the [_scrollController] is added
  /// to the scrollable child.
  ///
  /// Another possibility is that one of the parents is scrollable.
  /// In that case, the position of the scroll is accessible inside [context].
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
  /// is calculated.
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
    // Todo dupliacted key überprüfung rein
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
