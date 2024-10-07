import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_reorderable_grid_view_example/widgets/change_children_bar.dart';

enum ReorderableType {
  gridView,
  gridViewCount,
  gridViewExtent,
  gridViewBuilder,
}

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xfffaa025),
          surface: const Color(0xff271f16),
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _startCounter = 200;

  final lockedIndices = <int>[0, 4];
  final nonDraggableIndices = [0, 2, 3];

  int keyCounter = _startCounter;
  List<int> children = List.generate(_startCounter, (index) => index);
  ReorderableType reorderableType = ReorderableType.gridViewBuilder;

  var _scrollController = ScrollController();
  var _gridViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<ReorderableType>(
          value: reorderableType,
          icon: const Icon(Icons.arrow_drop_down_rounded),
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
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Stack(
          children: [
            _getReorderableWidget(),
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
          ],
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
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          nonDraggableIndices: nonDraggableIndices,
          onDragStarted: _handleDragStarted,
          onUpdatedDraggedChild: _handleUpdatedDraggedChild,
          onDragEnd: _handleDragEnd,
          scrollController: _scrollController,
          reverse: true,
          children: generatedChildren,
          builder: (children) {
            return GridView(
              key: _gridViewKey,
              controller: _scrollController,
              reverse: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 8,
              ),
              children: children,
            );
          },
        );

      case ReorderableType.gridViewCount:
        final generatedChildren = _getGeneratedChildren();
        return ReorderableBuilder(
          key: Key(_gridViewKey.toString()),
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          nonDraggableIndices: nonDraggableIndices,
          scrollController: _scrollController,
          fadeInDuration: Duration.zero,
          enableLongPress: true,
          children: generatedChildren,
          builder: (children) {
            return GridView.count(
              key: _gridViewKey,
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              children: children,
            );
          },
        );
      case ReorderableType.gridViewExtent:
        final generatedChildren = _getGeneratedChildren();
        return ReorderableBuilder(
          key: Key(_gridViewKey.toString()),
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          nonDraggableIndices: nonDraggableIndices,
          scrollController: _scrollController,
          children: generatedChildren,
          builder: (children) {
            return GridView.extent(
              key: _gridViewKey,
              controller: _scrollController,
              maxCrossAxisExtent: 200,
              padding: EdgeInsets.zero,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: children,
            );
          },
        );

      case ReorderableType.gridViewBuilder:
        return ReorderableBuilder.builder(
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
