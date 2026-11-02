import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view_example/examples/apple_style/apple_style_grid.dart';
import 'package:flutter_reorderable_grid_view_example/examples/apple_style/apple_style_header.dart';
import 'package:flutter_reorderable_grid_view_example/examples/apple_style/apple_style_tile.dart';

/// Calm, Apple-like insert, remove and drag feedback animations.
///
/// Tap + to insert a widget, tap a widget to remove it, long press to drag.
class AppleStyleExample extends StatefulWidget {
  const AppleStyleExample({super.key});

  @override
  State<AppleStyleExample> createState() => _AppleStyleExampleState();
}

class _AppleStyleExampleState extends State<AppleStyleExample> {
  var _tiles = List.generate(6, AppleStyleTile.fromId);
  var _nextId = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppleStyleHeader(
              onRemove: _tiles.isEmpty
                  ? null
                  : () => setState(() => _tiles = _tiles.sublist(1)),
              onAdd: () => setState(() {
                _tiles = [..._tiles, AppleStyleTile.fromId(_nextId++)];
              }),
            ),
            Expanded(
              child: AppleStyleGrid(
                tiles: _tiles,
                onReorder: (reorderedListFunction) {
                  setState(() => _tiles = reorderedListFunction(_tiles));
                },
                onRemove: (tile) => setState(() {
                  _tiles = [..._tiles]..remove(tile);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
