// Reproduction: fading removed children are not clipped by the GridView.
//
// 1. Scroll the grid a bit, so the top row is only partly visible below the
//    green header.
// 2. Tap a tile of that row to remove it (or use the button to remove all).
//
// EXPECTED: the fading tile stays inside the grid, like before removing it.
// ACTUAL: the fading tile is drawn at full size and overlaps the green header
// for the duration of the fade out (1 second here).
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
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
  final _gridViewKey = GlobalKey();

  List<int> children = List.generate(200, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => children = []),
        label: const Text('Remove all'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 200.0,
            width: double.infinity,
            child: ColoredBox(color: Colors.green),
          ),
          Expanded(
            child: ReorderableBuilder.builder(
              scrollController: _scrollController,
              // long fade out to see the removed child clearly
              animationConfig: const ReorderableAnimationConfig(
                fadeOutDuration: Duration(seconds: 1),
              ),
              onReorder: (ReorderedListFunction<int> reorderedListFunction) {
                setState(() {
                  children = reorderedListFunction(children);
                });
              },
              itemCount: children.length,
              childBuilder: (itemBuilder) {
                return GridView.builder(
                  key: _gridViewKey,
                  controller: _scrollController,
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children.elementAt(index);
                    return itemBuilder(
                      GestureDetector(
                        key: Key(child.toString()),
                        // removes the tapped child
                        onTap: () => setState(() => children.remove(child)),
                        child: ColoredBox(
                          color: Colors.lightBlue,
                          child: Text(child.toString()),
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
          ),
        ],
      ),
    );
  }
}
