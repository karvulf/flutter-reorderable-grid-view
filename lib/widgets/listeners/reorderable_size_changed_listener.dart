import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_builder_type.dart';

/// Listener to detect any size changes in [child].
///
/// Calls [onSizeChanged] after the size of [child] has changed, e.g.
/// after orientation change or one of the children in GridView changed the size.
///
/// Wraps either all children of ReorderableBuilder or a single child with
/// [childKey].
class ReorderableSizeChangedListener extends SingleChildRenderObjectWidget {
  final VoidCallback onSizeChanged;

  /// Type of ReorderableBuilder that uses this listener.
  final ReorderableBuilderType type;

  /// Key of the single child in [child], null if [child] contains all children.
  ///
  /// In a [Wrap], children at the same index can have different sizes, so
  /// this listener is keyed with [childKey] to stay with its child. Otherwise
  /// it would report a size change after reordering.
  final Key? childKey;

  ReorderableSizeChangedListener({
    required this.onSizeChanged,
    required this.type,
    required super.child,
    this.childKey,
  }) : super(
          key: type == ReorderableBuilderType.wrap && childKey != null
              ? ValueKey(childKey)
              : null,
        );

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderReorderableSizeChangedListener(
        onSizeChanged,
        reportsOnlyWidth: _reportsOnlyWidth,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderReorderableSizeChangedListener renderObject,
  ) {
    renderObject
      ..onSizeChanged = onSizeChanged
      ..reportsOnlyWidth = _reportsOnlyWidth;
  }

  /// Checks if only a new available width should be reported.
  ///
  /// A [Wrap] changes its own size when its children change their order,
  /// e.g. when a new run is needed. That doesn't change the positions of the
  /// children, but a new available width does. Single children always report
  /// their new size.
  bool get _reportsOnlyWidth =>
      type == ReorderableBuilderType.wrap && childKey == null;
}

class RenderReorderableSizeChangedListener extends RenderProxyBox {
  VoidCallback onSizeChanged;

  /// Only reports a change of the available width instead of the size.
  bool reportsOnlyWidth;

  Object? _previousValue;

  RenderReorderableSizeChangedListener(
    this.onSizeChanged, {
    this.reportsOnlyWidth = false,
  });

  @override
  void performLayout() {
    super.performLayout();

    final value = reportsOnlyWidth ? constraints.maxWidth : size;

    if (_previousValue != null && _previousValue != value) {
      // Called after the frame because a rebuild isn't allowed during layout.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (attached) onSizeChanged();
      });
    }
    _previousValue = value;
  }
}
