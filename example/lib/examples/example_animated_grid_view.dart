import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: ExampleAnimatedGridView()));
}

class ExampleAnimatedGridView extends StatefulWidget {
  const ExampleAnimatedGridView({Key? key}) : super(key: key);

  @override
  State<ExampleAnimatedGridView> createState() =>
      _ExampleAnimatedGridViewState();
}

class _ExampleAnimatedGridViewState extends State<ExampleAnimatedGridView> {
  final fruits = <String>["banana", "apple", "strawberry"];
  bool hasAdded = false;

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
}
