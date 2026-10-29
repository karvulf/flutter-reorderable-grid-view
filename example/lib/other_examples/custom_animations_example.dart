import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

/// Custom insert, remove and drag feedback animations.
///
/// Tap + to insert a child, tap - or a child to remove it, long press to drag.
void main() {
  runApp(const MaterialApp(home: CustomAnimationsExample()));
}

class CustomAnimationsExample extends StatefulWidget {
  const CustomAnimationsExample({super.key});

  @override
  State<CustomAnimationsExample> createState() =>
      _CustomAnimationsExampleState();
}

class _CustomAnimationsExampleState extends State<CustomAnimationsExample> {
  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();
  var _items = List.generate(8, (index) => index);
  var _nextItem = 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom animations')),
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
      body: ReorderableBuilder.builder(
        scrollController: _scrollController,
        animationConfig: ReorderableAnimationConfig(
          changePositionAfterFadeOut: true,
          // pops in with an elastic spin
          insert: ReorderableItemTransition(
            duration: const Duration(milliseconds: 900),
            curve: Curves.elasticOut,
            builder: (child, animation) => RotationTransition(
              turns: Tween(begin: -0.25, end: 0.0).animate(animation),
              child: ScaleTransition(scale: animation, child: child),
            ),
          ),
          // spins away while shrinking and fading
          remove: ReorderableItemTransition(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInBack,
            builder: (child, animation) => FadeTransition(
              opacity: animation,
              child: RotationTransition(
                turns: Tween(begin: 0.5, end: 0.0).animate(animation),
                child: ScaleTransition(scale: animation, child: child),
              ),
            ),
          ),
          // lifts up with a playful tilt
          dragFeedback: ReorderableItemTransition(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (child, animation) => RotationTransition(
              turns: Tween(begin: 0.0, end: 0.03).animate(animation),
              child: ScaleTransition(
                scale: Tween(begin: 1.0, end: 1.2).animate(animation),
                child: child,
              ),
            ),
          ),
        ),
        onReorder: (ReorderedListFunction<int> reorderedListFunction) {
          setState(() => _items = reorderedListFunction(_items));
        },
        itemCount: _items.length,
        childBuilder: (itemBuilder) {
          return GridView.builder(
            key: _gridViewKey,
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final item = _items[index];
              return itemBuilder(
                GestureDetector(
                  key: Key(item.toString()),
                  onTap: () => setState(
                    () => _items = [..._items]..remove(item),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.primaries[item % Colors.primaries.length],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '$item',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                index,
              );
            },
          );
        },
      ),
    );
  }
}
