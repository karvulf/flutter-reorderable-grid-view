![Pub Version](https://img.shields.io/pub/v/flutter_reorderable_grid_view?color=%23397ab6&style=flat-square)
![Codecov](https://img.shields.io/codecov/c/gh/karvulf/flutter-reorderable-grid-view?style=flat-square)
![GitHub branch checks state](https://img.shields.io/github/checks-status/karvulf/flutter-reorderable-grid-view/master?style=flat-square)

Package for having animated Drag and Drop functionality for every type of `GridView` and `Wrap`.

Also you have the option to have an animation, when adding or removing children inside your `GridView`.

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

- Use an animated drag and drop for every type of `GridView` and `Wrap`
    - You have the option to lock specific children when using drag and drop
    - Optimized performance by just adding `ReorderableBuilder`
- Having an animation when adding or removing children inside `GridView` (currently not supported for `Wrap`)
    - Opimized performance by just adding `AnimatedGridViewBuilder`
- You can combine `ReorderableBuilder` and `AnimatedGridViewBuilder` by using `AnimatedReorderableBuilder`
    - In this case you get the support for the animated drag and drop and when adding or removing children

## Getting started

**Animated Drag and Drop**

- Just use `ReorderableBuilder` as builder widget for your `GridView` or `Wrap`

**Animated GridView**

- Just use `AnimatedGridViewBuilder` to have an animation when adding or removing children

**Animated GridView with Drag and Drop**

- Just use `AnimatedReorderableBuilder` to have an animation when adding or removing children with the option for drag
  and drop

## Usage

### Animated Drag and Drop

```dart

class ExampleDragAndDropGridView extends StatefulWidget {
  const ExampleDragAndDropGridView({Key? key}) : super(key: key);

  @override
  State<ExampleDragAndDropGridView> createState() =>
      _ExampleDragAndDropGridViewState();
}

class _ExampleDragAndDropGridViewState
    extends State<ExampleDragAndDropGridView> {
  final fruits = <String>["banana", "apple", "strawberry"];

  @override
  Widget build(BuildContext context) {
    final children = List.generate(
      fruits.length,
      (index) {
        final fruit = fruits.elementAt(index);
        return Container(
          key: Key(fruit),
          alignment: Alignment.center,
          color: Colors.white,
          child: Text(fruit),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white70,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ReorderableBuilder(
          children: children,
          onReorder: _handleReorder,
          builder: (children, scrollController) {
            return GridView(
              controller: scrollController,
              children: children,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 8,
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      final child = fruits.removeAt(oldIndex);
      fruits.insert(newIndex, child);
    });
  }
}
```

### Animated GridView

```dart

class ExampleAnimatedGridView extends StatefulWidget {
  const ExampleAnimatedGridView({Key? key}) : super(key: key);

  @override
  State<ExampleAnimatedGridView> createState() =>
      _ExampleAnimatedGridViewState();
}

class _ExampleAnimatedGridViewState extends State<ExampleAnimatedGridView> {
  final fruits = <String>["banana", "apple", "strawberry"];
  bool hasAdded = false;

  @override
  Widget build(BuildContext context) {
    final children = List.generate(
      fruits.length,
      (index) {
        final fruit = fruits.elementAt(index);
        return Container(
          key: Key(fruit),
          alignment: Alignment.center,
          color: Colors.white,
          child: Text(fruit),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white70,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedGridViewBuilder(
          children: children,
          builder: (children, contentGlobalKey, scrollController) {
            return GridView(
              key: contentGlobalKey,
              controller: scrollController,
              children: children,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 8,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(hasAdded ? Icons.remove : Icons.add),
        onPressed: () {
          setState(() {
            if (!hasAdded) {
              fruits.insert(1, 'new fruit ${fruits.length}');
            } else {
              fruits.removeAt(1);
            }
            setState(() {
              hasAdded = !hasAdded;
            });
          });
        },
      ),
    );
  }
}
```

### Animated GridView with Drag and Drop

```dart

class ExampleAnimatedDragAndDropGridView extends StatefulWidget {
  const ExampleAnimatedDragAndDropGridView({Key? key}) : super(key: key);

  @override
  State<ExampleAnimatedDragAndDropGridView> createState() =>
      _ExampleAnimatedGridViewState();
}

class _ExampleAnimatedGridViewState
    extends State<ExampleAnimatedDragAndDropGridView> {
  final fruits = <String>["banana", "apple", "strawberry"];
  bool hasAdded = false;

  @override
  Widget build(BuildContext context) {
    final children = List.generate(
      fruits.length,
      (index) {
        final fruit = fruits.elementAt(index);
        return Container(
          key: Key(fruit),
          alignment: Alignment.center,
          color: Colors.white,
          child: Text(fruit),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white70,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedReorderableBuilder(
          children: children,
          onReorder: _handleReorder,
          builder: (children, contentGlobalKey, scrollController) {
            return GridView(
              key: contentGlobalKey,
              controller: scrollController,
              children: children,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 8,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(hasAdded ? Icons.remove : Icons.add),
        onPressed: () {
          setState(() {
            if (!hasAdded) {
              fruits.insert(1, 'new fruit ${fruits.length}');
            } else {
              fruits.removeAt(1);
            }
            setState(() {
              hasAdded = !hasAdded;
            });
          });
        },
      ),
    );
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      final child = fruits.removeAt(oldIndex);
      fruits.insert(newIndex, child);
    });
  }
}
```

To see more examples, just start the Example App and use the DropDown to test all type of widgets.

### Supported Widgets

#### Support for Drag and Drop

* `Wrap`
* GridViews
    * `GridView`
    * `GridView.count`
    * `GridView.extent`
    * `GridView.builder`

#### Support for animated GridViews

* GridViews
    * `GridView`
    * `GridView.count`
    * `GridView.extent`
    * `GridView.builder`

#### Support for animated GridViews with Drag and Drop

* GridViews
    * `GridView`
    * `GridView.count`
    * `GridView.extent`
    * `GridView.builder`

### Parameters

| **Parameter** | **Description** | **Default Value** |
| :------------- | :------------- | :-------------: |
| `children` | Displays all given children that are build inside a Wrap or GridView. Don't forget a unique key for every child. | **
-** |
| `lockedIndices` | Define all children that can't be moved while dragging. You need to add the index of this child in a list. | **<int>[]** |
| `enableAnimation` | Enables the animation when changing the positions of children after drag and drop. | **true** |
| `enableLongPress` | Decides if the user needs a long press to move the item around. | **true** |
| `longPressDelay` | Specify the delay to move an item when enabling long press. | **500 ms** |
| `dragChildBoxDecoration` | When a child is dragged, you can override the default BoxDecoration, e. g. if your children have another shape. | **
-** |
| `onReorder` | After dragging an item to a new position, this function is called.<br/> The function contains always the old and new index. Be sure to update your children after that. See more on examples.| **
-** |
| `enableReorder` | Enables the functionality to reorder the children.| **true** |

## Future Plans

With this package, I tried to simplify the logic for adding drag and drop to GridViews or Wrap.

I also added an animation when adding or removing children, but this feature is currently only supported for GridViews.

But I want to optimize this package, so I hope, that it might help you to get the best experience when using flutter.

If you have feature **requests** or found some **issues**, feel free and open your issues in the GitHub project.

Thank you for using this package.