import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:flutter_reorderable_grid_view_example/examples/wrap_layouts/wrap_layouts_child.dart';
import 'package:flutter_reorderable_grid_view_example/examples/wrap_layouts/wrap_layouts_dropdown.dart';

/// Drag and drop in a [Wrap] with every kind of layout.
///
/// Change the layout of the [Wrap] with the dropdowns at the top.
/// Tap + to add a child, - to remove the first one and long press to drag.
/// The grey child is locked.
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
                WrapLayoutsDropdown(
                  label: 'direction',
                  value: _direction,
                  values: Axis.values,
                  onChanged: (value) => setState(() => _direction = value),
                ),
                WrapLayoutsDropdown(
                  label: 'alignment',
                  value: _alignment,
                  values: WrapAlignment.values,
                  onChanged: (value) => setState(() => _alignment = value),
                ),
                WrapLayoutsDropdown(
                  label: 'runAlignment',
                  value: _runAlignment,
                  values: WrapAlignment.values,
                  onChanged: (value) => setState(() => _runAlignment = value),
                ),
                WrapLayoutsDropdown(
                  label: 'crossAxisAlignment',
                  value: _crossAxisAlignment,
                  values: WrapCrossAlignment.values,
                  onChanged: (value) {
                    setState(() => _crossAxisAlignment = value);
                  },
                ),
                WrapLayoutsDropdown(
                  label: 'textDirection',
                  value: _textDirection,
                  values: TextDirection.values,
                  onChanged: (value) => setState(() => _textDirection = value),
                ),
                WrapLayoutsDropdown(
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
                    WrapLayoutsChild(
                      key: Key('$item'),
                      item: item,
                      isLocked: _lockedIndices.contains(index),
                    ),
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
}
