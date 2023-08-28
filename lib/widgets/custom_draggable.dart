import 'package:flutter/cupertino.dart';

/// Helper widget if you want to add sth to [Draggable] related to [child].
///
/// If you want to add more info to [Draggable] or [LongPressDraggable],
/// this widget will transfer these info to the widgets.
/// It is important that you add also a unique [key] that is related
/// to the [child].
class CustomDraggable extends StatelessWidget {
  /// Will be displayed as a widget.
  final Widget child;

  /// Will be used for [Draggable] or [LongPressDraggable].
  final Object? data;

  const CustomDraggable({
    required this.child,
    required Key key,
    this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
