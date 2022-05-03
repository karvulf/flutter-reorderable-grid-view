![Pub Version](https://img.shields.io/pub/v/flutter_reorderable_grid_view?color=%23397ab6&style=flat-square)
![Codecov](https://img.shields.io/codecov/c/gh/karvulf/flutter-reorderable-grid-view?style=flat-square)
![GitHub branch checks state](https://img.shields.io/github/checks-status/karvulf/flutter-reorderable-grid-view/master?style=flat-square)

<p>
  <img src="https://github.com/karvulf/flutter-reorderable-grid-view/blob/master/doc/animated_grid_view_drag_and_drop.gif?raw=true"
    alt="An animated image of the iOS ReordableGridView UI" height="400"/>
<img src="https://github.com/karvulf/flutter-reorderable-grid-view/blob/master/doc/animated_grid_view_add.gif?raw=true"
    alt="An animated image of the iOS ReordableGridView UI" height="400"/>
<img src="https://github.com/karvulf/flutter-reorderable-grid-view/blob/master/doc/animated_grid_view_remove.gif?raw=true"
    alt="An animated image of the iOS ReordableGridView UI" height="400"/>
<img src="https://github.com/karvulf/flutter-reorderable-grid-view/blob/master/doc/animated_grid_view_swap.gif?raw=true"
alt="An animated image of the iOS ReordableGridView UI" height="400"/>
</p>

Package for having animated Drag and Drop functionality for every type of `GridView` and to have animations when changing the size of children inside your `GridView`.

## Index
- [Overview](#overview)
- [Getting Started](#getting-started)
- [Usage](#usage)
  - [Drag and Drop](#drag-and-drop)
  - [Scroll while dragging](#scroll-while-dragging)
  - [Animations](#animations)
- [Supported Widgets](#supported-widgets)
- [Parameters](#parameters)
- [Future Plans](#future-plans)


## Overview

Use this package in your Flutter App to:

- get the functionality for an animated drag and drop in all type of `GridView`
- have animations when updating, adding or removing children

## Getting started

```dart
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();
  final _fruits = <String>["apple", "banana", "strawberry"];

  @override
  Widget build(BuildContext context) {
    final generatedChildren = List.generate(
      _fruits.length,
              (index) => Container(
        key: Key(_fruits.elementAt(index)),
        color: Colors.lightBlue,
        child: Text(
          _fruits.elementAt(index),
        ),
      ),
    );

    return Scaffold(
      body: ReorderableBuilder(
        children: generatedChildren,
        scrollController: _scrollController,
        onReorder: (List<OrderUpdateEntity> orderUpdateEntities) {
          for (final orderUpdateEntity in orderUpdateEntities) {
            final fruit = _fruits.removeAt(orderUpdateEntity.oldIndex);
            _fruits.insert(orderUpdateEntity.newIndex, fruit);
          }
        },
        builder: (children) {
          return GridView(
            key: _gridViewKey,
            controller: _scrollController,
            children: children,
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
```

## Usage
`ReorderableBuilder` has two main functionalities: **Drag and Drop** and **Animations**.

For using this widget, you have to wrap `ReorderableBuilder` to your `GridView` (see more on Getting Started).

Every child has to have a unique key.

Also be sure to make where you have the scrolling behavior. If your `GridView` has the functionality to scroll, you should add the `ScrollController` from `ReorderableBuilder` to your `GridView`.

### Drag and Drop
The functionality for drag and drop is enabled by default. You have to use `onReorder` to prevent a weird behavior after releasing the dragged child.

### Scroll while dragging
While dragging a child, it can be moved to top or bottom of your `GridView` to start an automatic scrolling. 

### Animations
There are different animations:
- when drag and drop, all position changes are animated
- when adding, removing or updating a child (e.g. you swap two positions), there is also an animation for that behavior

### Supported Widgets

* GridViews
    * `GridView`
    * `GridView.count`
    * `GridView.extent`
    * `GridView.builder`

### Parameters

| **Parameter** | **Description** | **Default Value** |
| :------------- | :------------- | :-------------: |
| `children` | Displays all given children that are build inside a Wrap or GridView. Don't forget a unique key for every child. |**-** |
| `lockedIndices` | Define all children that can't be moved while dragging. You need to add the index of this child in a list. | **<int>[]** |
| `enableLongPress` | Decides if the user needs a long press to move the item around. | **true** |
| `longPressDelay` | Specify the delay to move an item when enabling long press. | **500 ms** |
| `enableDraggable` | Enables the drag and drop functionality. | **true** |
| `dragChildBoxDecoration` | When a child is dragged, you can override the default BoxDecoration, e. g. if your children have another shape. |**-** |
| `initDelay` | !**Not recommended**! - Adding a delay when creating children instead of a PostFrameCallback.|**-** |
| `enableScrollingWhileDragging` | Enables the functionality to scroll while dragging a child to the top or bottom.|**true** |
| `automaticScrollExtent` | Defines the height of the top or bottom before the dragged child indicates a scrolling. |**80.0** |
| `scrollController` | `ScrollController` to get the current scroll position. Important for calculations!|**-** |
| `onReorder` | Called after drag and drop was released. Contains a list of `OrderUpdateEntity` that has information about the old and new index. See more on the example `main.dart`|**-** |
| `onDragStarted` | Callback when user starts dragging a child. |**-** |
| `onDragEnd` | Callback when user releases dragged child. |**-** |
| `builder` | Important function that returns your `children` as modified `children` to enable animations and the drag and drop. See more on the example `main.dart`.|**-** |

## Future Plans

With the Update `2.0.0`, I totally changed the logic for having a drag and drop functionality. So it is possible, that there are still some problems, so let me know it if you find them.

If you have feature **requests** or found some **issues**, feel free and open your issues in the GitHub project.

Thank you for using this package.