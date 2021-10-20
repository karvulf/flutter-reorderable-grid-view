import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

abstract class ReorderableParameters {
  /// Adding [children] that should be displayed inside this widget
  final List<Widget> children = [];

  final List<int> lockedChildren = [];

  /// By default animation is enabled when the position of the items changes
  final bool enableAnimation = true;

  /// By default long press is enabled when tapping an item
  final bool enableLongPress = true;

  /// By default it has a duration of 500ms before an item can be moved.
  ///
  /// Can only be used if [enableLongPress] is enabled.
  final Duration longPressDelay = kLongPressTimeout;

  final ScrollPhysics? physics = null;

  /// Every a child changes his position, this function is called.
  ///
  /// When a child was moved, you get the old index where the child was and
  /// the new index where the child is positioned now.
  ///
  /// You should always update your list if you want to make use of the new
  /// order. Otherwise this widget is just a good-looking widget.
  ///
  /// See more on the example.
  final void Function(int oldIndex, int newIndex)? onReorder = null;
}
