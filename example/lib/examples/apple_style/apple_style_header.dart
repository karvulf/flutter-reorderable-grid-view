import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view_example/examples/apple_style/apple_style_colors.dart';
import 'package:flutter_reorderable_grid_view_example/examples/apple_style/apple_style_header_button.dart';

/// Large title with buttons to remove the first and add a new widget.
class AppleStyleHeader extends StatelessWidget {
  final VoidCallback? onRemove;
  final VoidCallback onAdd;

  const AppleStyleHeader({
    required this.onRemove,
    required this.onAdd,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
        child: Row(
          spacing: 8,
          children: [
            const Expanded(
              child: Text(
                'Widgets',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: AppleStyleColors.label,
                ),
              ),
            ),
            AppleStyleHeaderButton(
              icon: Icons.remove_rounded,
              onPressed: onRemove,
            ),
            AppleStyleHeaderButton(icon: Icons.add_rounded, onPressed: onAdd),
          ],
        ),
      );
}
