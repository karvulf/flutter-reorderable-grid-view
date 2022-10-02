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
  /// Represents this entity
  final Widget child;

  /// Describes [size] of [child].
  final Size size;

  /// Describes the original orderId before it was updated.
  final int originalOrderId;

  /// Describes the updated orderId when it was updated.
  final int updatedOrderId;

  /// Describes the original [Offset] before it was updated.
  final Offset originalOffset;

  /// Describes the updated [Offset] when it was updated.
  final Offset updatedOffset;

  /// Usually means that the [child] has a new position that is still unknown.
  ///
  /// If [isBuilding] is true, then it is possible, that the [Offset] and
  /// orderId will be updated.
  final bool isBuilding;

  /// The [Offset] can already be known but this is still a flag to know, that [child] didn't exist before.
  final bool isNew;

  /// Is true, when this [child] only changed the position with another child.
  ///
  /// This is only true, when the changed position has nothing to do with
  /// another added or removed child.
  final bool hasSwappedOrder;

  const ReorderableEntity({
    required this.child,
    required this.originalOrderId,
    required this.updatedOrderId,
    required this.isBuilding,
    this.originalOffset = Offset.zero,
    this.updatedOffset = Offset.zero,
    this.size = Size.zero,
    this.isNew = false,
    this.hasSwappedOrder = false,
  });

  /// Overrides all parameters of this entity and returns the updated [ReorderableEntity].
  ReorderableEntity copyWith({
    Offset? originalOffset,
    Offset? updatedOffset,
    Widget? child,
    Size? size,
    int? originalOrderId,
    int? updatedOrderId,
    bool? isBuilding,
    bool? isNew,
    bool? hasSwappedOrder,
  }) =>
      ReorderableEntity(
        size: size ?? this.size,
        originalOffset: originalOffset ?? this.originalOffset,
        updatedOffset: updatedOffset ?? this.updatedOffset,
        child: child ?? this.child,
        updatedOrderId: updatedOrderId ?? this.updatedOrderId,
        originalOrderId: originalOrderId ?? this.originalOrderId,
        isBuilding: isBuilding ?? this.isBuilding,
        isNew: isNew ?? this.isNew,
        hasSwappedOrder: hasSwappedOrder ?? this.hasSwappedOrder,
      );

  Key get key => child.key!;
}
