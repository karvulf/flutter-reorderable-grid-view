import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

/// Void callback which contains ReorderableEntity as parameter.
typedef ReorderableEntityCallback = void Function(
  ReorderableEntity reorderableEntity,
);

/// Callback which contains ReorderableEntity as parameter.
///
/// Expects to return the updated ReorderableEntity.
typedef ReturnReorderableEntityCallback = ReorderableEntity Function(
  ReorderableEntity reorderableEntity,
);

/// Void callback which contains ReleasedReorderableEntity as parameter.
typedef ReleasedReorderableEntityCallback = void Function(
  ReleasedReorderableEntity releasedReorderableEntity,
);

/// Callback after creating widget that contains ReorderableEntity and a key.
///
/// The key is related to reorderableEntity and will be used to determine
/// size and position of the widget.
typedef OnCreatedFunction = void Function(
  ReorderableEntity reorderableEntity,
  GlobalKey key,
);

/// Callback after creating widget that contains ReorderableEntity and a key.
///
/// The key is related to reorderableEntity and will be used to determine
/// size and position of the widget.
///
/// Expects to return the updated ReorderableEntity.
typedef ReturnOnCreatedFunction = ReorderableEntity Function(
  ReorderableEntity reorderableEntity,
  GlobalKey key,
);

/// Called after the position of the dragged child updates.
typedef OnDragUpdateFunction = Function(
  DragUpdateDetails details,
);
