![Pub Version](https://img.shields.io/pub/v/flutter_reorderable_grid_view?color=%23397ab6&style=flat-square)
![GitHub branch checks state](https://img.shields.io/github/checks-status/karvulf/flutter-reorderable-grid-view/master?style=flat-square)

<p>
  <img src="https://github.com/karvulf/flutter-reorderable-grid-view/blob/master/doc/animated_drag_and_drop.gif?raw=true"
    alt="An animated image of the iOS ReordableGridView UI" height="400"/>
<img src="https://github.com/karvulf/flutter-reorderable-grid-view/blob/master/doc/animated_items.gif?raw=true"
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
- [Road Map](#road-map)
- [Future Plans](#future-plans)


## Overview

Enhance your Flutter app with this package to:

- Enable animated drag-and-drop functionality:
  - Works seamlessly with any GridView.
  - For GridView.builder, use ReorderableBuilder.builder to implement drag-and-drop.
- Add smooth animations for adding, removing, or updating items in your grid.

## Getting started

```dart
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();
  
  var _fruits = <String>["apple", "banana", "strawberry"];

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
        onReorder: (ReorderedListFunction reorderedListFunction) {
          setState(() {
            _fruits = reorderedListFunction(_fruits) as List<String>;
          });
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
`ReorderableBuilder` provides two main functionalities: **Drag and Drop** and **Animations**.

To use this widget, wrap `ReorderableBuilder` around your `GridView`. For more details, refer to the [Getting Started](#getting-started) section.

**Important**: Ensure each child within the `GridView` has a unique key.

### ScrollController

When using a scrollable `GridView`, `ReorderableBuilder` requires a `ScrollController`. 
This means you must assign the `ScrollController` to both the scrollable widget and `ReorderableBuilder`. 

If the parent is a scrollable widget, you should not assign a `ScrollController`.
In this case, the widget automatically looks up the `ScrollController`.
Assigning one manually can cause issues with drag-and-drop functionality.

### Drag and Drop
The drag-and-drop functionality is enabled by default.

To ensure proper reordering, you must implement the `onReorder` callback to update your list of children. 
Without this, the reorder operation will not work and may cause issues.

### Scroll while dragging
While dragging a child, moving it to the top or bottom of your `GridView` will trigger automatic scrolling. 

You can disable this behavior by setting `enableScrollingWhileDragging` to `false`.

### Animations
## Types of Animations

There are two types of animations:

**Drag and Drop**: 

This animation ensures smooth positioning of the dragged child to any position (unless the position is locked). 
While dragging, the movement of the other children is also animated.

**List Updates**: 

These animations occur when updating your list of children by adding, removing, or modifying items. 
For example, adding or removing a child at the beginning of the list affects the positions of all subsequent children (See the GIFs at the top of the page for examples).

### Supported Widgets

* Using `ReorderableBuilder` supports
    * `GridView`
    * `GridView.count`
    * `GridView.extent`


* Using `ReorderableBuilder.builder` supports
  * `GridView.builder`

### Parameters

| **Parameter**                  | **Description**                                                                                                           | **Default Value** |
|:-------------------------------|:--------------------------------------------------------------------------------------------------------------------------|:-----------------:|
| `children`                     | Displays all given children that are build inside a Wrap or GridView. Don't forget a unique key for every child.          |       **-**       |
| `childBuilder`                 | Enable support for [GridView.builder] using this function. Don't forget a unique key for every child.                     |       **-**       |
| `lockedIndices`                | Define all children that can't be moved while dragging. You need to add the index of this child in a list.                |    **<int>[]**    |
| `nonDraggableIndices`          | Specify indices for [children] that are not draggable.                                                                    |    **<int>[]**    |
| `enableLongPress`              | If true, you need to long press the widget to start the dragging.                                                         |     **true**      |
| `longPressDelay`               | Specify the duration before dragging starts after long-pressing the widget.                                               |    **500 ms**     |
| `enableDraggable`              | Enables the drag and drop functionality.                                                                                  |     **true**      |
| `enableScrollingWhileDragging` | Enables the functionality to scroll while dragging a child to the top or bottom.                                          |     **true**      |
| `automaticScrollExtent`        | Defines the height of the top or bottom before the dragged child indicates a scrolling.                                   |     **80.0**      |
| `fadeInDuration`               | [Duration] for the fade in animation when a new child was added.                                                          |     **500ms**     |
| `releasedChildDuration`        | [Duration] for the position animation when a dragged child was released and is moving to his new position.                |     **150ms**     |
| `positionDuration `            | [Duration] when the child is changing his position (not working while using drag and drop).                               |     **200ms**     |
| `dragChildBoxDecoration`       | When a child is dragged, you can override the default BoxDecoration of the dragged child.                                 |       **-**       |
| `reverse`                      | Handles the reversed order of your children. Ensure to add this flag to your scrollable and this widget.                  |     **false**     |
| `builder`                      | It's required to use [ReorderableBuilder] to obtain updated [children].                                                   |       **-**       |
| `onReorder`                    | After releasing the dragged child, [onReorder] is called which contains a function as parameter to reorder all the items. |       **-**       |
| `onDragStarted`                | Callback when dragging starts with the index where it started.                                                            |       **-**       |
| `onDragEnd`                    | Callback when the dragged child was released with the index.                                                              |       **-**       |
| `onUpdatedDraggedChild`        | Called when the dragged child has updated his position while dragging.                                                    |       **-**       |
| `scrollController`             | `ScrollController` which should be also assigned to the scrollable widget. Don't forget this to prevent animation issues. |       **-**       |

### `CustomDraggable`

The `CustomDraggable` widget is a helper that can contain optional information to be added to `Draggable` or `LongPressDraggable`.

Ensure this widget wraps the child you intend to add to your `GridView`, as it should receive the unique key.

```dart
  CustomDraggable(
    // add your unique key here
    key: Key('unique'),
    // will be passed to `Draggable` or `LongPressDraggable`
    data: 'data',
    child: Placeholder(),
  ),
```

## Road map for release of version `6.0.0`
* Code Refactoring for easier understanding!

* Support for `Wrap` 
  * with animation when adding or removing items
  * drag and drop
  * Github Issue [#28](https://github.com/karvulf/flutter-reorderable-grid-view/issues/28)

## Future Plans

If you have feature requests or have found any issues, please feel free to open an issue on the GitHub project repository.

Contributions are also highly appreciated! If you'd like to contribute a new feature or bug fix, 
opening a pull request is the way to go. This helps in getting updates and fixes out faster.

Thank you for using this package!
