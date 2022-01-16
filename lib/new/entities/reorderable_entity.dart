import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/new/entities/reorderable_updated_entity.dart';

class ReorderableEntity {
  final Widget child;
  final Offset originalOffset;
  final ReorderableUpdatedEntity? reorderableUpdatedEntity;
  final Size size;

  const ReorderableEntity({
    required this.child,
    this.originalOffset = Offset.zero,
    this.size = Size.zero,
    this.reorderableUpdatedEntity,
  });

  ReorderableEntity copyWith({
    ReorderableUpdatedEntity? reorderableUpdatedEntity,
    Size? size,
    Offset? originalOffset,
  }) =>
      ReorderableEntity(
        originalOffset: originalOffset ?? this.originalOffset,
        size: size ?? this.size,
        reorderableUpdatedEntity:
            this.reorderableUpdatedEntity ?? reorderableUpdatedEntity,
        child: child,
      );

  Offset get currentOffset =>
      reorderableUpdatedEntity?.offset ?? originalOffset;
}
