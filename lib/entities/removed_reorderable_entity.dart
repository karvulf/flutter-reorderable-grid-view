import 'package:flutter/widgets.dart';

/// Describes a removed child that is still shown while it is fading out.
class RemovedReorderableEntity {
  /// Key of the removed child.
  final ValueKey key;

  /// Last widget of the removed child.
  final Widget child;

  /// Last offset of the child inside ReorderableBuilder (scroll offset included).
  final Offset offset;

  /// Last size of the child.
  final Size size;

  const RemovedReorderableEntity({
    required this.key,
    required this.child,
    required this.offset,
    required this.size,
  });
}
