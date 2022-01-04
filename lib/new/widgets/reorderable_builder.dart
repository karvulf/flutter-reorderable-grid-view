import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/new/widgets/reorderable_draggable.dart';

typedef DraggableBuilder = Widget Function(List<Widget> draggableChildren);

class ReorderableBuilder extends StatefulWidget {
  final List<Widget> children;
  final DraggableBuilder builder;

  const ReorderableBuilder({
    required this.children,
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  _ReorderableBuilderState createState() => _ReorderableBuilderState();
}

class _ReorderableBuilderState extends State<ReorderableBuilder> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(
      _getDraggableChildren(),
    );
  }

  List<Widget> _getDraggableChildren() {
    final draggableChildren = <Widget>[];

    for (final child in widget.children) {
      draggableChildren.add(ReorderableDraggable(
        child: child,
      ));
    }

    return draggableChildren;
  }
}
