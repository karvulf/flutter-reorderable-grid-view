import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view_example/examples/apple_style/apple_style_colors.dart';
import 'package:flutter_reorderable_grid_view_example/examples/apple_style/apple_style_tile.dart';

/// Card of [tile] that is removed by tapping it.
class AppleStyleTileCard extends StatelessWidget {
  final AppleStyleTile tile;
  final VoidCallback onTap;

  const AppleStyleTileCard({
    required this.tile,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppleStyleColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x14FFFFFF)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(tile.icon, color: AppleStyleColors.label, size: 28),
                const Spacer(),
                Text(
                  tile.title,
                  style: const TextStyle(
                    color: AppleStyleColors.label,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Tap to remove',
                  style: TextStyle(
                    color: AppleStyleColors.secondaryLabel,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
