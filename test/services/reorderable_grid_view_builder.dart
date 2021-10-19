import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';

class ReorderableGridViewBuilder {
  GridItemEntity getGridItemEntity({
    Offset? globalPosition,
    Offset? localPosition,
    Size? size,
    int? orderId,
    int? id,
  }) =>
      GridItemEntity(
        localPosition: localPosition ?? const Offset(0, 0),
        size: size ?? const Size(0, 0),
        orderId: orderId ?? 0,
        id: id ?? 1,
      );
}
