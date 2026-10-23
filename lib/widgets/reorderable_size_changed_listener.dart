import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Calls [onSizeChanged] after the frame in which [child] was laid out with a
/// different size than before (not on the first layout).
class ReorderableSizeChangedListener extends SingleChildRenderObjectWidget {
  final VoidCallback onSizeChanged;

  const ReorderableSizeChangedListener({
    required this.onSizeChanged,
    required super.child,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderReorderableSizeChangedListener(onSizeChanged);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderReorderableSizeChangedListener renderObject,
  ) {
    renderObject.onSizeChanged = onSizeChanged;
  }
}

class RenderReorderableSizeChangedListener extends RenderProxyBox {
  VoidCallback onSizeChanged;
  Size? _previousSize;

  RenderReorderableSizeChangedListener(this.onSizeChanged);

  @override
  void performLayout() {
    super.performLayout();
    if (_previousSize != null && _previousSize != size) {
      // Called after the frame because a rebuild isn't allowed during layout.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (attached) onSizeChanged();
      });
    }
    _previousSize = size;
  }
}
