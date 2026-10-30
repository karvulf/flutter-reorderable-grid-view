import 'package:flutter/widgets.dart';

/// Paints [child] in the [Overlay] above all other widgets.
///
/// [child] stays at the position of this widget, which keeps an empty box
/// with [size] in its place.
class ReorderableOverlayChild extends StatefulWidget {
  /// Size of [child] and of the empty box in its place.
  final Size size;

  final Widget child;

  const ReorderableOverlayChild({
    required this.size,
    required this.child,
    super.key,
  });

  @override
  State<ReorderableOverlayChild> createState() =>
      _ReorderableOverlayChildState();
}

class _ReorderableOverlayChildState extends State<ReorderableOverlayChild> {
  final _overlayController = OverlayPortalController()..show();
  final _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) => Positioned(
        left: 0,
        top: 0,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          child: SizedBox.fromSize(size: widget.size, child: widget.child),
        ),
      ),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: SizedBox.fromSize(size: widget.size),
      ),
    );
  }
}
