import 'package:flutter/material.dart';

/// Child of the playground showing [value].
///
/// Locked children are shown in the disabled color.
class PlaygroundChild extends StatelessWidget {
  final int value;
  final bool isLocked;
  final double width;

  const PlaygroundChild({
    required this.value,
    required this.isLocked,
    this.width = 100.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: isLocked ? theme.disabledColor : theme.colorScheme.primary,
      height: 100.0,
      width: width,
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
