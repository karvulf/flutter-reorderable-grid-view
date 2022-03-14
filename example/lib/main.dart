import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
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
  static const _startCounter = 4;
  final lockedIndices = <int>[0];

  int keyCounter = _startCounter;
  List<int> children = List.generate(_startCounter, (index) => index);
  ReorderableType reorderableType = ReorderableType.gridViewExtent;

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
                    const OrderUpdateEntity(oldIndex: 0, newIndex: 2),
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
        height: 100.0,
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
          children: generatedChildren,
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          builder: (children, scrollController) {
            return GridView(
              controller: scrollController,
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
          children: generatedChildren,
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          builder: (children, scrollController) {
            return GridView.count(
              controller: scrollController,
              key: const Key('count'),
              children: children,
              crossAxisCount: 3,
            );
          },
        );

      case ReorderableType.gridViewExtent:
        return ReorderableBuilder(
          children: generatedChildren,
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          builder: (children, scrollController) {
            return GridView.extent(
              controller: scrollController,
              key: const Key('extent'),
              children: children,
              maxCrossAxisExtent: 200,
              padding: EdgeInsets.zero,
              clipBehavior: Clip.none,
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
          builder: (children, scrollController) {
            return GridView.builder(
              key: const Key('builder'),
              controller: scrollController,
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
    }
  }
}
