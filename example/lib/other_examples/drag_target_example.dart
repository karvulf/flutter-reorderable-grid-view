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
  final _gridViewKey = GlobalKey();

  List<int> children = List.generate(200, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DragTarget(
              onAcceptWithDetails: (details) {
                setState(() {
                  children.removeAt(details.data as int);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return const Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 200.0,
                        width: double.infinity,
                        child: ColoredBox(color: Colors.green),
                      ),
                    ),
                    Icon(
                      Icons.delete,
                      size: 60.0,
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: ReorderableBuilder.builder(
                scrollController: _scrollController,
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
                      return itemBuilder(
                        CustomDraggable(
                          key: Key(children.elementAt(index).toString()),
                          data: index,
                          child: ColoredBox(
                            color: Colors.lightBlue,
                            child: Text(
                              children.elementAt(index).toString(),
                            ),
                          ),
                        ),
                        index,
                      );
                    },
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
      ),
    );
  }
}
