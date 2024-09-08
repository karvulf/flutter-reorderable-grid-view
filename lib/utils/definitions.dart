import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

typedef ReorderableEntityCallback = void Function(
  ReorderableEntity reorderableEntity,
);

typedef ReturnReorderableEntityCallback = ReorderableEntity Function(
  ReorderableEntity reorderableEntity,
);

typedef ReleasedReorderableEntityCallback = void Function(
  ReleasedReorderableEntity releasedReorderableEntity,
);

typedef OnCreatedFunction = void Function(
  ReorderableEntity reorderableEntity,
  GlobalKey key,
);

typedef ReturnOnCreatedFunction = ReorderableEntity Function(
  ReorderableEntity reorderableEntity,
  GlobalKey key,
);

typedef OnDragUpdateFunction = Function(
  DragUpdateDetails details,
);
