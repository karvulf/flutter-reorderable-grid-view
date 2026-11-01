import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/removed_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_builder_type.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/removed/reorderable_animated_removed_child.dart';

/// Shows removed children above [child] while they are fading out.
///
/// Removed children are recognized by comparing [children] of the previous
/// widget or by a decreased [itemCount] for ReorderableBuilder.builder.
class ReorderableRemovedChildren extends StatefulWidget {
  /// Widget of ReorderableBuilder that contains all children.
  final Widget child;

  /// Children of ReorderableBuilder, null when using ReorderableBuilder.builder.
  final List<Widget>? children;

  /// Item count of ReorderableBuilder.builder.
  final int? itemCount;

  /// Contains the offsets and sizes of all children.
  ///
  /// The children have to be updated before this widget is updated.
  final ReorderableController controller;

  /// Contains the duration and curve of the fade out.
  final ReorderableAnimationConfig animationConfig;

  /// Used to update the position of the removed children while scrolling.
  final ScrollController? scrollController;

  /// Returns the current scroll offset.
  final ValueGetter<Offset> getScrollOffset;

  /// Type of ReorderableBuilder that uses this widget.
  final ReorderableBuilderType type;

  const ReorderableRemovedChildren({
    required this.child,
    required this.children,
    required this.itemCount,
    required this.controller,
    required this.animationConfig,
    required this.scrollController,
    required this.getScrollOffset,
    required this.type,
    super.key,
  });

  @override
  State<ReorderableRemovedChildren> createState() =>
      _ReorderableRemovedChildrenState();
}

