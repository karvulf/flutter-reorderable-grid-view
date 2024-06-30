import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/definitions.dart';

class DraggableFeedback extends StatefulWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;
  final Animation<Decoration> decoration;
  final ReorderableEntityCallback onDeactivate;

  const DraggableFeedback({
    required this.child,
    required this.reorderableEntity,
    required this.decoration,
    required this.onDeactivate,
    Key? key,
  }) : super(key: key);

  @override
  State<DraggableFeedback> createState() => _DraggableFeedbackState();
}

class _DraggableFeedbackState extends State<DraggableFeedback> {
  @override
  void deactivate() {
    widget.onDeactivate(widget.reorderableEntity);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.reorderableEntity.size;

    return Material(
      color: Colors.transparent, // removes white corners when having shadow
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: DecoratedBoxTransition(
          position: DecorationPosition.background,
          decoration: widget.decoration,
          child: widget.child,
        ),
      ),
    );
  }
}
