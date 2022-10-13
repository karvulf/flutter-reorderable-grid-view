import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';

typedef OnCreatedFunction = void Function(
  GlobalKey key,
  ReorderableEntity reorderableEntity,
);

class ReorderableInitChild extends StatefulWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;

  final OnCreatedFunction onCreated;

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
  final _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.onCreated(_globalKey, widget.reorderableEntity);
    });
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
