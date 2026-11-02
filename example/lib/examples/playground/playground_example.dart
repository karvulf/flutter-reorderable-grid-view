import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_reorderable_grid_view_example/examples/playground/playground_change_children_bar.dart';
import 'package:flutter_reorderable_grid_view_example/examples/playground/playground_reorderable.dart';
import 'package:flutter_reorderable_grid_view_example/examples/playground/playground_type.dart';
import 'package:flutter_reorderable_grid_view_example/examples/playground/playground_type_dropdown.dart';

/// All layouts of [ReorderableBuilder] with locked and non draggable children.
///
/// The bar at the bottom adds, removes, updates and swaps children.
class PlaygroundExample extends StatefulWidget {
  const PlaygroundExample({super.key});

  @override
  State<PlaygroundExample> createState() => _PlaygroundExampleState();
}

class _PlaygroundExampleState extends State<PlaygroundExample> {
  static const _startCounter = 200;
  static const _lockedIndices = [0, 4];
  static const _nonDraggableIndices = [0, 2, 3];

  var _keyCounter = _startCounter;
  var _items = List.generate(_startCounter, (index) => index);
  var _type = PlaygroundType.wrap;

  var _scrollController = ScrollController();
  var _gridViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PlaygroundTypeDropdown(
          value: _type,
          onChanged: (type) => setState(() {
            _scrollController = ScrollController();
            _gridViewKey = GlobalKey();
            _type = type;
          }),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Stack(
          children: [
            PlaygroundReorderable(
              type: _type,
              items: _items,
              lockedIndices: _lockedIndices,
              nonDraggableIndices: _nonDraggableIndices,
              scrollController: _scrollController,
              gridViewKey: _gridViewKey,
              onReorder: (reorderedListFunction) {
                setState(() => _items = reorderedListFunction(_items));
              },
              onDragStarted: (index) =>
                  _showSnackbar('Dragging at index $index has started!'),
              onUpdatedDraggedChild: (index) =>
                  _showSnackbar('Dragged child updated position to $index'),
              onDragEnd: (index) =>
                  _showSnackbar('Dragging was finished at $index!'),
            ),
            PlaygroundChangeChildrenBar(
              onTapAddChild: () => setState(() {
                _items.insert(0, _keyCounter++);
              }),
              onTapRemoveChild: () {
                if (_items.isEmpty) return;
                setState(() => _items.removeAt(0));
              },
              onTapClear: () => setState(() => _items = []),
              onTapUpdateChild: () {
                if (_items.isEmpty) return;
                setState(() => _items[0] = 999);
              },
              onTapSwap: () {
                if (_items.length < 2) return;
                setState(() {
                  _items = [_items[1], _items[0], ..._items.skip(2)];
                });
              },
            ),
          ],
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
