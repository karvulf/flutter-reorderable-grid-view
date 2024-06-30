import 'package:flutter/cupertino.dart';

/// Helper widget for adding additional information to [Draggable] related to [child].
///
/// Use this widget to supplement [Draggable] or [LongPressDraggable]
/// with additional information.
/// It's essential to provide a unique [key] that correlates with the [child].
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
