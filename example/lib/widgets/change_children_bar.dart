import 'package:flutter/material.dart';

class ChangeChildrenBar extends StatelessWidget {
  final VoidCallback onTapUpdateChild;
  final VoidCallback onTapAddChild;
  final VoidCallback onTapRemoveChild;
  final VoidCallback onTapClear;
  final VoidCallback onTapSwap;

  const ChangeChildrenBar({
    required this.onTapUpdateChild,
    required this.onTapAddChild,
    required this.onTapRemoveChild,
    required this.onTapClear,
    required this.onTapSwap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Card(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                IconButton(
                  onPressed: onTapUpdateChild,
                  icon: const Icon(Icons.find_replace),
                ),
                IconButton(
                  onPressed: onTapAddChild,
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: onTapRemoveChild,
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  onPressed: onTapClear,
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: onTapSwap,
                  icon: const Icon(Icons.swap_horiz),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
