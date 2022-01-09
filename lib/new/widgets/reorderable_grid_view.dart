import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/new/widgets/reorderable_builder.dart';

class ReorderableGridView2 extends StatelessWidget {
  final List<Widget> children;

  final EdgeInsets? padding;
  final Clip? clipBehavior;

  const ReorderableGridView2({
    required this.children,
    this.padding,
    this.clipBehavior,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableBuilder(
      children: children,
      onReorder: (_, __) {},
      builder: (draggableChildren) {
        return GridView(
          // key: _reorderableKey,
          // shrinkWrap: true,
          padding: padding,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 8,
          ),
          clipBehavior: clipBehavior ?? Clip.hardEdge,
          children: draggableChildren,
        );
      },
    );
  }
}
