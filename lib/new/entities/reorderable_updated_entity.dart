import 'package:flutter/cupertino.dart';

class ReorderableUpdatedEntity {
  final Offset offset;
  final int? oldIndex;
  final int? newIndex;

  const ReorderableUpdatedEntity({
    required this.offset,
    this.oldIndex,
    this.newIndex,
  });
}
