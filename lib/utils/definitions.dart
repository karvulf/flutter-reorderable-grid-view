import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

typedef ReorderableEntityCallback = void Function(
  ReorderableEntity reorderableEntity,
);

typedef ReorderableEntityCallback2 = ReorderableEntity Function(
  ReorderableEntity reorderableEntity,
);

typedef ReorderableBuilderCallback = Widget Function(
  ReorderableEntity reorderableEntity,
);

typedef ReleasedReorderableEntityCallback = void Function(
  ReleasedReorderableEntity releasedReorderableEntity,
);

/// Called after dragging of child ends.
typedef OnDragEndFunction = void Function(
  ReorderableEntity reorderableEntity,
  Offset globalOffset,
);

/// Called if drag was canceled, e.g. the dragged item is removed while dragging.
typedef OnDragCanceledFunction = void Function(
  ReorderableEntity reorderableEntity,
);

typedef OnCreatedFunction = void Function(
  ReorderableEntity reorderableEntity,
  GlobalKey key,
);

typedef OnDragUpdateFunction = Function(
  DragUpdateDetails details,
);