class _ReorderableRemovedChildrenState
    extends State<ReorderableRemovedChildren> {
  /// Removed children that are still shown while fading out.
  final _removedEntities = <RemovedReorderableEntity>[];

  /// Size of this widget before children were removed.
  ///
  /// Kept while [_removedEntities] are fading out.
  Size? _sizeBeforeRemoval;

  @override
  void didUpdateWidget(covariant ReorderableRemovedChildren oldWidget) {
    super.didUpdateWidget(oldWidget);

    final children = widget.children;

    if (children == null) {
      _checkRemovedBuiltChildren(oldItemCount: oldWidget.itemCount);
    } else if (children != oldWidget.children) {
      _updateRemovedEntities(oldChildren: oldWidget.children ?? const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final removedArea = _buildRemovedArea();

    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (removedArea != null) removedArea,
        // Ensures that removed children in scrollable GridViews
        // are visible on the outside of the GridView when fading them out
        Positioned.fill(
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final removedEntity in _removedEntities)
                  ReorderableAnimatedRemovedChild(
                    key: ObjectKey(removedEntity),
                    removedEntity: removedEntity,
                    animationConfig: widget.animationConfig,
                    scrollController: widget.scrollController,
                    getScrollOffset: widget.getScrollOffset,
                    onFinished: () => setState(() {
                      _removedEntities.remove(removedEntity);

                      if (_removedEntities.isEmpty) {
                        _sizeBeforeRemoval = null;
                      }
                    }),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Returns an empty box with the size before children were removed.
  ///
  /// A [Wrap] shrinks with its children, so the removed children would be
  /// clipped, e.g. after removing all children at once. As a non-positioned
  /// child of the [Stack], the [Stack] keeps at least its previous size.
  /// Returns null for other types or if no child is removed.
  Widget? _buildRemovedArea() {
    if (widget.type != ReorderableBuilderType.wrap) {
      return null;
    }

    final sizeBeforeRemoval = _sizeBeforeRemoval;

    if (_removedEntities.isEmpty || sizeBeforeRemoval == null) {
      return null;
    }

    return SizedBox.fromSize(size: sizeBeforeRemoval);
  }

  /// Adds removed children of [oldChildren] to [_removedEntities] to fade them out.
  ///
  /// Uses [ReorderableController.lastRemovedEntities] to get the last offset
  /// and size of the removed children.
  void _updateRemovedEntities({required List<Widget> oldChildren}) {
    final keyValues = {
      for (final child in widget.children!) (child.key as ValueKey).value,
    };

    // a child that was added again is shown by the GridView
    _removedEntities.removeWhere(
      (entity) => keyValues.contains(entity.key.value),
    );
    if (_removedEntities.isEmpty) {
      _sizeBeforeRemoval = null;
    }
    if (!_canFadeOut) {
      return;
    }

    final oldChildMap = {
      for (final child in oldChildren) (child.key as ValueKey).value: child,
    };
    final removedCount = _removedEntities.length;

    for (final entity in widget.controller.lastRemovedEntities) {
      final child = oldChildMap[entity.key.value];
      if (child == null || !_wasVisible(entity)) continue;

      _removedEntities.add(
        RemovedReorderableEntity(
          key: entity.key,
          child: child,
          offset: entity.updatedOffset,
          size: entity.size,
        ),
      );
    }

    if (_removedEntities.length > removedCount) {
      final renderBox = context.findRenderObject() as RenderBox?;
      
      if (renderBox != null && renderBox.hasSize) {
        _sizeBeforeRemoval ??= renderBox.size;
      }
      _delayPositionChanges();
    }
  }

  /// Finds removed children for ReorderableBuilder.builder to fade them out.
  ///
  /// When the item count decreases, the GridView rebuilds all children that
  /// are currently shown. A child that was visible before, but is not built
  /// again in the next frame, was removed.
  void _checkRemovedBuiltChildren({required int? oldItemCount}) {
    final itemCount = widget.itemCount;
    if (oldItemCount == null ||
        itemCount == null ||
        itemCount >= oldItemCount) {
      return;
    }

    if (!_canFadeOut) return;

    final controller = widget.controller;
    final visibleEntities = <RemovedReorderableEntity>[];

    for (final entity in controller.childrenKeyMap.values) {
      final child = controller.lastBuiltChildren[entity.key.value];
      if (child == null || !_wasVisible(entity)) continue;

      visibleEntities.add(
        RemovedReorderableEntity(
          key: entity.key,
          child: child,
          offset: entity.updatedOffset,
          size: entity.size,
        ),
      );
    }

    // all children were removed, so there is no need to wait for the GridView
    if (itemCount == 0) {
      _removedEntities.addAll(visibleEntities);
      return;
    }

    controller.builtKeyValues.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final removedEntities = visibleEntities.where(
        (entity) => !controller.builtKeyValues.contains(entity.key.value),
      );
      if (removedEntities.isEmpty) return;

      _delayPositionChanges();
      setState(() {
        for (final removedEntity in removedEntities) {
          controller.lastBuiltChildren.remove(removedEntity.key.value);
          _removedEntities.add(removedEntity);
        }
      });
    });
  }

  /// Lets the position changes of the current update wait for the fade out.
  ///
  /// Only if [ReorderableAnimationConfig.changePositionAfterFadeOut] is true.
  /// The delay is reset after the next frame, when all position changes of
  /// this update have started.
  void _delayPositionChanges() {
    final animationConfig = widget.animationConfig;
    if (!animationConfig.changePositionAfterFadeOut) return;

    final controller = widget.controller;
    // the children start to move while the removed child is still fading out
    controller.positionChangeDelay = animationConfig.remove.duration ~/ 2;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.positionChangeDelay = Duration.zero;
      });
    });
  }

  /// Returns true if [entity] was measured and at least partially visible
  /// in the last frame.
  bool _wasVisible(ReorderableEntity entity) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (entity.isBuildingOffset || renderBox == null || !renderBox.hasSize) {
      return false;
    }

    final offset = entity.updatedOffset - widget.getScrollOffset();
    return (offset & entity.size).overlaps(Offset.zero & renderBox.size);
  }

  /// Removed children only fade out with a duration and while not dragging.
  bool get _canFadeOut =>
      widget.animationConfig.remove.duration > Duration.zero &&
      widget.controller.draggedEntity == null;
}
