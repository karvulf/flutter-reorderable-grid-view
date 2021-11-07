import 'package:flutter/cupertino.dart';

class GridItemEntity {
  final int id;
  final Offset localPosition;
  final Size size;
  final int orderId;
  final Widget child;

  const GridItemEntity({
    required this.id,
    required this.localPosition,
    required this.size,
    required this.orderId,
    required this.child,
  });

  GridItemEntity copyWith({
    Offset? localPosition,
    int? orderId,
    Size? size,
    Widget? child,
  }) =>
      GridItemEntity(
        id: id,
        localPosition: localPosition ?? this.localPosition,
        size: size ?? this.size,
        orderId: orderId ?? this.orderId,
        child: child ?? this.child,
      );
}
