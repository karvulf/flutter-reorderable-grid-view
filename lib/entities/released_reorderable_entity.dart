import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

class ReleasedReorderableEntity {
  final ReorderableEntity reorderableEntity;
  final Offset dropOffset;

  const ReleasedReorderableEntity({
    required this.reorderableEntity,
    required this.dropOffset,
  });
}
