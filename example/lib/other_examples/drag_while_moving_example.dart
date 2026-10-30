import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

/// Reproduces "Null check operator used on a null value" in _wrapChildren.
///
/// 1. Tap "Remove first" -> all children animate one position back.
/// 2. Immediately drag a child (no long press) back and forth across the
///    moving children until their move animations end.
/// On the unfixed version, a swap in the frame a move finishes crashes.
void main() => runApp(const MaterialApp(home: DragWhileMovingExample()));

class DragWhileMovingExample extends StatefulWidget {
  const DragWhileMovingExample({super.key});

  @override
  State<DragWhileMovingExample> createState() => _DragWhileMovingExampleState();
}

class _DragWhileMovingExampleState extends State<DragWhileMovingExample> {
  final _scrollController = ScrollController();
  var _items = List.generate(40, (i) => i);
  var _next = 40;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _items = [..._items.skip(1), _next++];
            }),
            child: const Text('Remove first'),
          ),
        ],
      ),
      body: ReorderableBuilder<int>(
        scrollController: _scrollController,
        longPressDelay: Duration.zero,
        animationConfig: const ReorderableAnimationConfig(
          positionChangeDuration: Duration(milliseconds: 800),
        ),
        onReorder: (reorder) => setState(() => _items = reorder(_items)),
        children: [
          for (final item in _items)
            Container(
              key: ValueKey(item.toString()),
              color: Colors.lightBlue,
              alignment: Alignment.center,
              child: Text('$item'),
            ),
        ],
        builder: (children) => GridView(
          controller: _scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          children: children,
        ),
      ),
    );
  }
}
