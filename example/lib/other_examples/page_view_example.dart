import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return RecorderableItem(
            color: Colors.primaries[index],
          );
        },
      ),
    );
  }
}

class RecorderableItem extends StatefulWidget {
  final Color color;

  const RecorderableItem({super.key, required this.color});

  @override
  State<RecorderableItem> createState() => _RecorderableItemState();
}

class _RecorderableItemState extends State<RecorderableItem> {
  static const _startCounter = 200;

  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();
  final lockedIndices = <int>[0, 4];
  final nonDraggableIndices = [0, 2, 3];

  List<int> children = List.generate(_startCounter, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      padding: const EdgeInsets.symmetric(vertical: 100),
      child: ReorderableBuilder.builder(
        key: Key(_gridViewKey.toString()),
        positionDuration: const Duration(seconds: 1),
        onReorder: _handleReorder,
        lockedIndices: lockedIndices,
        nonDraggableIndices: nonDraggableIndices,
        onDragStarted: _handleDragStarted,
        onUpdatedDraggedChild: _handleUpdatedDraggedChild,
        onDragEnd: _handleDragEnd,
        scrollController: _scrollController,
        childBuilder: (itemBuilder) {
          return GridView.builder(
            key: _gridViewKey,
            scrollDirection: Axis.vertical,
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: children.length,
            itemBuilder: (context, index) {
              return itemBuilder(
                _getChild(index: index),
                index,
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
          );
        },
      ),
    );
  }

  Widget _getChild({required int index}) {
    return CustomDraggable(
      key: Key(children[index].toString()),
      data: index,
      child: Container(
        decoration: BoxDecoration(
          color: lockedIndices.contains(index)
              ? Theme.of(context).disabledColor
              : Theme.of(context).colorScheme.primary,
        ),
        height: 100.0,
        width: 100.0,
        child: Center(
          child: Text(
            '${children[index]}',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _handleDragStarted(int index) {
    _showSnackbar(text: 'Dragging at index $index has started!');
  }

  void _handleUpdatedDraggedChild(int index) {
    _showSnackbar(text: 'Dragged child updated position to $index');
  }

  void _handleReorder(ReorderedListFunction reorderedListFunction) {
    setState(() {
      children = reorderedListFunction(children) as List<int>;
    });
  }

  void _handleDragEnd(int index) {
    _showSnackbar(text: 'Dragging was finished at $index!');
  }

  void _showSnackbar({required String text}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snackBar = SnackBar(
      content: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      duration: const Duration(milliseconds: 1000),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
