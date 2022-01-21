import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/new/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/new/widgets/reorderable_animated_child.dart';

typedef DraggableBuilder = Widget Function(
  List<Widget> draggableChildren,
  ScrollController scrollController,
);

class ReorderableBuilder extends StatefulWidget {
  final List<Widget> children;
  final DraggableBuilder builder;
  final ReorderCallback onReorder;

  const ReorderableBuilder({
    required this.children,
    required this.builder,
    required this.onReorder,
    Key? key,
  }) : super(key: key);

  @override
  _ReorderableBuilderState createState() => _ReorderableBuilderState();
}

class _ReorderableBuilderState extends State<ReorderableBuilder> {
  final _scrollController = ScrollController();

  ReorderableEntity? draggedReorderableEntity;

  var childrenMap = <int, ReorderableEntity>{};

  var offsetMap = <int, Offset>{};

  double scrollPositionPixels = 0.0;

  @override
  void initState() {
    super.initState();

    _updateChildren();
  }

  @override
  void didUpdateWidget(covariant ReorderableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.children.length != widget.children.length) {
      _updateChildren();
    }
  }

  void _updateChildren() {
    var counter = 0;

    final checkDuplicatedKeyList = <int>[];

    for (final child in widget.children) {
      final hashKey = child.key.hashCode;

      if (!checkDuplicatedKeyList.contains(hashKey)) {
        checkDuplicatedKeyList.add(hashKey);
      } else {
        throw Exception('Duplicated key $hashKey found in children');
      }

      final reorderableEntity = childrenMap[hashKey];

      if (reorderableEntity == null) {
        childrenMap[hashKey] = ReorderableEntity(
          child: child,
          originalOrderId: counter,
          updatedOrderId: counter,
        );
      }

      counter++;
    }
    setState(() {});
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
    final sortedChildren = childrenMap.values.toList()
      ..sort((a, b) => a.originalOrderId.compareTo(b.originalOrderId));

    for (final reorderableEntity in sortedChildren) {
      draggableChildren.add(
        ReorderableAnimatedChild(
          draggedReorderableEntity: draggedReorderableEntity,
          reorderableEntity: reorderableEntity,
          onDragUpdate: _handleDragUpdate,
          onCreated: _handleCreated,
          onDragStarted: _handleDragStarted,
          onDragEnd: _handleDragEnd,
        ),
      );
    }

    return draggableChildren;
  }

  void _handleCreated(int hashKey, GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      assert(false, 'RenderBox of child should not be null!');
    } else {
      final reorderableEntity = childrenMap[hashKey]!;
      final localOffset = renderBox.localToGlobal(Offset.zero);
      final offset = Offset(
        localOffset.dx,
        localOffset.dy + _scrollController.position.pixels,
      );
      final size = renderBox.size;
      childrenMap[hashKey] = reorderableEntity.copyWith(
        size: size,
        originalOffset: offset,
        updatedOffset: offset,
      );
      print('Added child $hashKey with offset $offset');
      offsetMap[reorderableEntity.updatedOrderId] = offset;
    }
  }

  void _handleDragStarted(ReorderableEntity reorderableEntity) {
    print('scrollPositionPixels ${_scrollController.position.pixels}');
    setState(() {
      draggedReorderableEntity = reorderableEntity;
      scrollPositionPixels = _scrollController.position.pixels;
    });
  }

  void _handleDragUpdate(int hashKey, DragUpdateDetails details) {
    _checkForCollisions(details: details);
  }

  /// Updates all children in map when dragging ends.
  ///
  /// Every updated child gets a new offset and orderId.
  void _handleDragEnd(DraggableDetails details) {
    int? oldIndex;
    int? newIndex;

    final originalOffset = draggedReorderableEntity!.originalOffset;
    final updatedOffset = draggedReorderableEntity!.updatedOffset;

    // the dragged item has changed position
    if (originalOffset != updatedOffset) {
      // looking for the old and new index
      for (final offsetMapEntry in offsetMap.entries) {
        final offset = offsetMapEntry.value;

        if (offset == draggedReorderableEntity!.originalOffset) {
          oldIndex = offsetMapEntry.key;
        } else if (offset == draggedReorderableEntity!.updatedOffset) {
          newIndex = offsetMapEntry.key;
        }

        if (oldIndex != 0 && newIndex != 0) {
          break;
        }
      }

      final updatedChildrenMap = <int, ReorderableEntity>{};

      // updating all entries in childrenMap
      for (final childrenMapEntry in childrenMap.entries) {
        final reorderableEntity = childrenMapEntry.value;

        final updatedEntryValue = childrenMapEntry.value.copyWith(
          originalOrderId: reorderableEntity.updatedOrderId,
          originalOffset: reorderableEntity.updatedOffset,
        );

        updatedChildrenMap[childrenMapEntry.key] = updatedEntryValue;
      }

      childrenMap = updatedChildrenMap;
    } else {
      print('No update while reordering children!');
    }

    setState(() {
      draggedReorderableEntity = null;
    });

    if (oldIndex != null && newIndex != null) {
      widget.onReorder(oldIndex, newIndex);
    }
  }

  /// some more logical functions

  void _checkForCollisions({
    required DragUpdateDetails details,
  }) {
    final draggedHashKey = draggedReorderableEntity!.child.key.hashCode;

    var draggedOffset = Offset(
      details.localPosition.dx,
      details.localPosition.dy + scrollPositionPixels,
    );

    final collisionMapEntry = _getCollisionMapEntry(
      draggedHashKey: draggedHashKey,
      draggedOffset: draggedOffset,
    );

    if (collisionMapEntry != null) {
      final draggedOrderId = draggedReorderableEntity!.updatedOrderId;
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
    while (draggedReorderableEntity!.updatedOrderId != collisionOrderId) {
      final summands = isBackwards ? -1 : 1;
      final collisionMapEntry = childrenMap.entries.firstWhere((entry) =>
          entry.value.updatedOrderId ==
          draggedReorderableEntity!.updatedOrderId + summands);

      _updateCollision(
        draggedHashKey: draggedHashKey,
        collisionMapEntry: collisionMapEntry,
      );
    }
  }

  void _updateCollision({
    required int draggedHashKey,
    required MapEntry<int, ReorderableEntity> collisionMapEntry,
  }) {
    // update for collision entity
    final updatedCollisionEntity = collisionMapEntry.value.copyWith(
      updatedOffset: draggedReorderableEntity!.updatedOffset,
      updatedOrderId: draggedReorderableEntity!.updatedOrderId,
    );
    childrenMap[collisionMapEntry.key] = updatedCollisionEntity;

    // update for dragged entity
    final updatedDraggedEntity = draggedReorderableEntity!.copyWith(
      updatedOffset: collisionMapEntry.value.updatedOffset,
      updatedOrderId: collisionMapEntry.value.updatedOrderId,
    );
    childrenMap[draggedHashKey] = updatedDraggedEntity;

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

    setState(() {
      draggedReorderableEntity = updatedDraggedEntity;
    });
  }

  MapEntry<int, ReorderableEntity>? _getCollisionMapEntry({
    required int draggedHashKey,
    required Offset draggedOffset,
  }) {
    for (final entry in childrenMap.entries) {
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
  }
}

/**
    ///
    /// some prints for me
    ///

    final draggedOrderIdBefore = draggedReorderableEntity.updatedOrderId;
    final draggedOrderIdAfter = updatedDraggedEntity.updatedOrderId;

    final collisionOrderIdBefore = collisionMapEntry.value.updatedOrderId;
    final collisionOrderIdAfter = updatedCollisionEntity.updatedOrderId;

    print('');
    print('---- Dragged child at position $draggedOrderIdBefore ----');
    print(
    'Dragged child from position $draggedOrderIdBefore to $draggedOrderIdAfter');
    print(
    'Collisioned child from position $collisionOrderIdBefore to $collisionOrderIdAfter');
    print('---- END ----');
    print('');
 */
