import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view_example/examples/playground/playground_type.dart';

/// Dropdown to switch between the layouts of the playground.
class PlaygroundTypeDropdown extends StatelessWidget {
  final PlaygroundType value;
  final ValueChanged<PlaygroundType> onChanged;

  const PlaygroundTypeDropdown({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) => DropdownButton<PlaygroundType>(
        value: value,
        icon: const Icon(Icons.arrow_drop_down_rounded),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        items: [
          for (final type in PlaygroundType.values)
            DropdownMenuItem(value: type, child: Text(type.name)),
        ],
      );
}
