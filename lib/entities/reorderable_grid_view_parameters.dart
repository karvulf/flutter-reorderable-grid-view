import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_type.dart';

abstract class ReorderableGridViewParameters {
  final ReorderableType reorderableType = ReorderableType.gridView;

  final int? crossAxisCount = null;

  final double mainAxisSpacing = 0.0;

  final bool shrinkWrap = false;

  final ScrollPhysics? physics = null;

  final double maxCrossAxisExtent = 0.0;

  final Clip clipBehavior = Clip.hardEdge;

  final double crossAxisSpacing = 0.0;
}