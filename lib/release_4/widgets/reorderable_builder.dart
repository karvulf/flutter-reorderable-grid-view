import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/release_4/widgets/reorderable_animated_opacity.dart';
import 'package:flutter_reorderable_grid_view/release_4/widgets/reorderable_init_child.dart';

typedef DraggableBuilder = Widget Function(
  List<Widget> children,
);

typedef ReorderListCallback = void Function(List<OrderUpdateEntity>);

/// Enables animated drag and drop behaviour for built widgets in [builder].
///
/// Be sure not to replace, add or remove your children while you are dragging
/// because this can lead to an unexpected behavior.
class ReorderableBuilder extends StatefulWidget {
  final List<Widget> children;

  /// Specify indices for [children] that should not change their position while dragging.
  ///
  /// Default value: <int>[]
  final List<int> lockedIndices;

  /// The drag of a child can be started with the long press.
  ///
  /// Default value: true
  final bool enableLongPress;

  /// Specify the [Duration] for the pressed child before starting the dragging.
  ///
  /// Default value: kLongPressTimeout
  final Duration longPressDelay;

  /// When disabling draggable, the drag and drop behavior is not working.
  ///
  /// When [enableDraggable] is true, [onReorder] must not be null.
  ///
  /// Default value: true
  final bool enableDraggable;

  /// Enables the functionality to scroll while dragging a child to the top or bottom.
  ///
  /// Combined with the value of [automaticScrollExtent], an automatic scroll starts,
  /// when you drag the child and the widget of [builder] is scrollable.
  ///
  /// Defualt value: true
  final bool enableScrollingWhileDragging;

  /// Defines the height of the top or bottom before the dragged child indicates a scrolling.
  ///
  /// Default value: 80.0
  final double automaticScrollExtent;

  /// [BoxDecoration] for the child that is dragged around.
  final BoxDecoration? dragChildBoxDecoration;

  /// Callback to return updated [children].
  final DraggableBuilder builder;

  /// After releasing the dragged child, [onReorder] is called.
  ///
  /// [enableDraggable] has to be true to ensure this is called.
  final ReorderListCallback? onReorder;

  /// Adding delay after initializing [children].
  ///
  /// Usually, the delay would be a postFrameCallBack. But sometimes, if the app
  /// is a bit slow, or there are a lot of things happening at the same time, a
  /// longer delay is necessary to ensure a correct behavior when using drag and drop.
  ///
  /// Not recommended to use.
  final Duration? initDelay;

  /// Callback when dragging starts.
  ///
  /// Prevent updating your children while you are dragging because this can lead
  /// to an unexpected behavior.
  final VoidCallback? onDragStarted;

  /// Callback when the dragged child was released.
  final VoidCallback? onDragEnd;

  /// [ScrollController] to get the current scroll position. Important for calculations!
  ///
  /// This controller has to be assigned if the returned widget of [builder] is
  /// scrollable. Every [GridView] is scrollable by default.
  ///
  /// So usually, you should assign the controller to the [ReorderableBuilder]
  /// and to your [GridView].
  final ScrollController? scrollController;

  const ReorderableBuilder({
    required this.children,
    required this.builder,
    this.scrollController,
    this.onReorder,
    this.lockedIndices = const [],
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.automaticScrollExtent = 80.0,
    this.enableScrollingWhileDragging = true,
    this.dragChildBoxDecoration,
    this.initDelay,
    this.onDragStarted,
    this.onDragEnd,
    Key? key,
  })  : assert((enableDraggable && onReorder != null) || !enableDraggable),
        super(key: key);

  @override
  State<ReorderableBuilder> createState() => _ReorderableBuilderState();
}

class _ReorderableBuilderState extends State<ReorderableBuilder> {
  final _childrenMap = <int, ReorderableEntity>{};
  final _childrenKeyMap = <dynamic, ReorderableEntity>{};

  @override
  void initState() {
    super.initState();

    var index = 0;
    for (final child in widget.children) {
      _checkChildState(child: child);
      assert(!_childrenMap.containsKey(child.key), "Key is duplicated!");
      final key = child.key! as ValueKey;
      final reorderableEntity = ReorderableEntity(
        key: key,
        originalOrderId: index,
        visible: false,
      );
      _updateMaps(reorderableEntity: reorderableEntity);
      index++;
    }
  }

  @override
  void didUpdateWidget(covariant ReorderableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    var index = 0;
    for (final child in widget.children) {
      _checkChildState(child: child);
      final key = child.key as ValueKey;
      final childInKeyMap = _childrenKeyMap[key.value];

      if (childInKeyMap == null) {
        final reorderableEntity = ReorderableEntity(
          key: child.key as ValueKey,
          originalOrderId: index,
          visible: false,
        );
        _updateMaps(reorderableEntity: reorderableEntity);
      } else {
        // child has updated or didn't change
      }
      index++;
    }
    // Todo: shouldn't rerender for every update, only if there was a change in children
    setState(() {});
  }

  void _updateMaps({required ReorderableEntity reorderableEntity}) {
    _childrenMap[reorderableEntity.originalOrderId] = reorderableEntity;
    _childrenKeyMap[reorderableEntity.key.value] = reorderableEntity;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_wrapChildren());
  }

  List<Widget> _wrapChildren() {
    final updatedChildren = <Widget>[];

    for (final child in widget.children) {
      final reorderableEntity = _childrenKeyMap[(child.key as ValueKey).value]!;
      updatedChildren.add(
        ReorderableAnimatedOpacity(
          reorderableEntity: reorderableEntity,
          child: ReorderableInitChild(
            onCreated: _handleCreatedChild,
            reorderableEntity: reorderableEntity,
            child: child,
          ),
        ),
      );
    }
    return updatedChildren;
  }

  void _handleCreatedChild(
    GlobalKey key,
    ReorderableEntity reorderableEntity,
  ) {
    final updatedReorderableEntity = reorderableEntity.copyWith(
      visible: true,
    );
    _updateMaps(reorderableEntity: updatedReorderableEntity);
    setState(() {});
  }

  void _handleDragStarted(ReorderableEntity reorderableEntity) {
    //
  }

  void _checkChildState({
    required Widget child,
  }) {
    assert(child.key != null, "Key can't be null!");
    assert(child.key is ValueKey, 'Key has to type of [ValueKey]!');
  }
}
