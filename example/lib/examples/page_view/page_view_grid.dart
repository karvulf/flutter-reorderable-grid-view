import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:flutter_reorderable_grid_view_example/examples/playground/playground_child.dart';

/// Reorderable grid of one page with its own children.
class PageViewGrid extends StatefulWidget {
  final Color color;

  const PageViewGrid({required this.color, super.key});

  @override
  State<PageViewGrid> createState() => _PageViewGridState();
}

class _PageViewGridState extends State<PageViewGrid> {
  static const _lockedIndices = [0, 4];
  static const _nonDraggableIndices = [0, 2, 3];

  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();

  var _items = List.generate(200, (index) => index);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      padding: const EdgeInsets.symmetric(vertical: 100),
      child: ReorderableBuilder<int>.builder(
        animationConfig: const ReorderableAnimationConfig(
          positionChangeDuration: Duration(seconds: 1),
        ),
        onReorder: (reorderedListFunction) {
          setState(() => _items = reorderedListFunction(_items));
        },
        lockedIndices: _lockedIndices,
        nonDraggableIndices: _nonDraggableIndices,
        onDragStarted: (index) =>
            _showSnackbar('Dragging at index $index has started!'),
        onUpdatedDraggedChild: (index) =>
            _showSnackbar('Dragged child updated position to $index'),
        onDragEnd: (index) => _showSnackbar('Dragging was finished at $index!'),
        scrollController: _scrollController,
        itemCount: _items.length,
        childBuilder: (itemBuilder) => GridView.builder(
          key: _gridViewKey,
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          itemCount: _items.length,
          itemBuilder: (context, index) => itemBuilder(
            CustomDraggable(
              key: Key(_items[index].toString()),
              data: index,
              child: PlaygroundChild(
                value: _items[index],
                isLocked: _lockedIndices.contains(index),
              ),
            ),
            index,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
        ),
      ),
    );
  }

  void _showSnackbar(String text) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(text, style: const TextStyle(color: Colors.white)),
          backgroundColor: theme.colorScheme.surface,
          duration: const Duration(seconds: 1),
        ),
      );
  }
}
