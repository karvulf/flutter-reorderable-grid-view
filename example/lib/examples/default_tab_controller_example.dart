import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

class DefaultTabControllerExample extends StatefulWidget {
  const DefaultTabControllerExample({super.key});

  @override
  State<DefaultTabControllerExample> createState() =>
      _DefaultTabControllerExampleState();
}

class _DefaultTabControllerExampleState
    extends State<DefaultTabControllerExample> {
  static const _myTabs = <Tab>[
    Tab(text: 'LEFT'),
    Tab(text: 'RIGHT'),
  ];
  final _gridViewLists = <List<String>>[
    List.generate(100, (index) => 'LEFT_$index'),
    List.generate(100, (index) => 'RIGHT_$index'),
  ];
  final _gridViewKeys = <GlobalKey>[
    GlobalKey(),
    GlobalKey(),
  ];
  final _scrollControllers = [
    ScrollController(),
    ScrollController(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: _myTabs,
          ),
        ),
        body: TabBarView(
          children: _myTabs.map((Tab tab) {
            final index = _myTabs.indexOf(tab);
            final list = _gridViewLists[index];

            final generatedChildren = List.generate(
              list.length,
              (index) => Container(
                key: Key(list.elementAt(index)),
                color: Colors.lightBlue,
                child: Text(
                  list.elementAt(index),
                ),
              ),
            );

            return ReorderableBuilder(
              scrollController: _scrollControllers[index],
              onReorder: (ReorderedListFunction reorderedListFunction) {
                final updatedList = reorderedListFunction(list) as List<String>;
                setState(() {
                  _gridViewLists[index] = updatedList;
                });
              },
              children: generatedChildren,
              builder: (children) {
                return GridView(
                  key: _gridViewKeys[index],
                  controller: _scrollControllers[index],
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 8,
                  ),
                  children: children,
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
