import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _scrollController = ScrollController();
  var index = 1;
  var _fruits = <String>[];

  @override
  Widget build(BuildContext context) {
    final generatedChildren = List.generate(_fruits.length + 1, (index) {
      if (index == _fruits.length) {
        // Add button
        return GestureDetector(
          key: const Key("button"),
          onTap: () {
            _fruits.add("value${index++}");
            setState(() {});
          },
          child: Container(
            color: Colors.lightBlue,
            child: const Text("Button"),
          ),
        );
      } else {
        // Item
        return Container(
          key: Key(_fruits.elementAt(index)),
          color: Colors.lightBlue,
          child: Text(
            _fruits.elementAt(index),
          ),
        );
      }
    });

    return Scaffold(
      body: ReorderableBuilder(
        scrollController: _scrollController,
        longPressDelay: const Duration(milliseconds: 300),
        lockedIndices: [_fruits.length],
        fadeInDuration: const Duration(milliseconds: 1000),
        dragChildBoxDecoration:
            const BoxDecoration(color: CupertinoColors.transparent),
        onReorder: (ReorderedListFunction<String> reorderedListFunction) {
          final updatedFruits = reorderedListFunction([..._fruits, 'button']);
          setState(() {
            _fruits = updatedFruits..removeLast();
          });
        },
        children: generatedChildren,
        builder: (children) {
          return GridView(
            controller: _scrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 8,
            ),
            children: children,
          );
        },
      ),
    );
  }
}
