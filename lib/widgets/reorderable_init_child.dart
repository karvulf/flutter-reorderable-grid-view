import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/definitions.dart';

/// Widget that calls [onCreated] if [reorderableEntity] is new.
///
/// When the flag "isBuildingOffset" is true, then it means the [child] is new
/// and is currently building. In that time, the visibility of this widget is
/// false to ensure that the positioning can start at the correct position
/// when the [child] was built.
class ReorderableInitChild extends StatefulWidget {
  /// Returns this child with [Visibility] wrapped.
  final Widget child;

  /// Used to obtain more info about the [child].
  final ReorderableEntity reorderableEntity;

  /// Called when "buildingOffset" of [reorderableEntity] is true and the child was built.
  final OnCreatedFunction onCreated;

  /// Calls [onCreated] after this delay.
  ///
  /// Warning: You should prevent using this. Sometimes there are "heavy" widgets
  /// e. g. widgets with images that needs more time to be loaded. In these
  /// cases [initDelay] can be useful to ensure that the drag and drop works
  /// correctly with correct calculated positions.
  final Duration? initDelay;

  const ReorderableInitChild({
    required this.child,
    required this.reorderableEntity,
    required this.onCreated,
    this.initDelay,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableInitChild> createState() => _ReorderableInitChildState();
}

class _ReorderableInitChildState extends State<ReorderableInitChild> {
  /// Key for Visibility wrapped with [widget.child].
  final _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    final initDelay = widget.initDelay;

    if (initDelay != null) {
      Future.delayed(initDelay).then((value) {
        widget.onCreated(widget.reorderableEntity, _globalKey);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        widget.onCreated(widget.reorderableEntity, _globalKey);
      });
    }
  }

  @override
  void didUpdateWidget(covariant ReorderableInitChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEntity = oldWidget.reorderableEntity;
    final newEntity = widget.reorderableEntity;

    // this case can happen if the orientation changed
    if (oldEntity.isBuildingOffset != newEntity.isBuildingOffset &&
        newEntity.isBuildingOffset) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCreated(widget.reorderableEntity, _globalKey);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      key: _globalKey,
      visible: visible,
      maintainAnimation: true,
      maintainSize: true,
      maintainState: true,
      child: widget.child,
    );
  }

  /// Returns true if "isBuildingOffset" of [widget.reorderableEntity] is false.
  bool get visible {
    final reorderableEntity = widget.reorderableEntity;
    return !reorderableEntity.isBuildingOffset;
  }
}
