import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_grid_view.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_wrap.dart';

enum ReorderableType {
  wrap,
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
  static const _startCounter = 3;
  final lockedIndices = <int>[2, 4, 5];

  int keyCounter = _startCounter;
  List<int> children = List.generate(_startCounter, (index) => index);
  ReorderableType reorderableType = ReorderableType.wrap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      ContainerButton(
                        onTap: () {
                          if (children.isNotEmpty) {
                            children[0] = 999;
                            setState(() {
                              children = children;
                            });
                          }
                        },
                        color: Colors.deepOrangeAccent,
                        icon: Icons.find_replace,
                      ),
                      ContainerButton(
                        onTap: () {
                          setState(() {
                            children = children..add(keyCounter++);
                          });
                        },
                        color: Colors.green,
                        icon: Icons.add,
                      ),
                      ContainerButton(
                        onTap: () {
                          if (children.isNotEmpty) {
                            setState(() {
                              // children = children..removeLast();
                              children.removeAt(2);
                            });
                          }
                        },
                        color: Colors.red,
                        icon: Icons.remove,
                      ),
                      ContainerButton(
                        onTap: () {
                          if (children.isNotEmpty) {
                            setState(() {
                              children = <int>[];
                            });
                          }
                        },
                        color: Colors.yellowAccent,
                        icon: Icons.delete,
                      ),
                    ],
                  ),
                ),
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
              Expanded(
                child: _getReorderableWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      final draggedItem = children[oldIndex];
      final collisionItem = children[newIndex];
      children[newIndex] = draggedItem;
      children[oldIndex] = collisionItem;
    });
  }

  Widget _getReorderableWidget() {
    final generatedChildren = List<Widget>.generate(
      children.length,
      (index) => Stack(
        children: [
          Positioned(
            child: Container(
              key: Key(children[index].toString()),
              decoration: BoxDecoration(
                color:
                    lockedIndices.contains(index) ? Colors.black : Colors.blue,
              ),
              height: 100.0,
              width: 100.0,
              child: Center(
                child: Text(
                  'test ${children[index]}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    switch (reorderableType) {
      case ReorderableType.wrap:
        return Wrap(
          children: generatedChildren,
        );
        return ReorderableWrap(
          children: generatedChildren,
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
        );
      case ReorderableType.gridView:
        return ReorderableGridView(
          children: generatedChildren,
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 8,
          ),
        );
      case ReorderableType.gridViewCount:
        return ReorderableGridView.count(
          children: generatedChildren,
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          crossAxisCount: 3,
        );
      case ReorderableType.gridViewExtent:
        return ReorderableGridView.extent(
          children: generatedChildren,
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          maxCrossAxisExtent: 2,
        );
      case ReorderableType.gridViewBuilder:
        return ReorderableGridView.builder(
          children: generatedChildren,
          onReorder: _handleReorder,
          lockedIndices: lockedIndices,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 8,
          ),
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
