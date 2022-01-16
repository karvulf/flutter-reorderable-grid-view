import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/new/entities/reorderable_updated_entity.dart';

class ReorderableEntity {
  final Widget child;
  final Offset originalOffset;
  final Size size;
  final int orderId;

  final ReorderableUpdatedEntity? reorderableUpdatedEntity;

  const ReorderableEntity({
    required this.child,
    required this.orderId,
    this.originalOffset = Offset.zero,
    this.size = Size.zero,
    this.reorderableUpdatedEntity,
  });

  ReorderableEntity copyWith({
    required ReorderableUpdatedEntity? reorderableUpdatedEntity,
    Widget? child,
    Size? size,
    Offset? originalOffset,
    int? orderId,
  }) =>
      ReorderableEntity(
        originalOffset: originalOffset ?? this.originalOffset,
        size: size ?? this.size,
        reorderableUpdatedEntity: reorderableUpdatedEntity,
        child: child ?? this.child,
        orderId: orderId ?? this.orderId,
      );

  Offset get currentOffset =>
      reorderableUpdatedEntity?.offset ?? originalOffset;
}
