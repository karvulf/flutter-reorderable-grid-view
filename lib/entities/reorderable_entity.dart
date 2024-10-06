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
  static const _isNewChildId = -1;

  final ValueKey key;

  final int originalOrderId;
  final int updatedOrderId;

  final Offset originalOffset;
  final Offset updatedOffset;

  final Size size;

  final bool isBuildingOffset;
  final bool hasSwappedOrder;

  const ReorderableEntity({
    required this.key,
    required this.originalOrderId,
    required this.updatedOrderId,
    required this.originalOffset,
    required this.updatedOffset,
    required this.size,
    required this.isBuildingOffset,
    required this.hasSwappedOrder,
  });

  factory ReorderableEntity.create({
    required ValueKey key,
    required int updatedOrderId,
    Offset? offset,
    Size? size,
  }) =>
      ReorderableEntity(
        key: key,
        originalOrderId: _isNewChildId,
        updatedOrderId: updatedOrderId,
        originalOffset: offset ?? Offset.zero,
        updatedOffset: offset ?? Offset.zero,
        size: size ?? Size.zero,
        isBuildingOffset: offset == null,
        hasSwappedOrder: false,
      );

  @override
  bool operator ==(Object other) {
    return other is ReorderableEntity &&
        (other.key == key &&
            other.originalOffset == originalOffset &&
            other.originalOrderId == originalOrderId &&
            other.updatedOrderId == updatedOrderId &&
            other.updatedOffset == updatedOffset &&
            other.size == size &&
            other.isBuildingOffset == isBuildingOffset &&
            other.hasSwappedOrder == hasSwappedOrder);
  }

  @override
  int get hashCode => originalOrderId + updatedOrderId;

  @override
  String toString() =>
      '[$key]: Original OrderId: $originalOrderId, Updated OrderId: $updatedOrderId, Original Offset: $originalOffset, Updated Offset: $updatedOffset';

  ReorderableEntity fadedIn() => ReorderableEntity(
        key: key,
        originalOrderId: updatedOrderId,
        updatedOrderId: updatedOrderId,
        originalOffset: updatedOffset,
        updatedOffset: updatedOffset,
        size: size,
        isBuildingOffset: false,
        hasSwappedOrder: false,
      );

  ReorderableEntity creationFinished({
    required Offset? offset,
    required Size size,
  }) {
    return ReorderableEntity(
      key: key,
      originalOrderId: originalOrderId,
      updatedOrderId: updatedOrderId,
      originalOffset: originalOffset,
      updatedOffset: offset ?? updatedOffset,
      size: size,
      isBuildingOffset: false,
      hasSwappedOrder: false, // TODO(karvulf): false wirklich richtig?
    );
  }

  ReorderableEntity updated({
    required int updatedOrderId,
    required Offset? updatedOffset,
    required Size? size,
  }) {
    var originalOrderId = this.originalOrderId;
    var originalOffset = this.originalOffset;

    // should only update original when previous updated orderId is different to previous one
    if (updatedOrderId != this.updatedOrderId) {
      originalOrderId = this.updatedOrderId;
      originalOffset = this.updatedOffset;
    }

    return ReorderableEntity(
      key: key,
      originalOrderId: originalOrderId,
      updatedOrderId: updatedOrderId,
      originalOffset: originalOffset,
      updatedOffset: updatedOffset ?? this.updatedOffset,
      size: size ?? this.size,
      isBuildingOffset: updatedOffset == null,
      hasSwappedOrder:
          updatedOrderId != originalOrderId && updatedOffset != null,
    );
  }

  ReorderableEntity positionUpdated() => ReorderableEntity(
        key: key,
        originalOrderId: updatedOrderId,
        updatedOrderId: updatedOrderId,
        originalOffset: updatedOffset,
        updatedOffset: updatedOffset,
        size: size,
        isBuildingOffset: false,
        hasSwappedOrder: false,
      );

  ReorderableEntity dragUpdated({
    required int updatedOrderId,
    required Offset updatedOffset,
  }) =>
      ReorderableEntity(
        key: key,
        originalOrderId: originalOrderId,
        updatedOrderId: updatedOrderId,
        originalOffset: originalOffset,
        updatedOffset: updatedOffset,
        size: size,
        isBuildingOffset: isBuildingOffset,
        hasSwappedOrder: true,
      );

  ReorderableEntity copyWith({
    Size? size,
    bool? isBuildingOffset,
  }) =>
      ReorderableEntity(
        key: key,
        originalOrderId: originalOrderId,
        updatedOrderId: updatedOrderId,
        originalOffset: originalOffset,
        updatedOffset: updatedOffset,
        size: size ?? this.size,
        isBuildingOffset: isBuildingOffset ?? this.isBuildingOffset,
        hasSwappedOrder: hasSwappedOrder,
      );

  bool get isNew => originalOrderId == _isNewChildId;
}
