import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:flutter_reorderable_grid_view_example/widgets/change_children_bar.dart';

enum ReorderableType {
  gridView,
  gridViewCount,
  gridViewExtent,
  gridViewBuilder,
  wrap,
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
  static const _startCounter = 2;
  final lockedIndices = <int>[];

  int keyCounter = _startCounter;
  List<int> children = List.generate(_startCounter, (index) => index);
  ReorderableType reorderableType = ReorderableType.wrap;

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
                  _handleReorder([
                    const OrderUpdateEntity(oldIndex: 0, newIndex: 1),
                  ]);
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

  void _handleReorder(List<OrderUpdateEntity> onReorderList) {
    for (final reorder in onReorderList) {
      final child = children.removeAt(reorder.oldIndex);
      children.insert(reorder.newIndex, child);
    }
    setState(() {});
  }

  Widget _getReorderableWidget() {
    final generatedChildren = List<Widget>.generate(
      children.length,
      (index) => Container(
        key: Key(children[index].toString()),
        decoration: BoxDecoration(
          color: lockedIndices.contains(index) ? Colors.black : Colors.white,
        ),
        height: 100.0 + (index * 10),
        width: 100.0,
        child: Center(
          child: Text(
            'test ${children[index]}',
            style: const TextStyle(),
          ),
        ),
      ),
    );

    switch (reorderableType) {
      case ReorderableType.gridView:
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
        return ReorderableBuilder(
          children: generatedChildren,
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          onDragStarted: () {
            const snackBar = SnackBar(
              content: Text('Dragging has started!'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          scrollController: _scrollController,
          builder: (children) {
            return GridView.builder(
              key: _gridViewKey,
              controller: _scrollController,
              itemCount: children.length,
              itemBuilder: (context, index) {
                return children[index];
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 8,
              ),
            );
          },
        );
      case ReorderableType.wrap:
        return const ReorderableWrapChipPage();
    }
  }

  void _handleDragStarted() {
    ScaffoldMessenger.of(context).clearSnackBars();
    const snackBar = SnackBar(
      content: Text('Dragging has started!'),
      duration: Duration(milliseconds: 1000),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

class ReorderableWrapChipPage extends StatefulWidget {
  const ReorderableWrapChipPage({Key? key}) : super(key: key);

  @override
  State<ReorderableWrapChipPage> createState() =>
      _ReorderableWrapChipPageState();
}

class _ReorderableWrapChipPageState extends State<ReorderableWrapChipPage> {
  final _wrapKey = GlobalKey();
  final _textEditingController = TextEditingController();
  final focusNode = FocusNode();

  final _names = <String>[
    'abc',
    'abcd',
    'aa',
    'fdsaf',
    'sdfaf',
    'dfd',
    'dfsafafda',
    'ddsaw',
    '_textfield_'
  ];

  @override
  Widget build(BuildContext context) {
    const normal = false;
    final unmodifiedChildren = _getChildren();
    if (normal) {
      return Scaffold(
        body: Container(
          key: _wrapKey,
          color: Colors.green,
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: unmodifiedChildren,
          ),
        ),
      );
    }
    return Scaffold(
      body: ReorderableBuilder(
        children: unmodifiedChildren,
        lockedIndices: [unmodifiedChildren.length - 1],
        onReorder: _handleReorder,
        builder: (children) {
          return Container(
            key: _wrapKey,
            color: Colors.blue,
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: children,
            ),
          );
        },
      ),
    );
  }

  List<Widget> _getChildren() {
    final children = <Widget>[];
    children.addAll(_names.map((e) => Chip(
          key: Key(e),
          label: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(e),
          ),
        )));
    children.add(
      Chip(
        key: const Key('chip-text-field'),
        label: SizedBox(
          width: 100.0,
          child: TextField(
            controller: _textEditingController,
            focusNode: focusNode,
            onSubmitted: (value) {
              if (value.isNotEmpty && !_names.contains(value)) {
                setState(() {
                  _names.add(value);
                });
              }
              _textEditingController.clear();
              FocusScope.of(context).requestFocus(focusNode);
            },
          ),
        ),
      ),
    );

    return children;
  }

  void _handleReorder(List<OrderUpdateEntity> onReorderList) {
    for (final reorder in onReorderList) {
      final child = _names.removeAt(reorder.oldIndex);
      _names.insert(reorder.newIndex, child);
    }
    setState(() {});
  }
}
