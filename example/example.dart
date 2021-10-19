import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/flutter_reorderable_grid_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<int> children = <int>[];

  @override
  Widget build(BuildContext context) {
    final lockedChildren = <int>[1];

    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (children.isNotEmpty) {
                          children[0] = 999;
                          setState(() {
                            children = children;
                          });
                        }
                      },
                      child: Container(
                        color: Colors.deepOrangeAccent,
                        height: 100,
                        width: 100,
                        child: const Center(
                          child: Icon(
                            Icons.find_replace,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          children = children..add(children.length);
                        });
                      },
                      child: Container(
                        color: Colors.green,
                        height: 100,
                        width: 100,
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (children.isNotEmpty) {
                          setState(() {
                            children = children..removeLast();
                          });
                        }
                      },
                      child: Container(
                        color: Colors.red,
                        height: 100,
                        width: 100,
                        child: const Center(
                          child: Icon(
                            Icons.remove,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (children.isNotEmpty) {
                          setState(() {
                            children = <int>[];
                          });
                        }
                      },
                      child: Container(
                        color: Colors.yellowAccent,
                        height: 100,
                        width: 100,
                        child: const Center(
                          child: Icon(
                            Icons.delete,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableWrap(
                  enableLongPress: false,
                  lockedChildren: lockedChildren,
                  spacing: 12,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      final draggedItem = children[oldIndex];
                      final collisionItem = children[newIndex];
                      children[newIndex] = draggedItem;
                      children[oldIndex] = collisionItem;
                    });
                  },
                  children: [
                    ...List.generate(
                      children.length,
                      (index) => Container(
                        color: lockedChildren.contains(index)
                            ? Colors.black
                            : Colors.blue,
                        height: 100,
                        width: 100,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
