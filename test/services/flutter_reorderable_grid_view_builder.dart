import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';

class FlutterReorderableGridViewBuilder {
  GridItemEntity getGridItemEntity({
    Offset? globalPosition,
    Offset? localPosition,
    Size? size,
    int? orderId,
    Widget? item,
  }) =>
      GridItemEntity(
        localPosition: localPosition ?? const Offset(0, 0),
        globalPosition: globalPosition ?? const Offset(0, 0),
        size: size ?? const Size(0, 0),
        item: item ?? Container(),
        orderId: orderId ?? 0,
      );
}
