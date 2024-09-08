import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

/// In this example [ReorderableBuilder.builder] is used.
///
/// The widget can build 9999 items with an image included.
void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _imagePath = 'assets/test_image.jpeg';

  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();

  var _children = List.generate(9999, (index) => index.toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heavy ReorderableGridView.builder'),
      ),
      body: ReorderableBuilder.builder(
        scrollController: _scrollController,
        onReorder: (ReorderedListFunction reorderedListFunction) {
          setState(() {
            _children = reorderedListFunction(_children) as List<String>;
          });
        },
        childBuilder: (itemBuilder) {
          return GridView.builder(
            key: _gridViewKey,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 8,
            ),
            controller: _scrollController,
            itemCount: _children.length,
            itemBuilder: (context, index) {
              final child = Container(
                key: Key(_children[index]),
                color: Colors.lightBlue,
                child: Stack(
                  children: [
                    Image.asset(_imagePath),
                    Center(
                      child: ColoredBox(
                        color: Colors.blueGrey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _children[index].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );

              return itemBuilder(child, index);
            },
          );
        },
      ),
    );
  }
}
