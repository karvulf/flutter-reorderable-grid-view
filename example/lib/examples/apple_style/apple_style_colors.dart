import 'package:flutter/widgets.dart';

/// Colors and curve of the Apple style example.
abstract final class AppleStyleColors {
  static const label = Color(0xFFF5F5F7);
  static const secondaryLabel = Color(0xFF8E8E93);
  static const surface = Color(0xFF1C1C1E);

  /// Smooth deceleration similar to iOS spring animations.
  static const ease = Cubic(0.2, 0.9, 0.3, 1.0);
}
