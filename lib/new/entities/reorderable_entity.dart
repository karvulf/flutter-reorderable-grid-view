import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/new/entities/reorderable_updated_entity.dart';

class ReorderableEntity {
  final Offset originalOffset;
  final ReorderableUpdatedEntity? reorderableUpdatedEntity;
  final Size size;

  const ReorderableEntity({
    required this.originalOffset,
    required this.size,
    this.reorderableUpdatedEntity,
  });

  ReorderableEntity copyWith({
    ReorderableUpdatedEntity? reorderableUpdatedEntity,
  }) =>
      ReorderableEntity(
        originalOffset: originalOffset,
        size: size,
        reorderableUpdatedEntity:
            this.reorderableUpdatedEntity ?? reorderableUpdatedEntity,
      );

  Offset get currentOffset =>
      reorderableUpdatedEntity?.offset ?? originalOffset;
}
