import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

void main() {
  runApp(const MaterialApp(home: ExampleAnimatedDragAndDropGridView()));
}

class ExampleAnimatedDragAndDropGridView extends StatefulWidget {
  const ExampleAnimatedDragAndDropGridView({Key? key}) : super(key: key);

  @override
  State<ExampleAnimatedDragAndDropGridView> createState() =>
      _ExampleAnimatedGridViewState();
}

class _ExampleAnimatedGridViewState
    extends State<ExampleAnimatedDragAndDropGridView> {
  final fruits = <String>["banana", "apple", "strawberry"];
  bool hasAdded = false;

  @override
  Widget build(BuildContext context) {
    final children = List.generate(
      fruits.length,
      (index) {
        final fruit = fruits.elementAt(index);
        return InkWell(
          key: Key(fruit),
          onTap: () => _handleReorder(
            index,
            index == fruits.length - 1 ? 0 : index + 1,
          ),
          child: Container(
            key: Key(fruit),
            alignment: Alignment.center,
            color: Colors.white,
            child: Text(fruit),
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white70,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ReorderableBuilder(
          children: children,
          onReorder: _handleReorder,
          builder: (children, scrollController) {
            return GridView(
              children: children,
              controller: scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 8,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(hasAdded ? Icons.remove : Icons.add),
        onPressed: () {
          setState(() {
            if (!hasAdded) {
              fruits.insert(1, 'new fruit ${fruits.length}');
            } else {
              fruits.removeAt(1);
            }
            setState(() {
              hasAdded = !hasAdded;
            });
          });
        },
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