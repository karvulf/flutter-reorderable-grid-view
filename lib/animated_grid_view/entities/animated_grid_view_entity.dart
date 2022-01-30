import 'package:flutter/cupertino.dart';

class AnimatedGridViewEntity {
  final Widget child;
  final Size size;

  final int originalOrderId;
  final int updatedOrderId;

  final Offset originalOffset;
  final Offset updatedOffset;

  final bool isBuilding;

  const AnimatedGridViewEntity({
    required this.child,
    required this.originalOrderId,
    required this.updatedOrderId,
    this.originalOffset = Offset.zero,
    this.updatedOffset = Offset.zero,
    this.size = Size.zero,
    this.isBuilding = false,
  });

  AnimatedGridViewEntity copyWith({
    Offset? originalOffset,
    Offset? updatedOffset,
    Widget? child,
    Size? size,
    int? originalOrderId,
    int? updatedOrderId,
    bool? isBuilding,
  }) =>
      AnimatedGridViewEntity(
        size: size ?? this.size,
        originalOffset: originalOffset ?? this.originalOffset,
        updatedOffset: updatedOffset ?? this.updatedOffset,
        child: child ?? this.child,
        updatedOrderId: updatedOrderId ?? this.updatedOrderId,
        originalOrderId: originalOrderId ?? this.originalOrderId,
        isBuilding: isBuilding ?? this.isBuilding,
      );

  int get keyHashCode => child.key.hashCode;
}
