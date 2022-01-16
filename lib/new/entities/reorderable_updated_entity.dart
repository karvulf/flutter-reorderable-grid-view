import 'package:flutter/cupertino.dart';

class ReorderableUpdatedEntity {
  final Offset offset;
  final int newOrderId;
  final int? oldIndex;
  final int? newIndex;

  const ReorderableUpdatedEntity({
    required this.offset,
    required this.newOrderId,
    this.oldIndex,
    this.newIndex,
  });
}
