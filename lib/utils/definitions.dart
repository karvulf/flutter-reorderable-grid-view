import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

typedef ReorderableEntityCallback = void Function(
  ReorderableEntity reorderableEntity,
);

typedef ReleasedReorderableEntityCallback = void Function(
    ReleasedReorderableEntity releasedReorderableEntity);

///
///
/// If [globalOffset] is null then [reorderableEntity] was removed before the
/// drag was finished.
typedef OnDragEndFunction = void Function(
  ReorderableEntity reorderableEntity,
  Offset? globalOffset,
);

typedef OnCreatedFunction = void Function(
  ReorderableEntity reorderableEntity,
  GlobalKey key,
);

typedef OnDragUpdateFunction = Function(
  DragUpdateDetails details,
);
