import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: ExampleDragAndDropGridView()));
}

class ExampleDragAndDropGridView extends StatefulWidget {
  const ExampleDragAndDropGridView({Key? key}) : super(key: key);

  @override
  State<ExampleDragAndDropGridView> createState() =>
      _ExampleDragAndDropGridViewState();
}

class _ExampleDragAndDropGridViewState
    extends State<ExampleDragAndDropGridView> {
  final fruits = <String>["banana", "apple", "strawberry"];

  @override
  Widget build(BuildContext context) {
    final children = List.generate(
      fruits.length,
      (index) {
        final fruit = fruits.elementAt(index);
        return Container(
          key: Key(fruit),
          alignment: Alignment.center,
          color: Colors.white,
          child: Text(fruit),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white70,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView(
          children: children,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 8,
          ),
        ),
      ),
    );
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      final child = fruits.removeAt(oldIndex);
      fruits.insert(newIndex, child);
    });
  }
}
