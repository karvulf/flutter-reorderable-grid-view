import 'package:flutter/material.dart';

/// Child of the [Wrap] with a size depending on [item].
///
/// Locked children are grey.
class WrapLayoutsChild extends StatelessWidget {
  final int item;
  final bool isLocked;

  const WrapLayoutsChild({
    required this.item,
    required this.isLocked,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: 50.0 + (item % 4) * 30.0,
        height: 40.0 + (item % 3) * 20.0,
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.grey
              : Colors.primaries[item % Colors.primaries.length],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          '$item',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
