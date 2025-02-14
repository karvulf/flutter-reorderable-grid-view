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
  final _gridViewKey = GlobalKey();
  final bool reverse = false;

  List<int> children = List.generate(200, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        reverse: reverse,
        child: Column(
          children: [
            const SizedBox(
              height: 200.0,
              width: double.infinity,
              child: ColoredBox(color: Colors.green),
            ),
            ReorderableBuilder.builder(
              onReorder: (ReorderedListFunction<int> reorderedListFunction) {
                setState(() {
                  children = reorderedListFunction(children);
                });
              },
              reverse: reverse,
              itemCount: children.length,
              childBuilder: (itemBuilder) {
                return GridView.builder(
                  key: _gridViewKey,
                  reverse: reverse,
                  shrinkWrap: true,
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
          ],
        ),
      ),
    );
  }
}
