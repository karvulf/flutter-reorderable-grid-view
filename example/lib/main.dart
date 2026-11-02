import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view_example/examples/apple_style/apple_style_example.dart';
import 'package:flutter_reorderable_grid_view_example/examples/basic_example.dart';
import 'package:flutter_reorderable_grid_view_example/examples/create_more_items_example.dart';
import 'package:flutter_reorderable_grid_view_example/examples/custom_animations_example.dart';
import 'package:flutter_reorderable_grid_view_example/examples/default_tab_controller_example.dart';
import 'package:flutter_reorderable_grid_view_example/examples/drag_target_example.dart';
import 'package:flutter_reorderable_grid_view_example/examples/drag_while_moving_example.dart';
import 'package:flutter_reorderable_grid_view_example/examples/heavy_reorderable_builder_example.dart';
import 'package:flutter_reorderable_grid_view_example/examples/inner_scrollable_example.dart';
import 'package:flutter_reorderable_grid_view_example/examples/no_scrollable_example.dart';
import 'package:flutter_reorderable_grid_view_example/examples/outer_scrollable_example.dart';
import 'package:flutter_reorderable_grid_view_example/examples/page_view/page_view_example.dart';
import 'package:flutter_reorderable_grid_view_example/examples/playground/playground_example.dart';
import 'package:flutter_reorderable_grid_view_example/examples/wrap_layouts/wrap_layouts_example.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xfffaa025),
          surface: const Color(0xff271f16),
        ),
      ),
      home: const ExampleGallery(),
    ),
  );
}

/// An example of the gallery.
///
/// [hasAppBar] is false for examples without their own app bar, so the
/// gallery adds one to navigate back.
typedef _Example = ({
  String title,
  String description,
  Widget page,
  bool hasAppBar,
});

const _examples = <_Example>[
  (
    title: 'Playground',
    description: 'GridView, GridView.count/.extent/.builder and Wrap with '
        'locked children and buttons to change the children',
    page: PlaygroundExample(),
    hasAppBar: true,
  ),
  (
    title: 'Basic',
    description: 'Minimal ReorderableBuilder with a GridView',
    page: BasicExample(),
    hasAppBar: false,
  ),
  (
    title: 'Apple style',
    description: 'Calm insert, remove and drag feedback animations',
    page: AppleStyleExample(),
    hasAppBar: false,
  ),
  (
    title: 'Custom animations',
    description: 'Custom insert, remove and drag feedback animations',
    page: CustomAnimationsExample(),
    hasAppBar: true,
  ),
  (
    title: 'Wrap layouts',
    description: 'Drag and drop in a Wrap with every kind of layout',
    page: WrapLayoutsExample(),
    hasAppBar: true,
  ),
  (
    title: 'Add button as last child',
    description: 'Locked add button that creates new children',
    page: CreateMoreItemsExample(),
    hasAppBar: false,
  ),
  (
    title: 'Drag target',
    description: 'Drop a child on a DragTarget to delete it',
    page: DragTargetExample(),
    hasAppBar: false,
  ),
  (
    title: 'Drag while moving',
    description: 'Drag right after removing a child, while the others move',
    page: DragWhileMovingExample(),
    hasAppBar: true,
  ),
  (
    title: 'Heavy builder',
    description: '9999 children with images using ReorderableBuilder.builder',
    page: HeavyReorderableBuilderExample(),
    hasAppBar: true,
  ),
  (
    title: 'Inner scrollable',
    description: 'GridView scrolling below a header',
    page: InnerScrollableExample(),
    hasAppBar: false,
  ),
  (
    title: 'Outer scrollable',
    description: 'GridView inside a SingleChildScrollView',
    page: OuterScrollableExample(),
    hasAppBar: false,
  ),
  (
    title: 'No scrollable',
    description: 'GridView that cannot scroll',
    page: NoScrollableExample(),
    hasAppBar: false,
  ),
  (
    title: 'PageView',
    description: 'A ReorderableBuilder on every page of a PageView',
    page: PageViewExample(),
    hasAppBar: false,
  ),
  (
    title: 'Tabs',
    description: 'A ReorderableBuilder in every tab of a TabBarView',
    page: DefaultTabControllerExample(),
    hasAppBar: true,
  ),
];

class ExampleGallery extends StatelessWidget {
  const ExampleGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_reorderable_grid_view')),
      body: ListView(
        children: [
          for (final example in _examples)
            ListTile(
              title: Text(example.title),
              subtitle: Text(example.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => example.hasAppBar
                      ? example.page
                      : Scaffold(
                          appBar: AppBar(title: Text(example.title)),
                          body: example.page,
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
