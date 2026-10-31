import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Listener to detect any size changes in [child].
///
/// Calls [onSizeChanged] after the size of [child] has changed, e.g.
/// after orientation change or one of the children in GridView changed the size.
class ReorderableSizeChangedListener extends SingleChildRenderObjectWidget {
  final VoidCallback onSizeChanged;

  /// Only reports a change when the available width changed.
  ///
  /// Used for [Wrap], which changes its own size when its children change
  /// their order, e.g. when a new run is needed. That doesn't change the
  /// positions of the children, but a new available width does.
  final bool onlyAvailableWidth;

  const ReorderableSizeChangedListener({
    required this.onSizeChanged,
    required super.child,
    this.onlyAvailableWidth = false,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderReorderableSizeChangedListener(
        onSizeChanged,
        onlyAvailableWidth: onlyAvailableWidth,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderReorderableSizeChangedListener renderObject,
  ) {
    renderObject
      ..onSizeChanged = onSizeChanged
      ..onlyAvailableWidth = onlyAvailableWidth;
  }
}

class RenderReorderableSizeChangedListener extends RenderProxyBox {
  VoidCallback onSizeChanged;
  bool onlyAvailableWidth;
  Object? _previousValue;

  RenderReorderableSizeChangedListener(
    this.onSizeChanged, {
    this.onlyAvailableWidth = false,
  });

  @override
  void performLayout() {
    super.performLayout();

    final value = onlyAvailableWidth ? constraints.maxWidth : size;
    if (_previousValue != null && _previousValue != value) {
      // Called after the frame because a rebuild isn't allowed during layout.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (attached) onSizeChanged();
      });
    }
    _previousValue = value;
  }
}
