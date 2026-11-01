import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

/// Drag and drop in a [Wrap] with every kind of layout.
///
/// Change the layout of the [Wrap] with the dropdowns at the top.
/// Tap + to add a child, - to remove the first one and long press to drag.
/// The grey child is locked.
void main() {
  runApp(const MaterialApp(home: WrapLayoutsExample()));
}

class WrapLayoutsExample extends StatefulWidget {
  const WrapLayoutsExample({super.key});

  @override
  State<WrapLayoutsExample> createState() => _WrapLayoutsExampleState();
}

class _WrapLayoutsExampleState extends State<WrapLayoutsExample> {
  static const _lockedIndices = [2];

  var _items = List.generate(12, (index) => index);
  var _nextItem = 12;

  var _direction = Axis.horizontal;
  var _alignment = WrapAlignment.start;
  var _runAlignment = WrapAlignment.start;
  var _crossAxisAlignment = WrapCrossAlignment.start;
  var _textDirection = TextDirection.ltr;
  var _verticalDirection = VerticalDirection.down;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wrap layouts')),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'remove',
            onPressed: _items.isEmpty
                ? null
                : () => setState(() => _items = _items.sublist(1)),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => setState(() => _items = [..._items, _nextItem++]),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildDropdown(
                  label: 'direction',
                  value: _direction,
                  values: Axis.values,
                  onChanged: (value) => setState(() => _direction = value),
                ),
                _buildDropdown(
                  label: 'alignment',
                  value: _alignment,
                  values: WrapAlignment.values,
                  onChanged: (value) => setState(() => _alignment = value),
                ),
                _buildDropdown(
                  label: 'runAlignment',
                  value: _runAlignment,
                  values: WrapAlignment.values,
                  onChanged: (value) => setState(() => _runAlignment = value),
                ),
                _buildDropdown(
                  label: 'crossAxisAlignment',
                  value: _crossAxisAlignment,
                  values: WrapCrossAlignment.values,
                  onChanged: (value) {
                    setState(() => _crossAxisAlignment = value);
                  },
                ),
                _buildDropdown(
                  label: 'textDirection',
                  value: _textDirection,
                  values: TextDirection.values,
                  onChanged: (value) => setState(() => _textDirection = value),
                ),
                _buildDropdown(
                  label: 'verticalDirection',
                  value: _verticalDirection,
                  values: VerticalDirection.values,
                  onChanged: (value) {
                    setState(() => _verticalDirection = value);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ReorderableBuilder<int>.wrap(
                // a new layout moves the children without changing their size,
                // so all of them have to be measured again
                key: ValueKey(_layoutKey),
                lockedIndices: _lockedIndices,
                onReorder: (reorderedListFunction) {
                  setState(() => _items = reorderedListFunction(_items));
                },
                builder: (children) {
                  return Wrap(
                    direction: _direction,
                    alignment: _alignment,
                    runAlignment: _runAlignment,
                    crossAxisAlignment: _crossAxisAlignment,
                    textDirection: _textDirection,
                    verticalDirection: _verticalDirection,
                    spacing: 8,
                    runSpacing: 8,
                    children: children,
                  );
                },
                children: [
                  for (final (index, item) in _items.indexed)
                    _buildChild(item: item, index: index),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Changes whenever one of the layout values of the [Wrap] changes.
  String get _layoutKey => [
        _direction,
        _alignment,
        _runAlignment,
        _crossAxisAlignment,
        _textDirection,
        _verticalDirection,
      ].join();

  Widget _buildChild({required int item, required int index}) {
    final isLocked = _lockedIndices.contains(index);

    return Container(
      key: Key('$item'),
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

  Widget _buildDropdown<T extends Enum>({
    required String label,
    required T value,
    required List<T> values,
    required ValueChanged<T> onChanged,
  }) {
    return Row(
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
}
