import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_reorderable_grid_view_example/widgets/change_children_bar.dart';

enum ReorderableType {
  gridView,
  gridViewCount,
  gridViewExtent,
  gridViewBuilder,
}

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _startCounter = 100000;
  final lockedIndices = <int>[1, 3, 9];

  int keyCounter = _startCounter;
  List<int> children = List.generate(_startCounter, (index) => index);
  ReorderableType reorderableType = ReorderableType.gridViewBuilder;

  var _scrollController = ScrollController();
  var _gridViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              ChangeChildrenBar(
                onTapAddChild: () {
                  setState(() {
                    // children = children..add(keyCounter++);
                    children.insert(0, keyCounter++);
                  });
                },
                onTapRemoveChild: () {
                  if (children.isNotEmpty) {
                    setState(() {
                      // children = children..removeLast();
                      children.removeAt(0);
                    });
                  }
                },
                onTapClear: () {
                  if (children.isNotEmpty) {
                    setState(() {
                      children = <int>[];
                    });
                  }
                },
                onTapUpdateChild: () {
                  if (children.isNotEmpty) {
                    children[0] = 999;
                    setState(() {
                      children = children;
                    });
                  }
                },
                onTapSwap: () {
                  final child1 = children[0];
                  final child2 = children[1];
                  children[0] = child2;
                  children[1] = child1;
                  setState(() {});
                },
              ),
              DropdownButton<ReorderableType>(
                value: reorderableType,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                itemHeight: 60,
                underline: Container(
                  height: 2,
                  color: Colors.white,
                ),
                onChanged: (ReorderableType? reorderableType) {
                  setState(() {
                    _scrollController = ScrollController();
                    _gridViewKey = GlobalKey();
                    this.reorderableType = reorderableType!;
                  });
                },
                items: ReorderableType.values.map((e) {
                  return DropdownMenuItem<ReorderableType>(
                    value: e,
                    child: Text(e.toString()),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Expanded(child: _getReorderableWidget()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getReorderableWidget() {
    switch (reorderableType) {
      case ReorderableType.gridView:
        final generatedChildren = _getGeneratedChildren();
        return ReorderableBuilder(
          key: Key(_gridViewKey.toString()),
          children: generatedChildren,
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          onDragStarted: _handleDragStarted,
          onDragEnd: _handleDragEnd,
          scrollController: _scrollController,
          builder: (children) {
            return GridView(
              key: _gridViewKey,
              controller: _scrollController,
              children: children,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 8,
              ),
            );
          },
        );

      case ReorderableType.gridViewCount:
        final generatedChildren = _getGeneratedChildren();
        return ReorderableBuilder(
          key: Key(_gridViewKey.toString()),
          children: generatedChildren,
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          scrollController: _scrollController,
          builder: (children) {
            return GridView.count(
              key: _gridViewKey,
              controller: _scrollController,
              children: children,
              crossAxisCount: 3,
            );
          },
        );
      case ReorderableType.gridViewExtent:
        final generatedChildren = _getGeneratedChildren();
        return ReorderableBuilder(
          key: Key(_gridViewKey.toString()),
          children: generatedChildren,
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          scrollController: _scrollController,
          builder: (children) {
            return GridView.extent(
              key: _gridViewKey,
              controller: _scrollController,
              children: children,
              maxCrossAxisExtent: 200,
              padding: EdgeInsets.zero,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            );
          },
        );

      case ReorderableType.gridViewBuilder:
        return ReorderableBuilder.builder(
          key: Key(_gridViewKey.toString()),
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          onDragStarted: () {
            const snackBar = SnackBar(
              content: Text('Dragging has started!'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          scrollController: _scrollController,
          childBuilder: (itemBuilder) {
            return GridView.builder(
              key: _gridViewKey,
              controller: _scrollController,
              itemCount: children.length,
              itemBuilder: (context, index) {
                return itemBuilder(
                  _getChild(index: index),
                  index,
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 8,
              ),
            );
          },
        );
    }
  }

  List<Widget> _getGeneratedChildren() {
    return List<Widget>.generate(
      children.length,
      (index) => _getChild(index: index),
    );
  }

  Widget _getChild({required int index}) {
    return Container(
      key: Key(children[index].toString()),
      decoration: BoxDecoration(
        color: lockedIndices.contains(index) ? Colors.black : Colors.white,
      ),
      height: 100.0,
      width: 100.0,
      child: Center(
        child: Text(
          'test ${children[index]}',
          style: const TextStyle(),
        ),
      ),
    );
  }

  void _handleDragStarted() {
    ScaffoldMessenger.of(context).clearSnackBars();
    const snackBar = SnackBar(
      content: Text('Dragging has started!'),
      duration: Duration(milliseconds: 1000),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _handleReorder(ReorderedListFunction reorderedListFunction) {
    setState(() {
      children = reorderedListFunction(children) as List<int>;
    });
  }

  void _handleDragEnd() {
    ScaffoldMessenger.of(context).clearSnackBars();
    const snackBar = SnackBar(
      content: Text('Dragging was finished!'),
      duration: Duration(milliseconds: 1000),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
