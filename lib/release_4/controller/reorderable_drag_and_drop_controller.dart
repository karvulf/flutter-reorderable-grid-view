import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/release_4/controller/reorderable_controller.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';

class ReorderableDragAndDropController extends ReorderableController {
  ReorderableEntity? _draggedEntity;

  void handleDragStarted({required ReorderableEntity reorderableEntity}) {
    _draggedEntity = reorderableEntity;
  }

  void handleDragUpdate({required PointerMoveEvent pointerMoveEvent}) {
    //
  }

  void handleScrollUpdate({required double scrollPixels}) {
    //
  }

  void handleDragEnd() {
    _draggedEntity = null;
  }

  ReorderableEntity? get draggedEntity => _draggedEntity;
}
