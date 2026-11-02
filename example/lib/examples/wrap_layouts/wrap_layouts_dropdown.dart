import 'package:flutter/material.dart';

/// Labeled dropdown to pick one of [values] for a layout value of the [Wrap].
class WrapLayoutsDropdown<T extends Enum> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> values;
  final ValueChanged<T> onChanged;

  const WrapLayoutsDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: '),
          DropdownButton<T>(
            value: value,
            isDense: true,
            items: [
              for (final value in values)
                DropdownMenuItem(value: value, child: Text(value.name)),
            ],
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ],
      );
}
