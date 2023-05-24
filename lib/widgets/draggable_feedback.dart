import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';

class DraggableFeedback extends StatelessWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;
  final Animation<Decoration> decoration;

  const DraggableFeedback({
    required this.child,
    required this.reorderableEntity,
    required this.decoration,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = reorderableEntity.size;

    return Material(
      color: Colors.transparent, // removes white corners when having shadow
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: DecoratedBoxTransition(
          position: DecorationPosition.background,
          decoration: decoration,
          child: child,
        ),
      ),
    );
  }
}
