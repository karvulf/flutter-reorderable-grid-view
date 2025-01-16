## 5.4.1
🐛 **Bug Fixes**
- when dragging an item to a `DragTarget` widget, the `onDragEnd` callback was not being called, causing the reorder process to remain incomplete
  - fixed it by using the `onDragCompleted` callback of `Draggable` 
  - added a new example file: `drag_target_example.dart` 

## 5.4.0
🐛 **Bug Fixes**
- dragging is now restricted to a single contact at a time
  - previously, initiating a drag with multiple contacts was possible, but only one contact would be dragged
  - this issue has been resolved to prevent confusion
  - special thanks to `wuhangandroid` and `Gloomy699` ([#57](https://github.com/karvulf/flutter-reorderable-grid-view/issues/57))
- Fixed issue with `longPressDelay` set to `Duration.zero` or `enableLongPress` set to `false` ([#141](https://github.com/karvulf/flutter-reorderable-grid-view/issues/141))
  - Previously, child widgets with an `onTap` function wouldn't respond
  - This should now work correctly, but note that using a delay of less than 55ms may still cause the issue

⭐️ **New Features**
- added a generic type for `ReorderableBuilder`
  - eliminates the need to cast `reorderListFunction` in `onReorder`
  - special thanks to `KevenMelo` ([#142](https://github.com/karvulf/flutter-reorderable-grid-view/issues/142))

ℹ️ **Information**
- added a new example for `DefaultTabController`
  - it was unclear how the `ReorderableBuilder` works with `DefaultTabController` and `TabBarView`
  - special thanks to `isenbj` and `emavgl` ([#78](https://github.com/karvulf/flutter-reorderable-grid-view/issues/78))

## 5.3.2
🐛 **Bug Fixes**
- **fixed reordering issue**:
  - reordering didn't work correctly after adding a new item
  - special thanks to `OICQ469` ([#135](https://github.com/karvulf/flutter-reorderable-grid-view/issues/135))
- **fixed fade in**
  - the fade in didn't appear when a new child was added

## 5.3.1
🐛 **Bug Fixes**
- **fixed `PageView.builder` issues**:
  - resolved problems when using `PageView.builder`, improving stability during reordering
  - special thanks to `FanYuanBo888` ([#121](https://github.com/karvulf/flutter-reorderable-grid-view/issues/121)) and `billizzard2` ([#113](https://github.com/karvulf/flutter-reorderable-grid-view/issues/113)) for reporting and contributing

- **resolved reordering issue with scrolling**:
  - fixed a bug where scrolling to the top while dragging and then back to the bottom caused issues with reordering children
  - thanks to `davidmartos96` for identifying this issue ([#127](https://github.com/karvulf/flutter-reorderable-grid-view/issues/127))

- **fixed drag and drop after resizing**:
  - addressed an issue where drag and drop would stop working correctly after resizing the grid
  - acknowledgements to `khjde1207` for the report ([#91](https://github.com/karvulf/flutter-reorderable-grid-view/issues/91))

## 5.3.0
⭐️ **New Features**
* added parameter `reverse`
  * if your `GridView` uses the flag `reverse`, ensure to also use it for `ReorderableBuilder`
* improved the scrolling behavior while dragging

## 5.2.0
⭐️ **New Features**
* enhanced the visual appearance of the feedback widget when starting a drag
* improved behavior when `enableLongPress` is set to `false`:
  * previously, the feedback widget only appeared after moving the dragged widget
  * now, the feedback starts immediately when pressing the widget, as `LongPressDraggable` is consistently used whether `enableLongPress` is `true` or `false`
  * this change also deprecates `enableLongPress`, as it's no longer needed. To achieve the same effect as `enableLongPress = false`, simply set `longPressDelay` to `Duration.zero`

🐛 **Bug Fixes**
* Fixed an issue where dragging didn't work correctly with `CarouselSlider` (thanks to `charmosz` – Issue [#118](https://github.com/karvulf/flutter-reorderable-grid-view/issues/118)).
  * The solution ensures the scroll position of the `ScrollController` is always used when it's added to `ReorderableBuilder` and linked to a scrollable widget.

## 5.1.0
* there were performance issues (Issue [#107](https://github.com/karvulf/flutter-reorderable-grid-view/issues/107))
  * because `setState` was called many times, it rerendered all children
  * I improved it by only rendering the updated children when they are built
  * this version can be used to test it

## 5.0.1
🐛 **Bug fix**
* Dragging not working in release mode on Android (thanks to `shubham-gupta-16` - Issue [#105](https://github.com/karvulf/flutter-reorderable-grid-view/issues/105))
  * changed behavior of `Listener` to `HitTestBehavior.deferToChild`

## 5.0.0
This release introduces a complete overhaul of the package, delivering significant performance optimizations, bug fixes, and new features.

⭐️ **New features**
* Improved Reorderable.builder performance: Now only renders visible children, similar to GridView.builder, significantly enhancing performance
* Horizontal direction support (Issue [#53](https://github.com/karvulf/flutter-reorderable-grid-view/issues/53)):
  * `GridView` now supports both horizontal and vertical directions
* New `fadeInDuration` parameter (Issue [#68](https://github.com/karvulf/flutter-reorderable-grid-view/issues/68)):
  * Default: `500ms`
  * Controls the animation duration when a new child appears
* `Draggable` and `LongPressDraggable` now support `data` attachment
* New `onDraggedChildUpdated` callback (thanks for the PR [Bader-AI](https://github.com/Bader-Al)):
  * Called whenever a dragged child updates its position during dragging
  * Avoid modifying children during this callback to prevent erratic behavior
* New `releasedChildDuration` parameter:
  * Defines the duration for a child to settle into its new position after being released
  * Default `150ms`
* New `positionDuration` parameter (thanks to `naderhezzy` - Issue [#94](https://github.com/karvulf/flutter-reorderable-grid-view/issues/94)):
  * Adjusts the animation duration when a child's position changes (e.g., when adding/removing items)
* New `nonDraggableIndicies` parameter (thanks to `Bader-Al` for the PR [#93](https://github.com/karvulf/flutter-reorderable-grid-view/pull/93/)):
  * Specifies indices of non-draggable items, though they remain movable while dragging other items


⚡️ **Breaking Changes**
* `onReorder`  function now includes a reorder callback that must be invoked within the `onReorder` handler
  * This improves performance, especially when working with large lists
  * Refer to the updated examples for guidance
* `onDragStarted` and `onDragEnd` callbacks now include the index of the dragged child in their parameters

## 5.0.0-dev.10
🐛 **Bug fix**
* locked children were still draggable, now they are locked (thanks to `gmarizy` - Issue [#97](https://github.com/karvulf/flutter-reorderable-grid-view/issues/97))

## 5.0.0-dev.9
🐛 **Bug fixes**
* fixed issue when deleting the dragged child (thanks to `khjde1207` - Issue [#88](https://github.com/karvulf/flutter-reorderable-grid-view/issues/88))

⭐️ **New features**
* added parameter `positionDuration` (thanks to `naderhezzy` - Issue [#94](https://github.com/karvulf/flutter-reorderable-grid-view/issues/94))
  * changes the animation duration when a child updates his position e.g. when adding or removing a child
* added parameter `nonDraggableIndicies` (thanks to `Bader-Al` for the PR [#93](https://github.com/karvulf/flutter-reorderable-grid-view/pull/93/))
  * you can specify the indices of children that cannot be dragged but are still movable while dragging

## 5.0.0-dev.8
🐛 **Bug fixes**
* fixed animation when releasing a dragged item
* fixed item animations when adding or removing them

## 5.0.0-dev.7
⭐️ **New features**
* you can add `data` to `Draggable` or `LongPressDraggable`
  * use the widget `CustomDraggable` for that
  * more info is added to the read me
* added new callback `onDraggedChildUpdated` (thanks for the PR [Bader-AI](https://github.com/Bader-Al))
  * always called when the dragged child updated his position while dragging
  * you should use this without changing the children, otherwise this could lead to weird behavior while using drag and drop
* added new parameter `releasedChildDuration`
  * can be used to define the duration when a dragged child was released and is moving to his new position
  * default value is 150ms

🐛 **Bug fixes**
* there were issues that required to add `initDelay` to fix wrong behavior while drag and drop
  * this should be fixed by calculating the positions differently to before
  * before the positions were calculated related to the global widget
  * now the positions are only calculated to the local widget
  * this fixes wrong calculated positions
  * fixes issue of `naw2nd` in [Issue #83](https://github.com/karvulf/flutter-reorderable-grid-view/issues/83) when using a BottomModalSheet

## 5.0.0-dev.6
🐛 This release contains some bugfixes (optimization)
* while dragging there were issues when the user scrolled with another finger
  * the dragged item was dropped if when it shouldn't

## 5.0.0-dev.5
🐛 This release contains some bugfixes
* fixed drag and drop after using functionality "scrolling while dragging" (thanks to [tsquillario](https://github.com/tsquillario) for pointing out that issue)
* fixed disappeared children after using functionality "scrolling while dragging"

## 5.0.0-dev.4
⭐️ **New features**
* updated two functions
  * `onDragStarted`
    * added `index` to parameter
    * `index` is the index where the drag started
  * `onDragEnd`
    * added `index` to parameter
    * `index` is the index where the drag ended

🐛 This release contains some bugfixes
* `onDragStarted` wasn't called and should work now
* `onDragEnd` wasn't called and should work now

## 5.0.0-dev.3
⭐️ **New features**
* added support for horizontal direction (Issue [#53](https://github.com/karvulf/flutter-reorderable-grid-view/issues/53))
  * with this, you can use your `GridView` in both directions
  * currently there might be still small bugs
* added parameter `fadeInDuration` (Issue [#68](https://github.com/karvulf/flutter-reorderable-grid-view/issues/68))
  * default value is `const Duration(milliseconds: 500)`
  * this parameter is responsible for the animation when a new child appears and describes the duration of the animation
* parameter `initDelay` is working again

## 5.0.0-dev.2
* 🐛 This release contains some bugfixes
  * drag and drop combined with `lockedIndices` and `GridView.builder` should work now
* ⭐️ Optimized reordering items
  * the callback `onReorder` is offering a function as parameter after reordering items
  * the reason for that change is a performance issue, especially having big lists
  * to ensure that everyone is using the same reordering process, I moved the logic to the package inside a function
* 🧑‍💻
  * refactored some code and added comments to some parts


## 5.0.0-dev.1
ℹ️ℹ️ℹ️ℹ️
* This is a prerelease and does not contain all functionalities that are tagged in GitHub for the release
  * the functionalities will be implemented if possible
* This release contains
  * completely redesigned logic for the animation and drag and drop
  * smoother animation
  * much better performance (`GridView.builder` is now working as it should work, see more on the example in `main.dart`)
* Still missing
  * tests
  * comments
  * documentation
  * some features from GitHub for this release
* there are still some bugs (I am pretty sure), so please try out this prerelease and post the issues on GitHub!
  * known bugs:
    * drag and drop in combination with `lockedIndices` and `GridView.builder` can lead to wrong animations
    * Android: seems like it is possible that the drag and drop leads to wrong positioning of items when releasing the dragged item
    * `GridView.builder`: rotating the device leads to wrong behavior when using drag and drop

ℹ️ℹ️ℹ️ℹ️

## 4.0.0
ℹ️ **Information**

This is not the new big release! This will come with version `5.0.0`.
  * the reason is the flutter upgrade `3.7.0` that was released a couple days ago
  * to ensure that people who are still using a lower flutter are not updating this package automatically, I had to make this update with `4.0.0`
  * so the big update will come with `5.0.0` hopefully in one or two months
  * you could already test it as pre-release

🐛 **Fixed error because of flutter upgrade `3.7.0`**
* fixed an error that was thrown because of the flutter ugprade `3.7.0`

## 3.1.3
🐛 **Fixed some bugs**
* fixed two null check errors (Issue [#41](https://github.com/karvulf/flutter-reorderable-grid-view/issues/41) and Issue [#44](https://github.com/karvulf/flutter-reorderable-grid-view/issues/44))
* fixed animated behavior when using `GridView.builder` (Issue [#44](https://github.com/karvulf/flutter-reorderable-grid-view/issues/44))
  * before there was no animation when adding or removing an item, this should work now
  * this should also fix the callback `onReorder` where an index of an item is returned that should not exist

ℹ️ **Information**
* added Roadmap for release `5.0.0`

## 3.1.2
🐛 **Fixed small bug**
* Fixed exception `Null check operator used on a null value` (Issue [#41](https://github.com/karvulf/flutter-reorderable-grid-view/issues/41)) 
 
🧑‍💻**Code Refactoring**
* Updated `flutter_lints` to `2.0.1`

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

