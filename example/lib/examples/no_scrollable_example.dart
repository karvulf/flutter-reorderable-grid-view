import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

class NoScrollableExample extends StatefulWidget {
  const NoScrollableExample({super.key});

  @override
  State<NoScrollableExample> createState() => _NoScrollableExampleState();
}

class _NoScrollableExampleState extends State<NoScrollableExample> {
  final _gridViewKey = GlobalKey();

  List<int> children = List.generate(100, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReorderableBuilder.builder(
        onReorder: (ReorderedListFunction<int> reorderedListFunction) {
          setState(() {
            children = reorderedListFunction(children);
          });
        },
        itemCount: children.length,
        childBuilder: (itemBuilder) {
          return GridView.builder(
            key: _gridViewKey,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            itemBuilder: (context, index) {
              return itemBuilder(
                ColoredBox(
                  key: Key(children.elementAt(index).toString()),
                  color: Colors.lightBlue,
                  child: Text(
                    children.elementAt(index).toString(),
                  ),
                ),
                index,
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 8,
            ),
          );
        },
      ),
    );
  }
}
