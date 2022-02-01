import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class ReorderableEntity extends Equatable {
  final Widget child;
  final Size size;

  final int originalOrderId;
  final int updatedOrderId;

  final Offset originalOffset;
  final Offset updatedOffset;

  const ReorderableEntity({
    required this.child,
    required this.originalOrderId,
    required this.updatedOrderId,
    this.originalOffset = Offset.zero,
    this.updatedOffset = Offset.zero,
    this.size = Size.zero,
  });

  ReorderableEntity copyWith({
    Offset? originalOffset,
    Offset? updatedOffset,
    Widget? child,
    Size? size,
    int? originalOrderId,
    int? updatedOrderId,
  }) =>
      ReorderableEntity(
        size: size ?? this.size,
        originalOffset: originalOffset ?? this.originalOffset,
        updatedOffset: updatedOffset ?? this.updatedOffset,
        child: child ?? this.child,
        updatedOrderId: updatedOrderId ?? this.updatedOrderId,
        originalOrderId: originalOrderId ?? this.originalOrderId,
      );

  @override
  List<Object?> get props => [
        size,
        originalOffset,
        updatedOffset,
        child,
        updatedOrderId,
        originalOrderId,
      ];
}
