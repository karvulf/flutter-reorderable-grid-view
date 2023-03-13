import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/definitions.dart';

class ReorderableInitChild extends StatefulWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;

  final OnCreatedFunction onCreated;

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
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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

  bool get visible {
    final reorderableEntity = widget.reorderableEntity;
    return !reorderableEntity.isBuildingOffset;
  }
}
