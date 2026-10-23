import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Listener to detect any size changes in [child].
///
/// Calls [onSizeChanged] after the size of [child] has changed, e.g.
/// after orientation change or one of the children in GridView changed the size.
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
