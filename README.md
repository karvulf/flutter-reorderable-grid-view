![Pub Version](https://img.shields.io/pub/v/flutter_reorderable_grid_view?color=%23397ab6&style=flat-square)
![Codecov](https://img.shields.io/codecov/c/gh/karvulf/flutter-reorderable-grid-view?style=flat-square)
![GitHub branch checks state](https://img.shields.io/github/checks-status/karvulf/flutter-reorderable-grid-view/master?style=flat-square)

A GridView and Wrap whose items the user can interactively reorder by dragging.

Animated Reordering with different type of widgets: GridView and Wrap.

<p>
  <img src="https://github.com/karvulf/flutter-reorderable-grid-view/blob/master/doc/flutter_reordable_grid_view_preview_ios.gif?raw=true"
    alt="An animated image of the iOS ReordableGridView UI" height="400"/>
<img src="https://github.com/karvulf/flutter-reorderable-grid-view/blob/master/doc/flutter_reordable_grid_view_preview2_ios.gif?raw=true"
    alt="An animated image of the iOS ReordableGridView UI" height="400"/>
<img src="https://github.com/karvulf/flutter-reorderable-grid-view/blob/master/doc/flutter_reordable_grid_view_preview3_ios.gif?raw=true"
    alt="An animated image of the iOS ReordableGridView UI" height="400"/>
<img src="https://github.com/karvulf/flutter-reorderable-grid-view/blob/master/doc/flutter_reordable_grid_view_preview4_ios.gif?raw=true"
alt="An animated image of the iOS ReordableGridView UI" height="400"/>
</p>

## Features

Use this package in your Flutter App to:

- Enable a reordering logic with different widgets
- Simplified widget for Wrap and GridView
- Works with all kind of widgets that are rendered inside
- Animated when reordering items
- Locking all items you don't want to move
- Animation added for removed or added children
- Tested workflows like updating children or changing orientation

## Getting started

Simply add `ReordableWrap` or `ReorderableGridView` to your preferred Widget and specify a list of children.

## Usage

```dart
import 'package:flutter_reorderable_grid_view/reorderable_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final children = List.generate(
      20,
          (index) =>
          Container(
            key: Key(index.toString()),
            color: Colors.blue,
            height: 100,
            width: 100,
            child: Text(
              'test $index',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
    );
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ReorderableWrap(
            onReorder: (int oldIndex, int newIndex) {
              // update your list of children when reordering!
            },
            children: children,
          ),
        ),
      ),
    );
  }
}
```

To see more examples, just start the Example App and use the DropDown to test all type of widgets.

### Supported Widgets

* `ReorderableWrap`
* `ReorderableGridView`
* `ReorderableGridView.count`
* `ReorderableGridView.extent`

## Additional information

`ReorderableWrap` and `ReorderableGridView` are just an extension of the known widgets `Wrap` and `GridView`.

The extension includes the functionality to reorder their items.

Be careful that you don't forget to reorder your children when you reorder your items to prevent weird bugs. Also you
have to add a unique key for every child in your list.

In the following description you get information about the new parameters.

More information about the parameters of `GridView` and `Wrap` are on the flutter documentation.

### Parameters

| **Parameter** | **Description** | **Default Value** |
| :------------- | :------------- | :-------------: |
| `children` | Displays all given children that are build inside a Wrap or GridView. Don't forget a unique key for every child. | **-** |
| `lockedChildren` | Define all children that can't be moved while dragging. You need to add the index of this child in a list. | **<int>[]** |
| `enableAnimation` | Enables the animation when changing the positions of childrens after drag and drop. | **true** |
| `enableLongPress` | Decides if the user needs a long press to move the item around. | **true** |
| `longPressDelay` | Specify the delay to move an item when enabling long press. | **500 ms** |
| `dragChildBoxDecoration` | When a child is dragged, you can override the default BoxDecoration, e. g. if your children have another shape. | **-** |
| `onReorder` | After dragging an item to a new position, this function is called.<br/> The function contains always the old and new index. Be sure to update your children after that. See more on examples.| **-** |

## Future Plans

Currently, I didn't implement all types of GridView.

Also there is an animation when removing or adding items but currently you cannot decide your preferred animation.

And the code could be more readable and less complex, so in the future I might refactor the code a bit more.

If you have feature **requests** or found some **issues**, feel free and open your issues in the GitHub project.

Thank you for using this package.