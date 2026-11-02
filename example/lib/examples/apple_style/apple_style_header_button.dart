import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view_example/examples/apple_style/apple_style_colors.dart';

/// Round button in the header, disabled when [onPressed] is null.
class AppleStyleHeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const AppleStyleHeaderButton({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) => IconButton.filled(
        style: IconButton.styleFrom(
          backgroundColor: AppleStyleColors.surface,
          foregroundColor: AppleStyleColors.label,
          disabledBackgroundColor: AppleStyleColors.surface,
          disabledForegroundColor:
              AppleStyleColors.secondaryLabel.withValues(alpha: 0.4),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
      );
}
