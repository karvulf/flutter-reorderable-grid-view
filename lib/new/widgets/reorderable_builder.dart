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
  var childrenMap = <int, ReorderableEntity>{};

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      _getDraggableChildren(),
    );
  }

  List<Widget> _getDraggableChildren() {
    final draggableChildren = <Widget>[];

    for (int i = 0; i < widget.children.length; i++) {
      final child = widget.children[i];
      final childMapEntry = childrenMap[child.key.hashCode];
      draggableChildren.add(
        ReorderableAnimatedChild(
          onDragUpdate: _handleDragUpdate,
          child: child,
          onCreated: _handleCreated,
          reorderableEntity: childMapEntry,
          onAnimationEnd: _handleChildAnimationEnd,
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
      final offset = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      childrenMap[hashKey] = ReorderableEntity(
        originalOffset: offset,
        size: size,
      );
      print('Added child $hashKey with position $offset');
    }
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
        ),
      );
      childrenMap[collisionMapEntry.key] = updatedCollisionEntity;

      // update for dragged entity
      final updatedDraggedEntity = draggedReorderableEntity.copyWith(
        reorderableUpdatedEntity: ReorderableUpdatedEntity(
          offset: collisionMapEntry.value.currentOffset,
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
    print('animation ended for ${getChildIndex(hashKey)}');
    final updatedReorderableEntity = ReorderableEntity(
      originalOffset: reorderableEntity.originalOffset,
      size: reorderableEntity.size,
    );
    childrenMap[hashKey] = updatedReorderableEntity;

    final oldIndex = reorderableEntity.reorderableUpdatedEntity?.oldIndex;
    final newIndex = reorderableEntity.reorderableUpdatedEntity?.newIndex;

    if (oldIndex != null && newIndex != null) {
      widget.onReorder(oldIndex, newIndex);
    }
  }

  int getChildIndex(int hashKey) => widget.children.indexWhere(
        (element) => element.key.hashCode == hashKey,
      );
}
