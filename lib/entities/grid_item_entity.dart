import 'package:flutter/cupertino.dart';

class GridItemEntity {
  final Offset localPosition;
  final Offset globalPosition;
  final Size size;
  final Widget item;
  final int orderId;

  const GridItemEntity({
    required this.localPosition,
    required this.globalPosition,
    required this.size,
    required this.item,
    required this.orderId,
  });

  GridItemEntity copyWith({
    Offset? localPosition,
    Offset? globalPosition,
    int? orderId,
  }) =>
      GridItemEntity(
        localPosition: localPosition ?? this.localPosition,
        globalPosition: globalPosition ?? this.globalPosition,
        size: size,
        item: item,
        orderId: orderId ?? this.orderId,
      );
}
