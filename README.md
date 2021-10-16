<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A GridView whose items the user can interactively reorder by dragging. 

Compared to the given `ReorderableListView`, it
is possible to reorder different sizes of widgets with or without animation.

TODO: Add GIF of animated GridView

## Features

Use this package in your Flutter App to:
- Enable a reordering logic with different widgets
- Simplified widget
- Works with all kind of widgets that are rendered inside
- Animated when reordering items

## Getting started
Simply add `ReordableGridView` to your preferred Widget and specify a list of children.

## Usage

```dart
// TODO: add correct import of flutter_reorderable_grid_view
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 0),
        child: Column(
          children: [
            Expanded(
              child: FlutterReordableGridView(
                spacing: 12,
                children: List.generate(
                  20,
                      (index) => Container(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Additional information

If you have feature requests or found some problems, feel free and open your issues in the GitHub project.
