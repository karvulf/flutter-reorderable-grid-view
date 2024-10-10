import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

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
  final void Function(GlobalKey key) onCreated;

  const ReorderableInitChild({
    required this.child,
    required this.reorderableEntity,
    required this.onCreated,
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

    _handleCreatedChild();
  }

  @override
  void didUpdateWidget(covariant ReorderableInitChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEntity = oldWidget.reorderableEntity;
    final newEntity = widget.reorderableEntity;

    // this case can happen if the orientation changed
    if (oldEntity.isBuildingOffset != newEntity.isBuildingOffset &&
        newEntity.isBuildingOffset) {
      _handleCreatedChild();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: _globalKey,
      child: widget.child,
    );
  }

  void _handleCreatedChild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCreated(_globalKey);
    });
  }
}
