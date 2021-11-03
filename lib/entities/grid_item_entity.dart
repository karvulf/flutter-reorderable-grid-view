import 'package:flutter/cupertino.dart';

class GridItemEntity {
  final int id;
  final Offset localPosition;
  final Size size;
  final int orderId;
  final Key? key;

  const GridItemEntity({
    required this.id,
    required this.localPosition,
    required this.size,
    required this.orderId,
    this.key,
  });

  GridItemEntity copyWith({
    Offset? localPosition,
    int? orderId,
    Size? size,
  }) =>
      GridItemEntity(
        id: id,
        localPosition: localPosition ?? this.localPosition,
        size: size ?? this.size,
        orderId: orderId ?? this.orderId,
        key: key,
      );
}
