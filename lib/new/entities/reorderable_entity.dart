import 'package:flutter/cupertino.dart';

class ReorderableEntity {
  final Offset position;
  final Size size;

  const ReorderableEntity({
    required this.position,
    required this.size,
  });
}
