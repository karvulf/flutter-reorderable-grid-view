import 'package:flutter/widgets.dart';

/// Visible state of a child that is animated while another child is dragged.
///
/// Used to continue the animation after releasing the dragged child, even if
/// a different widget is showing the child after the children were reordered.
class DraggingAnimationEntity {
  /// Visible offset of the child inside ReorderableBuilder.
  final Offset offset;

  /// Progress of the animation between 0.0 and 1.0.
  final double progress;

  const DraggingAnimationEntity({
    required this.offset,
    required this.progress,
  });
}
