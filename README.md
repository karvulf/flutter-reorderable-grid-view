![Pub Version](https://img.shields.io/pub/v/flutter_reorderable_grid_view?color=%23397ab6&style=flat-square)
![Codecov](https://img.shields.io/codecov/c/gh/karvulf/flutter-reorderable-grid-view?style=flat-square)
![GitHub branch checks state](https://img.shields.io/github/checks-status/karvulf/flutter-reorderable-grid-view/master?style=flat-square)

Package for having animated Drag and Drop functionality for every type of `GridView` and to have animations when changing the size of children inside your `GridView`.


## Features

Use this package in your Flutter App to:

- get the functionality for an animated drag and drop in all type of `GridView`
- have animations when updating, adding or removing children

## Getting started



## Usage

### Supported Widgets

* GridViews
    * `GridView`
    * `GridView.count`
    * `GridView.extent`
    * `GridView.builder`

### Parameters

| **Parameter** | **Description** | **Default Value** |
| :------------- | :------------- | :-------------: |
| `children` | Displays all given children that are build inside a Wrap or GridView. Don't forget a unique key for every child. | 
**-** |
| `lockedIndices` | Define all children that can't be moved while dragging. You need to add the index of this child in a list. | **<int>[]** |
| `enableAnimation` | Enables the animation when changing the positions of children after drag and drop. | **true** |
| `enableLongPress` | Decides if the user needs a long press to move the item around. | **true** |
| `longPressDelay` | Specify the delay to move an item when enabling long press. | **500 ms** |
| `dragChildBoxDecoration` | When a child is dragged, you can override the default BoxDecoration, e. g. if your children have another shape. | 
**-** |
| `onReorder` | Called after drag and drop was released. Contains a list of `OrderUpdateEntity` that has information about the old and new index. See more on the example `main.dart`| 
**-** |
| `enableReorder` | Enables the functionality to reorder the children.| **true** |

## Future Plans

With this package, I tried to simplify the logic for adding drag and drop to GridViews.

I also added an animation when adding or removing children, but this feature is currently only supported for GridViews.

If you have feature **requests** or found some **issues**, feel free and open your issues in the GitHub project.

Thank you for using this package.