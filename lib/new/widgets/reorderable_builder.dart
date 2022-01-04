import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/new/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/new/widgets/reorderable_draggable.dart';

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
      draggableChildren.add(
        ReorderableDraggable(
          child: child,
          orderId: i,
          onCreated: _handleCreated,
          onDragUpdate: _handleDragUpdate,
        ),
      );
    }

    return draggableChildren;
  }

  void _handleCreated(int orderId, GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      assert(false, 'RenderBox of child should not be null!');
    } else {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      childrenMap[orderId] = ReorderableEntity(
        position: position,
        size: size,
      );
      print('Added child $orderId with position $position');
    }
  }

  void _handleDragUpdate(int orderId, DragUpdateDetails details) {
    final updatedMap = _checkForCollisions(
      details: details,
      orderId: orderId,
    );
  }

  void _checkForCollisions({
    required int orderId,
    required DragUpdateDetails details,
  }) {
    final collisionMapEntry = _getCollisionMapEntry(
      orderId: orderId,
      details: details,
    );

    if (collisionMapEntry != null && collisionMapEntry.key != orderId) {
      print('collision detected with orderId ${collisionMapEntry.key}');
      // update all items and notify change
    }
  }

  MapEntry<int, ReorderableEntity>? _getCollisionMapEntry({
    required int orderId,
    required DragUpdateDetails details,
  }) {
    final draggedPosition = childrenMap[orderId]!.position;

    for (final entry in childrenMap.entries) {
      final localPosition = entry.value.position;
      final size = entry.value.size;

      if (draggedPosition == localPosition) {
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
}
