import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view_example/widgets/container_button.dart';

class ChangeChildrenBar extends StatelessWidget {
  final VoidCallback onTapUpdateChild;
  final VoidCallback onTapAddChild;
  final VoidCallback onTapRemoveChild;
  final VoidCallback onTapClear;

  const ChangeChildrenBar({
    required this.onTapUpdateChild,
    required this.onTapAddChild,
    required this.onTapRemoveChild,
    required this.onTapClear,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            ContainerButton(
              onTap: onTapUpdateChild,
              color: Colors.deepOrangeAccent,
              icon: Icons.find_replace,
            ),
            ContainerButton(
              onTap: onTapAddChild,
              color: Colors.green,
              icon: Icons.add,
            ),
            ContainerButton(
              onTap: onTapRemoveChild,
              color: Colors.red,
              icon: Icons.remove,
            ),
            ContainerButton(
              onTap: onTapClear,
              color: Colors.yellowAccent,
              icon: Icons.delete,
            ),
          ],
        ),
      ),
    );
  }
}
