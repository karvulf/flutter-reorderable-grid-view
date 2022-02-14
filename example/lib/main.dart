import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:flutter_reorderable_grid_view_example/widgets/change_children_bar.dart';

enum ReorderableType {
  wrap,
  gridView,
  gridViewCount,
  gridViewExtent,
  gridViewBuilder,
}

// Todo:
// - Rotieren: alle Positionen neu berechnen
// - Flackern vom letzten neuen Item wegkriegen
// - Tests schreiben
// - mehr dokumentieren
// - read me schöner machen und verständlicher
void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _startCounter = 1;
  final lockedIndices = <int>[];

  int keyCounter = _startCounter;
  List<int> children = List.generate(_startCounter, (index) => index);
  ReorderableType reorderableType = ReorderableType.gridViewCount;

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
                  _handleReorder(1, 2);
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

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      final child = children.removeAt(oldIndex);
      children.insert(newIndex, child);
    });
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
      case ReorderableType.wrap:
        return ReorderableBuilder(
          children: generatedChildren,
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          builder: (children, _) {
            return Wrap(
              key: const Key('wrap'),
              children: children,
            );
          },
        );

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

class ContainerButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final IconData icon;
  final Color color;

  const ContainerButton({
    required this.onTap,
    required this.icon,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: color,
        height: 50,
        width: 50,
        child: Center(
          child: Icon(
            icon,
            size: 20,
          ),
        ),
      ),
    );
  }
}
