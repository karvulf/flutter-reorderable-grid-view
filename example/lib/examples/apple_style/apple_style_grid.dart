import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:flutter_reorderable_grid_view_example/examples/apple_style/apple_style_colors.dart';
import 'package:flutter_reorderable_grid_view_example/examples/apple_style/apple_style_tile.dart';
import 'package:flutter_reorderable_grid_view_example/examples/apple_style/apple_style_tile_card.dart';

/// Reorderable grid of [tiles] with calm Apple-like animations.
class AppleStyleGrid extends StatefulWidget {
  final List<AppleStyleTile> tiles;
  final OnReorderCallback<AppleStyleTile> onReorder;
  final ValueChanged<AppleStyleTile> onRemove;

  const AppleStyleGrid({
    required this.tiles,
    required this.onReorder,
    required this.onRemove,
    super.key,
  });

  @override
  State<AppleStyleGrid> createState() => _AppleStyleGridState();
}

class _AppleStyleGridState extends State<AppleStyleGrid> {
  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiles = widget.tiles;

    return ReorderableBuilder<AppleStyleTile>.builder(
      scrollController: _scrollController,
      longPressDelay: const Duration(milliseconds: 350),
      dragChildBoxDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      animationConfig: ReorderableAnimationConfig(
        defaultAnimationCurve: AppleStyleColors.ease,
        positionChangeDuration: const Duration(milliseconds: 450),
        draggingPositionChangeDuration: const Duration(milliseconds: 350),
        releasedItemDuration: const Duration(milliseconds: 350),
        // grows softly from slightly smaller while fading in
        insert: ReorderableItemTransition(
          duration: const Duration(milliseconds: 550),
          builder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.85, end: 1.0).animate(animation),
              child: child,
            ),
          ),
        ),
        // shrinks a little and dissolves
        remove: ReorderableItemTransition(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          builder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.8, end: 1.0).animate(animation),
              child: child,
            ),
          ),
        ),
        // lifts gently towards the user
        dragFeedback: ReorderableItemTransition(
          duration: const Duration(milliseconds: 300),
          builder: (child, animation) => ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.08).animate(animation),
            child: child,
          ),
        ),
      ),
      onReorder: widget.onReorder,
      itemCount: tiles.length,
      childBuilder: (itemBuilder) => GridView.builder(
        key: _gridViewKey,
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        itemCount: tiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final tile = tiles[index];
          return itemBuilder(
            AppleStyleTileCard(
              key: Key(tile.id.toString()),
              tile: tile,
              onTap: () => widget.onRemove(tile),
            ),
            index,
          );
        },
      ),
    );
  }
}
