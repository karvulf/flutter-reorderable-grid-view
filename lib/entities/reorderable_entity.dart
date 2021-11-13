import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';

class ReorderableEntity {
  List<Widget> children;
  Map<int, GridItemEntity> idMap;

  // don't use const to ensure that map and list is modifiable
  ReorderableEntity({
    required this.children,
    required this.idMap,
  });

  factory ReorderableEntity.create() => ReorderableEntity(
        children: [],
        idMap: {},
      );

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

  void addEntry(MapEntry<int, GridItemEntity> entry) {
    idMap[entry.key] = entry.value;
  }
}
