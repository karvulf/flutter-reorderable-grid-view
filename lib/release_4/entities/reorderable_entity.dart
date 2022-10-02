import 'package:flutter/cupertino.dart';

/// Represents [child] with some extra information.
///
/// When animating all children in this package, this entity is important
/// to have access to all needed values of [child].
///
/// With this entity, it is possible to know where the [child] is
/// positioned and which order that [child] has inside all children.
///
/// Also the current state of [child] is added as information: [isBuilding],
/// [isNew] and [hasSwappedOrder].
class ReorderableEntity {
  final ValueKey key;
  final bool visible;
  final int originalOrderId;

  const ReorderableEntity({
    required this.key,
    required this.originalOrderId,
    required this.visible,
  });

  ReorderableEntity copyWith({
    bool? visible,
  }) =>
      ReorderableEntity(
        key: key,
        originalOrderId: originalOrderId,
        visible: visible ?? this.visible,
      );
}
