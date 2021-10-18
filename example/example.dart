import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_grid_view.dart';

/// Example how you should act when updating the children.
///
/// In this example, you can add, remove or clear all children.
///
/// Also there is a button to update the first child text to 999 to see that
/// you still get the updated children that are added to the GridView.
///
/// If you reorder the children, you have an example how you should make use
/// of the onUpdate function.
///
/// The black square is locked and can't be moved because it was added to
/// lockedChildren.
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(width: 20),
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
                  const SizedBox(width: 20),
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
                  const SizedBox(width: 20),
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
              child: ReorderableGridView(
                enableLongPress: false,
                lockedChildren: lockedChildren,
                spacing: 12,
                onUpdate: (int oldIndex, int newIndex) {
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
    );
  }
}
