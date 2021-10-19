import 'package:flutter/cupertino.dart';

class GridItemEntity {
  final int id;
  final Offset localPosition;
  final Offset globalPosition;
  final Size size;
  final int orderId;

  const GridItemEntity({
    required this.id,
    required this.localPosition,
    required this.globalPosition,
    required this.size,
    required this.orderId,
  });

  GridItemEntity copyWith({
    Offset? localPosition,
    Offset? globalPosition,
    int? orderId,
    Size? size,
  }) =>
      GridItemEntity(
        id: id,
        localPosition: localPosition ?? this.localPosition,
        globalPosition: globalPosition ?? this.globalPosition,
        size: size ?? this.size,
        orderId: orderId ?? this.orderId,
      );
}
