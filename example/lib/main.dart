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
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final fruits = <String>[
    "apple",
    "banana",
    "orange",
    "strawberry",
  ];

  @override
  Widget build(BuildContext context) {
    final generatedChildren = List.generate(
      fruits.length,
      (index) => Container(
        height: 50,
        width: 50,
        alignment: Alignment.center,
        key: Key(fruits.elementAt(index)),
        color: Colors.lightBlue,
        child: Text(
          fruits.elementAt(index),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              IconButton(
                onPressed: () {
                  fruits.removeAt(0);
                  setState(() {});
                },
                icon: Icon(Icons.remove),
              ),
              Expanded(
                child: ReorderableBuilder(
                  children: generatedChildren,
                  onReorder: (List<OrderUpdateEntity> orderUpdateEntities) {
                    for (final orderUpdateEntity in orderUpdateEntities) {
                      final fruit = fruits.removeAt(orderUpdateEntity.oldIndex);
                      fruits.insert(orderUpdateEntity.newIndex, fruit);
                    }
                  },
                  builder: (children, scrollController) {
                    return GridView.extent(
                      controller: scrollController,
                      children: children,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      maxCrossAxisExtent: 100,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
