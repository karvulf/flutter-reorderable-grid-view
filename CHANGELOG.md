## 3.1.1
🐛 **Fixed Bugs**
* There was a problem when having the scrollable widget outside the `ReorderableBuilder`
  * The scrolling to top didn't work when it was scrolled to bottom
  * also `automaticScrollExtent` didn't calculate the correct area when scrolling to top

## 3.1.0
🐛 **Fixed Bugs**
* Because of the update of flutter version `3.0.0`, this package couldn't support earlier versions because of the last update
  * with this version, the package should also work for versions before `3.0.0`

## 3.0.1
🐛 **Fixed Bugs**
* fixed warnings due to flutter update version `3.0.0`

## 3.0.0

⚠️️ **Breaking Changes**

* you have to add the `ScrollController` to `ReorderableBuilder` and your `GridView` to make sure that the drag and drop
  still works
* an exception would be if your content is scrollable outside your `GridView`

⭐️ **New features**

* `enableScrollingWhileDragging`
    * **IMPORTANT**: You have to add a `GlobalKey` to your `GridView` before autoscroll can work
    * enables autoscrolling while dragging
    * you can automatically scroll while dragging a child to the bottom or top of your `GridView`
* `automaticScrollExtent`
    * define the height of the area before the autoscroll is starting when moving to top or bottom


* for more information, check out the example

## 2.1.0

⭐️ **New features**

* added two new parameters for `ReorderableBuilder`:
    * `onDragStarted`: Called when user starts dragging a child
    * `onDragEnd`: Called when user releases dragged child

🦙 **Behavior changed**

* `onReorder` won't be called anymore when the dragged child didn't change his original position

## 2.0.3

🐛 **Fixed Bugs**

* Wrong behavior after updating children (especially the key) and using drag and drop
* For every update of a child, a new listener was added
    * this behavior is fixed
    * now only one listener will be added

🦙 **Behavior changed**

* When using drag and drop to a locked child, no position will be changed

## 2.0.2

* Downgraded Dart-version from `2.16.1` to `2.16.0`

## 2.0.2-dev.2

* second try to solve dependency issue

## 2.0.2-dev.1

* trying to solve dependency problem

## 2.0.1

* updated pubspec

## 2.0.0

* Official Release of 2.0.0
* There are breaking changes in this release:
    * Currently I don't support the widget `Wrap`
    * I removed all custom widgets for `GridView`
        * instead you can use `ReorderableBuilder` as a Wrapper for all `GridView` of Flutter
        * See more on Getting Started or the example app

## 2.0.0-dev.5

* last release candidate! (if there aren't some critical bugs)
* this release includes a change for the function `onReorder`
    * the function gives always a list of entities containing the old and new index for children
    * this case had to be done to ensure correct animations when there are locked children (`lockedIndices`)
    * see more on the example app in `main.dart`
* multiple other bugs were solved when changing positions or adding/removing children
* added more commentaries to classes
* Before publishing the official `2.0.0`, the following things will be done:
    * Unit and Widget tests
    * some more refactoring, also in favor of making the testing easier
    * Refactoring example app
    * ReadMe gets a whole new update

## 2.0.0-dev.4

* Removed `AnimatedGridViewBuilder` and `AnimatedReorderableBuilder` because there were some problems splitting the
  logic for animation while dragging and adding/removing items
* `ReorderableBuilder` is making all the animation
    * to disable drag and drop, just make `enableDraggable` to false
* improved the performance
* Todo:
    * Refactoring of code
    * more testing
    * Widget tests + Unit Tests (?)
    * updating examples
    * updating read me

## 2.0.0-dev.3

* Removed `ReorderableWrap` and `ReorderableGridView`
* New widgets for more flexibility:
    * `ReorderableBuilder` for Drag and Drop with all `GridView` and `Wrap`
    * `AnimatedGridViewBuilder` for animation when adding or removing children with all types of `GridView`
    * `AnimatedReorderableBuilder` combines `ReorderableBuilder` and `AnimatedGridViewBuilder`
* See more examples with the new widgets in the example folder

## 2.0.0-dev.2

* Added animation when there are new children added or removed
    * Working for all types of `GridView`
    * Currently not supported for `ReorderableWrap`
* Some bug fixes when adding/removing items
* Work in Progress:
    * More Configurations
    * Separated widget only for animation when removing/adding children
    * Fixing flickering when adding children in GridView
    * Still some bugs when reordering children

## 2.0.0-dev.1

* Complete rebuilt Reorderable GridViews and Wrap
* Supporting all types of `GridView`
* Better performance by displaying the original GridViews/Wrap
* More options to add to GridViews/Wrap
* Work in Progress:
    * Animated children when removing/adding one or multiple children
    * Tests still missing
    * New docu

## 1.1.5

* Fixed a bug when changing from `enableReorder` `false` to `true`

## 1.1.4

* Added parameter `enableReorder` with default value `true`

## 1.1.3

* BoxDecoration added for dragged child

## 1.1.2

* AnimationController disposing

## 1.1.1

* Some Readme changes
* fixed clipBehavior while scrolling (clipBehavior is now Clip.hardEdge)

## 1.1.0

* Added animation for the following cases:
    * Item was added to children
    * Item was removed from children
    * all children are animated when an item is added or removed
* From now, you have to add a unique key for every child in your list, see more on the example app

## 1.0.2

* fixed scrolling e. g. for `RefreshIndicator`

## 1.0.1

* fixed ClipBehavior

## 1.0.0

* Old used `ReorderableGridView` now called `ReorderableWrap`
* New `ReorderableGridView` added
    * `ReorderableGridView`
    * `ReorderableGridView.count`
    * `ReorderableGridView.extent`

## 1.0.0-dev.4

* Drag Update Position fixed with PostFrameCallback
* All tests now passes

## 1.0.0-dev.3

* Fixed Scrolling Bugs in and outside widget

## 1.0.0-dev.2

* Fixed ReorderableGridView.extent

## 1.0.0-dev.1

* Differentiate between Wrap and GridView
* ReorderableGridView renamed to ReorderableWrap
* ReorderableGridView created with different GridView Builds
    * ReorderableGridView.count added
    * ReorderableGridView.extent added
    * Hint: Multiple Props still missing

## 0.3.0

* Fixed some critical bugs
    * When children are updated (e. g. a new one is added or removed) then the gridview updates normally
    * When changing screen orientation, then the GridView repositions all children
    * all bugs are covered with new tests

## 0.2.1

* Updated ReadMe

## 0.2.0

* lockedChildren added to specify items that should not change their positions
* optimized performance

## 0.1.0

* onUpdate added to notifiy the user that there was an update while moving items
* LongPressDelay added

## 0.0.8

* ReadMe Prettier

## 0.0.7

* ReadMe Prettier

## 0.0.6

* ReadMe Fix

## 0.0.5

* ReadMe Fix

## 0.0.4

* ReadMe update with badges
    - Build Number
    - Code Coverage
    - Build Passing

## 0.0.3

* Updated ReadMe
* Added example

## 0.0.2

* Renamed `FlutterReorderableGridView` to `ReorderableGridView`

## 0.0.1

* Enables to reorder widgets inside a Wrap
* Animated Reordering

