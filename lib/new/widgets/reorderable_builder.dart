import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/new/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/new/entities/reorderable_updated_entity.dart';
import 'package:flutter_reorderable_grid_view/new/widgets/reorderable_animated_child.dart';

typedef DraggableBuilder = Widget Function(List<Widget> draggableChildren);

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
  Widget? draggedChild;
  var childrenMap = <int, ReorderableEntity>{};

  var offsetMap = <int, Offset>{};

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
          orderId: counter,
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
    );
  }

  List<Widget> _getDraggableChildren() {
    final draggableChildren = <Widget>[];
    final sortedChildren = childrenMap.values.toList()
      ..sort(
        (a, b) => a.orderId.compareTo(b.orderId),
      );

    for (final reorderableEntity in sortedChildren) {
      draggableChildren.add(
        ReorderableAnimatedChild(
          onDragUpdate: _handleDragUpdate,
          draggedChild: draggedChild,
          onCreated: _handleCreated,
          reorderableEntity: reorderableEntity,
          onAnimationEnd: _handleChildAnimationEnd,
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
      final offset = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      childrenMap[hashKey] = reorderableEntity.copyWith(
        originalOffset: offset,
        size: size,
        reorderableUpdatedEntity: null,
      );
      print('Added child $hashKey with position $offset');
      offsetMap[reorderableEntity.orderId] = offset;
    }
  }

  void _handleDragStarted(Widget child) {
    setState(() {
      draggedChild = child;
    });
  }

  void _handleDragUpdate(int hashKey, DragUpdateDetails details) {
    _checkForCollisions(
      details: details,
      hashKey: hashKey,
    );
  }

  void _checkForCollisions({
    required int hashKey,
    required DragUpdateDetails details,
  }) {
    final draggedReorderableEntity = childrenMap[hashKey]!;
    final draggedOffset = draggedReorderableEntity.currentOffset;

    final collisionMapEntry = _getCollisionMapEntry(
      draggedOffset: draggedOffset,
      details: details,
    );

    if (collisionMapEntry != null && collisionMapEntry.key != hashKey) {
      final draggedIndex = widget.children.indexWhere(
        (element) => element.key.hashCode == hashKey,
      );
      final collisionIndex = widget.children.indexWhere(
        (element) => element.key.hashCode == collisionMapEntry.key,
      );
      print(
          'Dragged index $draggedIndex detected collision with $collisionIndex');

      // update for collision entity
      final updatedCollisionEntity = collisionMapEntry.value.copyWith(
        reorderableUpdatedEntity: ReorderableUpdatedEntity(
          offset: draggedOffset,
          oldIndex: draggedIndex,
          newIndex: collisionIndex,
          newOrderId: draggedReorderableEntity.orderId,
        ),
      );
      childrenMap[collisionMapEntry.key] = updatedCollisionEntity;

      // update for dragged entity
      final updatedDraggedEntity = draggedReorderableEntity.copyWith(
        reorderableUpdatedEntity: ReorderableUpdatedEntity(
          offset: collisionMapEntry.value.currentOffset,
          newOrderId: collisionMapEntry.value.orderId,
        ),
      );
      childrenMap[hashKey] = updatedDraggedEntity;
      setState(() {});
    }
  }

  MapEntry<int, ReorderableEntity>? _getCollisionMapEntry({
    required Offset draggedOffset,
    required DragUpdateDetails details,
  }) {
    for (final entry in childrenMap.entries) {
      final localPosition = entry.value.originalOffset;
      final size = entry.value.size;

      if (draggedOffset == localPosition) {
        continue;
      }

      // checking collision with full item size and local position
      if (details.localPosition.dx >= localPosition.dx &&
          details.localPosition.dy >= localPosition.dy &&
          details.localPosition.dx <= localPosition.dx + size.width &&
          details.localPosition.dy <= localPosition.dy + size.height) {
        return entry;
      }
    }
  }

  void _handleChildAnimationEnd(
    int hashKey,
    ReorderableEntity reorderableEntity,
  ) {
    final reorderableEntity = childrenMap[hashKey]!;

    final oldIndex = reorderableEntity.reorderableUpdatedEntity?.oldIndex;
    final newIndex = reorderableEntity.reorderableUpdatedEntity?.newIndex;

    if (oldIndex != null && newIndex != null) {
      // widget.onReorder(oldIndex, newIndex);
    }

    final newOrderId = reorderableEntity.reorderableUpdatedEntity?.newOrderId;
    if (newOrderId != null) {
      childrenMap[hashKey] = reorderableEntity.copyWith(
        orderId: newOrderId,
        originalOffset: offsetMap[newOrderId]!,
        reorderableUpdatedEntity: null,
      );
    }
  }

  int getChildIndex(int hashKey) => widget.children.indexWhere(
        (element) => element.key.hashCode == hashKey,
      );

  /// Updates all children in map when dragging ends.
  ///
  /// Every updated child gets a new offset and orderId.
  void _handleDragEnd(DraggableDetails details) {
    var counter = 0;

    for (final child in widget.children) {
      final hashKey = child.key.hashCode;
      final reorderableEntity = childrenMap[hashKey];

      if (reorderableEntity != null) {
        childrenMap[hashKey] = reorderableEntity.copyWith(
          child: child,
          orderId: counter,
          originalOffset: offsetMap[counter]!,
          reorderableUpdatedEntity: null,
        );
      }
      counter++;
    }

    setState(() {
      draggedChild = null;
    });
  }
}
