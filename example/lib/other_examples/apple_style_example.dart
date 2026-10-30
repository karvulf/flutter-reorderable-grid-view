import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

/// Calm, Apple-like insert, remove and drag feedback animations.
///
/// Tap + to insert a widget, tap a widget to remove it, long press to drag.
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AppleStyleExample(),
  ));
}

class _Tile {
  final int id;
  final String title;
  final IconData icon;

  const _Tile(this.id, this.title, this.icon);
}

const _items = [
  ('Weather', Icons.wb_sunny_outlined),
  ('Music', Icons.music_note_outlined),
  ('Fitness', Icons.favorite_border_rounded),
  ('Notes', Icons.edit_note_rounded),
  ('Photos', Icons.photo_outlined),
  ('Maps', Icons.navigation_outlined),
  ('Wallet', Icons.account_balance_wallet_outlined),
  ('Mail', Icons.mail_outline_rounded),
];

const _label = Color(0xFFF5F5F7);
const _secondaryLabel = Color(0xFF8E8E93);
const _surface = Color(0xFF1C1C1E);

/// Smooth deceleration similar to iOS spring animations.
const _ease = Cubic(0.2, 0.9, 0.3, 1.0);

class AppleStyleExample extends StatefulWidget {
  const AppleStyleExample({super.key});

  @override
  State<AppleStyleExample> createState() => _AppleStyleExampleState();
}

class _AppleStyleExampleState extends State<AppleStyleExample> {
  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();
  late var _tiles = List.generate(6, _createTile);
  var _nextId = 6;

  static _Tile _createTile(int id) {
    final (title, icon) = _items[id % _items.length];
    return _Tile(id, title, icon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Widgets',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: _label,
                      ),
                    ),
                  ),
                  _HeaderButton(
                    icon: Icons.remove_rounded,
                    onPressed: _tiles.isEmpty
                        ? null
                        : () => setState(() => _tiles = _tiles.sublist(1)),
                  ),
                  const SizedBox(width: 8),
                  _HeaderButton(
                    icon: Icons.add_rounded,
                    onPressed: () => setState(
                      () => _tiles = [..._tiles, _createTile(_nextId++)],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return ReorderableBuilder.builder(
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
        defaultAnimationCurve: _ease,
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
      onReorder: (ReorderedListFunction<_Tile> reorderedListFunction) {
        setState(() => _tiles = reorderedListFunction(_tiles));
      },
      itemCount: _tiles.length,
      childBuilder: (itemBuilder) {
        return GridView.builder(
          key: _gridViewKey,
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          itemCount: _tiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final tile = _tiles[index];
            return itemBuilder(
              _TileCard(
                key: Key(tile.id.toString()),
                tile: tile,
                onTap: () => setState(
                  () => _tiles = [..._tiles]..remove(tile),
                ),
              ),
              index,
            );
          },
        );
      },
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _HeaderButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: _surface,
        foregroundColor: _label,
        disabledBackgroundColor: _surface,
        disabledForegroundColor: _secondaryLabel.withValues(alpha: 0.4),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _TileCard extends StatelessWidget {
  final _Tile tile;
  final VoidCallback onTap;

  const _TileCard({required this.tile, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x14FFFFFF)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(tile.icon, color: _label, size: 28),
              const Spacer(),
              Text(
                tile.title,
                style: const TextStyle(
                  color: _label,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Tap to remove',
                style: TextStyle(color: _secondaryLabel, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
