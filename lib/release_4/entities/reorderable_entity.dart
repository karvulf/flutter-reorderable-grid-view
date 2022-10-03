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
  static const isNewChildId = -1;

  final ValueKey key;

  final int originalOrderId;
  final int updatedOrderId;

  final Offset originalOffset;
  final Offset updatedOffset;

  const ReorderableEntity({
    required this.key,
    required this.originalOrderId,
    required this.updatedOrderId,
    required this.originalOffset,
    required this.updatedOffset,
  });

  factory ReorderableEntity.create({
    required ValueKey key,
    required int updatedOrderId,
  }) =>
      ReorderableEntity(
        key: key,
        originalOrderId: isNewChildId,
        updatedOrderId: updatedOrderId,
        originalOffset: Offset.zero,
        updatedOffset: Offset.zero,
      );

  @override
  bool operator ==(Object other) {
    return other is ReorderableEntity &&
        (other.key == key &&
            other.originalOffset == originalOffset &&
            other.originalOrderId == originalOrderId &&
            other.updatedOrderId == updatedOrderId &&
            other.updatedOffset == updatedOffset);
  }

  @override
  int get hashCode => originalOrderId;

  ReorderableEntity copyWith({
    int? originalOrderId,
    int? updatedOrderId,
    Offset? originalOffset,
    Offset? updatedOffset,
  }) =>
      ReorderableEntity(
        key: key,
        originalOrderId: originalOrderId ?? this.originalOrderId,
        updatedOrderId: updatedOrderId ?? this.updatedOrderId,
        originalOffset: originalOffset ?? this.originalOffset,
        updatedOffset: updatedOffset ?? this.updatedOffset,
      );

  ReorderableEntity creationFinished() => ReorderableEntity(
        key: key,
        originalOrderId: updatedOrderId,
        updatedOrderId: updatedOrderId,
        originalOffset: updatedOffset,
        updatedOffset: updatedOffset,
      );

  ReorderableEntity updated({
    required int updatedOrderId,
    required Offset? updatedOffset,
  }) =>
      ReorderableEntity(
        key: key,
        originalOrderId: originalOrderId,
        updatedOrderId: updatedOrderId,
        originalOffset: originalOffset,
        updatedOffset: updatedOffset ?? this.updatedOffset,
      );
}
