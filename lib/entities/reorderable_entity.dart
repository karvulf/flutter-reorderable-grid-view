import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';

class ReorderableEntity {
  final List<Widget> children;
  final Map<int, GridItemEntity> idMap;

  ReorderableEntity({
    required this.children,
    required this.idMap,
  });

  ReorderableEntity copyWith({
    List<Widget>? children,
    Map<int, GridItemEntity>? idMap,
  }) =>
      ReorderableEntity(
        children: children ?? this.children,
        idMap: idMap ?? this.idMap,
      );

  void clear() {
    children.clear();
    idMap.clear();
  }
}
